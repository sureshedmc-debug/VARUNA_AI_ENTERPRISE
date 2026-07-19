"""Tests for MAVLinkManager reconnection logic and message dispatch.

No serial port or hardware is needed – the underlying pymavutil connection
is fully mocked.
"""

from __future__ import annotations

import math
import threading
import time
from unittest.mock import MagicMock, patch, call

import pytest

from app.managers.mavlink_manager import MAVLinkManager, TelemetryState


class TestTelemetryState:
    def test_update_single_field(self) -> None:
        st = TelemetryState()
        st.update(roll=1.5)
        assert st.roll == pytest.approx(1.5)

    def test_update_multiple_fields(self) -> None:
        st = TelemetryState()
        st.update(lat=12.9716, lon=77.5946, alt_msl=920.0)
        assert st.lat == pytest.approx(12.9716)
        assert st.lon == pytest.approx(77.5946)
        assert st.alt_msl == pytest.approx(920.0)

    def test_update_ignores_unknown_fields(self) -> None:
        st = TelemetryState()
        st.update(nonexistent_field=42)  # should not raise

    def test_snapshot_excludes_lock(self) -> None:
        st = TelemetryState()
        snap = st.snapshot()
        assert "_lock" not in snap

    def test_snapshot_contains_core_fields(self) -> None:
        st = TelemetryState()
        snap = st.snapshot()
        for field in ("roll", "pitch", "yaw", "lat", "lon", "connected", "mode"):
            assert field in snap

    def test_thread_safety(self) -> None:
        st = TelemetryState()
        errors: list[Exception] = []

        def writer() -> None:
            for i in range(200):
                try:
                    st.update(roll=float(i))
                except Exception as e:
                    errors.append(e)

        def reader() -> None:
            for _ in range(200):
                try:
                    st.snapshot()
                except Exception as e:
                    errors.append(e)

        threads = [threading.Thread(target=writer), threading.Thread(target=reader)]
        for t in threads:
            t.start()
        for t in threads:
            t.join()
        assert errors == []


class TestMAVLinkManagerStateUpdates:
    """Test _update_state correctly parses MAVLink messages."""

    def _make_manager(self) -> MAVLinkManager:
        mgr = MAVLinkManager()
        mgr.state.update(connected=True, vehicle_type=2)
        return mgr

    def _mock_msg(self, msg_type: str, **attrs: object) -> MagicMock:
        msg = MagicMock()
        msg.get_type.return_value = msg_type
        for k, v in attrs.items():
            setattr(msg, k, v)
        return msg

    def test_attitude_update(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "ATTITUDE",
            roll=math.radians(10),
            pitch=math.radians(5),
            yaw=math.radians(90),
            rollspeed=0.1,
            pitchspeed=0.05,
            yawspeed=0.02,
        )
        mgr._update_state(msg)
        assert mgr.state.roll == pytest.approx(10.0, abs=0.01)
        assert mgr.state.pitch == pytest.approx(5.0, abs=0.01)
        assert mgr.state.yaw == pytest.approx(90.0, abs=0.01)

    def test_global_position_int_update(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "GLOBAL_POSITION_INT",
            lat=int(12.9716 * 1e7),
            lon=int(77.5946 * 1e7),
            alt=int(920.0 * 1000),
            relative_alt=int(0.0 * 1000),
            vx=int(1.0 * 100),
            vy=int(0.5 * 100),
            vz=int(-0.1 * 100),
            hdg=4500,  # 45.00 degrees
        )
        mgr._update_state(msg)
        assert mgr.state.lat == pytest.approx(12.9716, rel=1e-4)
        assert mgr.state.lon == pytest.approx(77.5946, rel=1e-4)
        assert mgr.state.alt_msl == pytest.approx(920.0, abs=0.01)
        assert mgr.state.vx == pytest.approx(1.0, abs=0.01)
        assert mgr.state.heading == pytest.approx(45.0, abs=0.01)

    def test_vfr_hud_update(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "VFR_HUD",
            airspeed=15.0,
            groundspeed=14.5,
            heading=90,
        )
        mgr._update_state(msg)
        assert mgr.state.airspeed == pytest.approx(15.0)
        assert mgr.state.groundspeed == pytest.approx(14.5)
        assert mgr.state.heading == pytest.approx(90.0)

    def test_gps_raw_int_update(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "GPS_RAW_INT",
            fix_type=3,
            satellites_visible=12,
            eph=90,  # 0.90 HDOP
        )
        mgr._update_state(msg)
        assert mgr.state.fix_type == 3
        assert mgr.state.satellites_visible == 12
        assert mgr.state.hdop == pytest.approx(0.9)

    def test_sys_status_battery(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "SYS_STATUS",
            voltage_battery=12600,
            current_battery=150,
            battery_remaining=80,
        )
        mgr._update_state(msg)
        assert mgr.state.battery_voltage == pytest.approx(12.6)
        assert mgr.state.battery_current == pytest.approx(1.5)
        assert mgr.state.battery_remaining == 80

    def test_heartbeat_armed(self) -> None:
        import pymavlink.mavutil as mavutil

        mgr = self._make_manager()
        msg = self._mock_msg(
            "HEARTBEAT",
            custom_mode=5,  # LOITER for copter
            type=2,         # QUADROTOR
            system_status=4,
            base_mode=mavutil.mavlink.MAV_MODE_FLAG_SAFETY_ARMED,
        )
        mgr._update_state(msg)
        assert mgr.state.armed is True
        assert mgr.state.mode == "LOITER"

    def test_heartbeat_disarmed(self) -> None:
        mgr = self._make_manager()
        msg = self._mock_msg(
            "HEARTBEAT",
            custom_mode=0,
            type=2,
            system_status=3,
            base_mode=0,
        )
        mgr._update_state(msg)
        assert mgr.state.armed is False
        assert mgr.state.mode == "STABILIZE"

    def test_plane_mode_decode(self) -> None:
        mgr = self._make_manager()
        mgr.state.update(vehicle_type=1)
        msg = self._mock_msg(
            "HEARTBEAT",
            custom_mode=10,  # AUTO for plane
            type=1,
            system_status=4,
            base_mode=0,
        )
        mgr._update_state(msg)
        assert mgr.state.mode == "AUTO"


