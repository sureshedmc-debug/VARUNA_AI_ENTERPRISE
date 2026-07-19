"""Enterprise MAVLink Manager.

Manages a persistent MAVLink 2 connection to a Pixhawk 2.4.8 running
ArduPilot 4.6.x.  Designed to run as a singleton on a Raspberry Pi 3A+
companion computer.

Features
--------
- Serial (GPIO UART) and UDP connections
- Automatic reconnection with exponential back-off
- Background reader thread that populates a thread-safe TelemetryState
- Subscriber / callback system for incoming MAVLink messages
- Synchronous helper methods used by MissionManager and ParameterManager
- Heartbeat sender (keeps ArduPilot from triggering GCS heartbeat failsafe)
"""

from __future__ import annotations

import logging
import math
import threading
import time
from collections import defaultdict
from collections.abc import Callable
from dataclasses import dataclass, field
from typing import Any, Optional

import pymavlink.mavutil as mavutil

from app.config import settings

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Flight-mode lookup tables for ArduPilot 4.6.x (Copter + Plane)
# ---------------------------------------------------------------------------
_COPTER_MODE_MAP: dict[int, str] = {
    0: "STABILIZE",
    1: "ACRO",
    2: "ALT_HOLD",
    3: "AUTO",
    4: "GUIDED",
    5: "LOITER",
    6: "RTL",
    7: "CIRCLE",
    9: "LAND",
    11: "DRIFT",
    13: "SPORT",
    14: "FLIP",
    15: "AUTOTUNE",
    16: "POSHOLD",
    17: "BRAKE",
    18: "THROW",
    19: "AVOID_ADSB",
    20: "GUIDED_NOGPS",
    21: "SMART_RTL",
    22: "FLOWHOLD",
    23: "FOLLOW",
    24: "ZIGZAG",
    25: "SYSTEMID",
    26: "AUTOROTATE",
    27: "AUTO_RTL",
}

_PLANE_MODE_MAP: dict[int, str] = {
    0: "MANUAL",
    1: "CIRCLE",
    2: "STABILIZE",
    3: "TRAINING",
    4: "ACRO",
    5: "FBWA",
    6: "FBWB",
    7: "CRUISE",
    8: "AUTOTUNE",
    10: "AUTO",
    11: "RTL",
    12: "LOITER",
    13: "TAKEOFF",
    14: "AVOID_ADSB",
    15: "GUIDED",
    17: "QSTABILIZE",
    18: "QHOVER",
    19: "QLOITER",
    20: "QLAND",
    21: "QRTL",
    22: "QAUTOTUNE",
    23: "QACRO",
    24: "THERMAL",
    25: "LOITER_ALT_QLAND",
}


# ---------------------------------------------------------------------------
# Thread-safe telemetry state
# ---------------------------------------------------------------------------

@dataclass
class TelemetryState:
    """Single-source-of-truth for vehicle state updated by the reader thread."""

    # Attitude (from ATTITUDE message)
    roll: float = 0.0
    pitch: float = 0.0
    yaw: float = 0.0
    rollspeed: float = 0.0
    pitchspeed: float = 0.0
    yawspeed: float = 0.0

    # Global position (from GLOBAL_POSITION_INT)
    lat: float = 0.0
    lon: float = 0.0
    alt_msl: float = 0.0
    alt_rel: float = 0.0

    # Velocity (from GLOBAL_POSITION_INT + VFR_HUD)
    vx: float = 0.0
    vy: float = 0.0
    vz: float = 0.0
    groundspeed: float = 0.0
    airspeed: float = 0.0

    # Heading (degrees 0-359, from VFR_HUD)
    heading: float = 0.0

    # Battery (from SYS_STATUS / BATTERY_STATUS)
    battery_voltage: float = 0.0
    battery_current: float = -1.0
    battery_remaining: int = -1

    # GPS (from GPS_RAW_INT)
    fix_type: int = 0
    satellites_visible: int = 0
    hdop: float = 99.99

    # Vehicle status (from HEARTBEAT)
    mode: str = "UNKNOWN"
    armed: bool = False
    system_status: int = 0        # MAV_STATE
    autopilot_type: int = 0       # MAV_AUTOPILOT
    vehicle_type: int = 0         # MAV_TYPE

    # Connection
    connected: bool = False
    last_heartbeat: float = 0.0

    _lock: threading.Lock = field(default_factory=threading.Lock, repr=False)

    def update(self, **kwargs: Any) -> None:
        with self._lock:
            for key, value in kwargs.items():
                if hasattr(self, key):
                    object.__setattr__(self, key, value)

    def snapshot(self) -> dict[str, Any]:
        with self._lock:
            return {
                k: v
                for k, v in self.__dict__.items()
                if not k.startswith("_")
            }