class TestMAVLinkManagerReconnect:
    """Test the reconnect scheduling logic."""

    def test_schedule_reconnect_starts_thread(self) -> None:
        mgr = MAVLinkManager()
        mgr._running = True

        # Patch _connect to return True immediately
        with patch.object(mgr, "_connect", return_value=True):
            mgr._schedule_reconnect()
            assert mgr._reconnect_thread is not None
            mgr._reconnect_thread.join(timeout=3.0)
            assert not mgr._reconnect_thread.is_alive()

    def test_schedule_reconnect_not_duplicated(self) -> None:
        mgr = MAVLinkManager()
        mgr._running = True
        barrier = threading.Event()

        def slow_connect() -> bool:
            barrier.wait(timeout=5.0)
            return True

        with patch.object(mgr, "_connect", side_effect=slow_connect):
            mgr._schedule_reconnect()
            first_thread = mgr._reconnect_thread

            # Second schedule call should NOT start another thread
            mgr._schedule_reconnect()
            assert mgr._reconnect_thread is first_thread
            barrier.set()
            first_thread.join(timeout=3.0)

    def test_reconnect_stops_when_running_false(self) -> None:
        mgr = MAVLinkManager()
        mgr._running = True
        connect_calls: list[int] = []

        def failing_connect() -> bool:
            connect_calls.append(1)
            return False

        with patch.object(mgr, "_connect", side_effect=failing_connect):
            mgr._running = False  # immediately stop
            mgr._reconnect_with_backoff()
            # Should not attempt connect since _running is False
            assert connect_calls == []


class TestMAVLinkManagerSubscribers:
    def test_subscribe_and_dispatch(self) -> None:
        mgr = MAVLinkManager()
        received: list[object] = []
        mgr.subscribe("ATTITUDE", received.append)

        msg = MagicMock()
        msg.get_type.return_value = "ATTITUDE"
        mgr._dispatch_message(msg)
        assert len(received) == 1

    def test_unsubscribe_removes_callback(self) -> None:
        mgr = MAVLinkManager()
        received: list[object] = []
        cb = received.append
        mgr.subscribe("ATTITUDE", cb)
        mgr.unsubscribe("ATTITUDE", cb)

        msg = MagicMock()
        msg.get_type.return_value = "ATTITUDE"
        mgr._dispatch_message(msg)
        assert received == []

    def test_wildcard_subscriber(self) -> None:
        mgr = MAVLinkManager()
        received: list[str] = []

        def cb(m: MagicMock) -> None:
            received.append(m.get_type())

        mgr.subscribe("*", cb)
        for msg_type in ["ATTITUDE", "HEARTBEAT", "GPS_RAW_INT"]:
            msg = MagicMock()
            msg.get_type.return_value = msg_type
            mgr._dispatch_message(msg)

        assert received == ["ATTITUDE", "HEARTBEAT", "GPS_RAW_INT"]

    def test_wait_for_message_satisfied(self) -> None:
        mgr = MAVLinkManager()
        target_msg = MagicMock()
        target_msg.get_type.return_value = "COMMAND_ACK"

        def deliver() -> None:
            time.sleep(0.05)
            mgr._dispatch_message(target_msg)

        threading.Thread(target=deliver, daemon=True).start()
        result = mgr.wait_for_message("COMMAND_ACK", timeout=2.0)
        assert result is target_msg

    def test_wait_for_message_timeout(self) -> None:
        mgr = MAVLinkManager()
        result = mgr.wait_for_message("COMMAND_ACK", timeout=0.1)
        assert result is None

    def test_wait_for_message_with_condition(self) -> None:
        mgr = MAVLinkManager()

        ack1 = MagicMock()
        ack1.get_type.return_value = "COMMAND_ACK"
        ack1.command = 400

        ack2 = MagicMock()
        ack2.get_type.return_value = "COMMAND_ACK"
        ack2.command = 22  # expected

        def deliver() -> None:
            time.sleep(0.05)
            mgr._dispatch_message(ack1)
            time.sleep(0.05)
            mgr._dispatch_message(ack2)

        threading.Thread(target=deliver, daemon=True).start()
        result = mgr.wait_for_message(
            "COMMAND_ACK", timeout=2.0, condition=lambda m: m.command == 22
        )
        assert result is ack2