# ---------------------------------------------------------------------------
# MAVLink Manager
# ---------------------------------------------------------------------------

class MAVLinkManager:
    """Enterprise-grade MAVLink connection manager.

    Usage
    -----
    .. code-block:: python

        manager = MAVLinkManager()
        manager.start()          # starts reader + heartbeat threads
        # ... use manager ...
        manager.stop()           # graceful shutdown

    The manager can also be used as an async context manager from FastAPI
    lifespan events.
    """

    def __init__(self) -> None:
        self._connection: Optional[mavutil.mavfile] = None
        self._connection_lock = threading.Lock()

        self._running = False
        self._reader_thread: Optional[threading.Thread] = None
        self._heartbeat_thread: Optional[threading.Thread] = None
        self._reconnect_thread: Optional[threading.Thread] = None

        self.state = TelemetryState()

        # message type → list of callbacks(msg)
        self._subscribers: dict[str, list[Callable]] = defaultdict(list)
        self._subscriber_lock = threading.Lock()

        # one-shot reply events keyed by message type name
        self._reply_events: dict[str, threading.Event] = {}
        self._reply_messages: dict[str, Any] = {}
        self._reply_lock = threading.Lock()

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    def start(self) -> None:
        """Start the manager (connect + background threads)."""
        if self._running:
            return
        self._running = True
        self._connect()
        self._reader_thread = threading.Thread(
            target=self._reader_loop, name="mavlink-reader", daemon=True
        )
        self._reader_thread.start()
        self._heartbeat_thread = threading.Thread(
            target=self._heartbeat_loop, name="mavlink-heartbeat", daemon=True
        )
        self._heartbeat_thread.start()
        logger.info("MAVLinkManager started (connection=%s)", settings.mavlink_connection)

    def stop(self) -> None:
        """Gracefully stop all threads and close the connection."""
        self._running = False
        with self._connection_lock:
            if self._connection is not None:
                try:
                    self._connection.close()
                except Exception:
                    pass
                self._connection = None
        self.state.update(connected=False)
        logger.info("MAVLinkManager stopped")

    # ------------------------------------------------------------------
    # Connection management
    # ------------------------------------------------------------------

    def _connect(self) -> bool:
        """Attempt to open the MAVLink connection.  Returns True on success."""
        conn_str = settings.mavlink_connection
        try:
            with self._connection_lock:
                if self._connection is not None:
                    try:
                        self._connection.close()
                    except Exception:
                        pass

                logger.info("Connecting to MAVLink: %s (baud=%d)", conn_str, settings.mavlink_baud)
                conn = mavutil.mavlink_connection(
                    conn_str,
                    baud=settings.mavlink_baud,
                    source_system=settings.mavlink_source_system,
                    source_component=settings.mavlink_source_component,
                )
                # Wait for first heartbeat (blocks up to timeout)
                logger.info("Waiting for HEARTBEAT from vehicle …")
                hb = conn.wait_heartbeat(timeout=settings.mavlink_timeout)
                if hb is None:
                    logger.warning("No HEARTBEAT received within %.1fs", settings.mavlink_timeout)
                    conn.close()
                    return False

                self._connection = conn
                self.state.update(
                    connected=True,
                    last_heartbeat=time.time(),
                    autopilot_type=hb.autopilot,
                    vehicle_type=hb.type,
                )
                logger.info(
                    "MAVLink connected – sysid=%d compid=%d type=%d autopilot=%d",
                    hb.get_srcSystem(),
                    hb.get_srcComponent(),
                    hb.type,
                    hb.autopilot,
                )
                return True
        except Exception as exc:
            logger.error("MAVLink connection failed: %s", exc)
            self.state.update(connected=False)
            return False

    def _reconnect_with_backoff(self) -> None:
        """Reconnect loop with exponential back-off (runs in its own thread)."""
        delay = settings.mavlink_reconnect_delay
        while self._running:
            logger.info("Reconnecting in %.1f s …", delay)
            time.sleep(delay)
            if not self._running:
                return
            if self._connect():
                return
            delay = min(delay * 2, settings.mavlink_max_reconnect_delay)

    def _schedule_reconnect(self) -> None:
        """Start a reconnect thread if not already running."""
        if self._reconnect_thread is not None and self._reconnect_thread.is_alive():
            return
        self._reconnect_thread = threading.Thread(
            target=self._reconnect_with_backoff,
            name="mavlink-reconnect",
            daemon=True,
        )
        self._reconnect_thread.start()

    # ------------------------------------------------------------------
    # Background threads
    # ------------------------------------------------------------------

    def _reader_loop(self) -> None:
        """Continuously read MAVLink messages and dispatch to handlers."""
        while self._running:
            conn = self._get_connection()
            if conn is None:
                time.sleep(0.1)
                continue
            try:
                msg = conn.recv_match(blocking=True, timeout=settings.mavlink_timeout)
                if msg is None:
                    # timeout – check heartbeat freshness
                    if self.state.connected:
                        elapsed = time.time() - self.state.last_heartbeat
                        if elapsed > settings.mavlink_timeout * 2:
                            logger.warning(
                                "No heartbeat for %.1f s – marking disconnected", elapsed
                            )
                            self.state.update(connected=False)
                            self._schedule_reconnect()
                    continue

                msg_type = msg.get_type()
                if msg_type == "BAD_DATA":
                    continue

                self._dispatch_message(msg)
                self._update_state(msg)
            except Exception as exc:
                logger.error("Reader loop error: %s", exc)
                self.state.update(connected=False)
                self._schedule_reconnect()
                time.sleep(1.0)

    def _heartbeat_loop(self) -> None:
        """Send GCS heartbeat at the configured interval."""
        while self._running:
            conn = self._get_connection()
            if conn is not None:
                try:
                    conn.mav.heartbeat_send(
                        mavutil.mavlink.MAV_TYPE_GCS,
                        mavutil.mavlink.MAV_AUTOPILOT_INVALID,
                        0,
                        0,
                        0,
                    )
                except Exception as exc:
                    logger.debug("Heartbeat send error: %s", exc)
            time.sleep(settings.mavlink_heartbeat_interval)

    # ------------------------------------------------------------------
    # State update from MAVLink messages
    # ------------------------------------------------------------------

    def _update_state(self, msg: Any) -> None:
        msg_type = msg.get_type()

        if msg_type == "HEARTBEAT":
            mode_str = self._decode_mode(msg)
            armed = bool(msg.base_mode & mavutil.mavlink.MAV_MODE_FLAG_SAFETY_ARMED)
            self.state.update(
                mode=mode_str,
                armed=armed,
                system_status=msg.system_status,
                last_heartbeat=time.time(),
                connected=True,
            )

        elif msg_type == "ATTITUDE":
            self.state.update(
                roll=math.degrees(msg.roll),
                pitch=math.degrees(msg.pitch),
                yaw=math.degrees(msg.yaw),
                rollspeed=msg.rollspeed,
                pitchspeed=msg.pitchspeed,
                yawspeed=msg.yawspeed,
            )

        elif msg_type == "GLOBAL_POSITION_INT":
            self.state.update(
                lat=msg.lat / 1e7,
                lon=msg.lon / 1e7,
                alt_msl=msg.alt / 1000.0,
                alt_rel=msg.relative_alt / 1000.0,
                vx=msg.vx / 100.0,
                vy=msg.vy / 100.0,
                vz=msg.vz / 100.0,
                heading=msg.hdg / 100.0 if msg.hdg != 65535 else 0.0,
            )

        elif msg_type == "VFR_HUD":
            self.state.update(
                airspeed=msg.airspeed,
                groundspeed=msg.groundspeed,
                heading=float(msg.heading),
            )

        elif msg_type == "GPS_RAW_INT":
            self.state.update(
                fix_type=msg.fix_type,
                satellites_visible=msg.satellites_visible,
                hdop=msg.eph / 100.0 if msg.eph != 65535 else 99.99,
            )

        elif msg_type == "SYS_STATUS":
            self.state.update(
                battery_voltage=msg.voltage_battery / 1000.0,
                battery_current=msg.current_battery / 100.0 if msg.current_battery != -1 else -1.0,
                battery_remaining=msg.battery_remaining,
            )

        elif msg_type == "BATTERY_STATUS":
            # Prefer BATTERY_STATUS if available (more detailed)
            if msg.voltages[0] != 65535:
                self.state.update(
                    battery_voltage=msg.voltages[0] / 1000.0,
                )
            if msg.current_battery != -1:
                self.state.update(battery_current=msg.current_battery / 100.0)
            if msg.battery_remaining != -1:
                self.state.update(battery_remaining=msg.battery_remaining)

    def _decode_mode(self, hb_msg: Any) -> str:
        """Decode ArduPilot custom flight mode from a HEARTBEAT message."""
        custom_mode = hb_msg.custom_mode
        vehicle_type = hb_msg.type

        # MAV_TYPE_FIXED_WING = 1, MAV_TYPE_QUADROTOR = 2, etc.
        # Plane types: 1 (FIXED_WING), 19 (VTOL_DUOROTOR), 20 (VTOL_QUADROTOR)
        if vehicle_type in (1, 19, 20, 21):
            return _PLANE_MODE_MAP.get(custom_mode, f"MODE_{custom_mode}")
        return _COPTER_MODE_MAP.get(custom_mode, f"MODE_{custom_mode}")

    # ------------------------------------------------------------------
    # Subscriber / dispatch system
    # ------------------------------------------------------------------

    def subscribe(self, msg_type: str, callback: Callable[[Any], None]) -> None:
        """Register *callback* to be called for each *msg_type* message."""
        with self._subscriber_lock:
            self._subscribers[msg_type].append(callback)

    def unsubscribe(self, msg_type: str, callback: Callable[[Any], None]) -> None:
        with self._subscriber_lock:
            try:
                self._subscribers[msg_type].remove(callback)
            except ValueError:
                pass

    def _dispatch_message(self, msg: Any) -> None:
        msg_type = msg.get_type()
        with self._subscriber_lock:
            callbacks = list(self._subscribers.get(msg_type, []))
            # Also dispatch to wildcard "*" subscribers
            callbacks += list(self._subscribers.get("*", []))
        for cb in callbacks:
            try:
                cb(msg)
            except Exception as exc:
                logger.error("Subscriber callback error (%s): %s", msg_type, exc)

    # ------------------------------------------------------------------
    # Reply-message waiting (used by mission / parameter managers)
    # ------------------------------------------------------------------

    def wait_for_message(
        self,
        msg_type: str,
        timeout: float = 5.0,
        condition: Optional[Callable[[Any], bool]] = None,
    ) -> Optional[Any]:
        """Block until a message of *msg_type* arrives (or timeout).

        Optionally filter with *condition(msg) -> bool*.
        """
        result: list[Any] = []
        event = threading.Event()

        def _handler(msg: Any) -> None:
            if condition is None or condition(msg):
                result.append(msg)
                event.set()

        self.subscribe(msg_type, _handler)
        try:
            event.wait(timeout=timeout)
        finally:
            self.unsubscribe(msg_type, _handler)

        return result[0] if result else None

    # ------------------------------------------------------------------
    # Send helpers
    # ------------------------------------------------------------------

    def _get_connection(self) -> Optional[mavutil.mavfile]:
        with self._connection_lock:
            return self._connection

    def send_command_long(
        self,
        command: int,
        param1: float = 0,
        param2: float = 0,
        param3: float = 0,
        param4: float = 0,
        param5: float = 0,
        param6: float = 0,
        param7: float = 0,
        confirmation: int = 0,
    ) -> bool:
        """Send a MAVLink COMMAND_LONG and return True if the send succeeded."""
        conn = self._get_connection()
        if conn is None:
            return False
        try:
            conn.mav.command_long_send(
                conn.target_system,
                conn.target_component,
                command,
                confirmation,
                param1,
                param2,
                param3,
                param4,
                param5,
                param6,
                param7,
            )
            return True
        except Exception as exc:
            logger.error("COMMAND_LONG send error: %s", exc)
            return False

    def send_command_long_and_wait(
        self,
        command: int,
        param1: float = 0,
        param2: float = 0,
        param3: float = 0,
        param4: float = 0,
        param5: float = 0,
        param6: float = 0,
        param7: float = 0,
        timeout: Optional[float] = None,
    ) -> Optional[Any]:
        """Send COMMAND_LONG and wait for the COMMAND_ACK reply."""
        to = timeout or settings.command_ack_timeout
        sent = self.send_command_long(
            command, param1, param2, param3, param4, param5, param6, param7
        )
        if not sent:
            return None
        return self.wait_for_message(
            "COMMAND_ACK",
            timeout=to,
            condition=lambda m: m.command == command,
        )

    def set_mode(self, mode_name: str) -> bool:
        """Change the flight mode by name (case-insensitive)."""
        conn = self._get_connection()
        if conn is None:
            return False

        # Build reverse lookup
        vehicle_type = self.state.vehicle_type
        if vehicle_type in (1, 19, 20, 21):
            mode_map = {v.upper(): k for k, v in _PLANE_MODE_MAP.items()}
        else:
            mode_map = {v.upper(): k for k, v in _COPTER_MODE_MAP.items()}

        mode_id = mode_map.get(mode_name.upper())
        if mode_id is None:
            logger.error("Unknown mode: %s", mode_name)
            return False

        try:
            conn.set_mode(mode_id)
            return True
        except Exception as exc:
            logger.error("set_mode error: %s", exc)
            return False

    @property
    def target_system(self) -> int:
        conn = self._get_connection()
        return conn.target_system if conn else 1

    @property
    def target_component(self) -> int:
        conn = self._get_connection()
        return conn.target_component if conn else 1

    @property
    def mav(self) -> Optional[Any]:
        conn = self._get_connection()
        return conn.mav if conn else None

    @property
    def is_connected(self) -> bool:
        return self.state.connected
