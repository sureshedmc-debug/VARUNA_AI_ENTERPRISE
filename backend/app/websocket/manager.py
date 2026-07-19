"""WebSocket connection manager and telemetry broadcaster.

Manages a pool of connected WebSocket clients and broadcasts the latest
telemetry snapshot at the configured interval (default 10 Hz).
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
from typing import Optional

from fastapi import WebSocket, WebSocketDisconnect

from app.config import settings
from app.managers.mavlink_manager import MAVLinkManager
from app.models.telemetry import (
    AttitudeModel,
    BatteryModel,
    GPSModel,
    PositionModel,
    TelemetrySnapshot,
    VelocityModel,
)

logger = logging.getLogger(__name__)


class WebSocketManager:
    """Manages WebSocket connections and broadcasts telemetry frames.

    A background asyncio task calls :meth:`broadcast_telemetry` at
    ``settings.ws_telemetry_interval`` seconds to push frames to all
    connected clients.  Disconnected clients are removed automatically.
    """

    def __init__(self) -> None:
        self._connections: list[WebSocket] = []
        self._lock = asyncio.Lock()
        self._broadcaster_task: Optional[asyncio.Task] = None  # type: ignore[type-arg]

    # ------------------------------------------------------------------
    # Connection lifecycle
    # ------------------------------------------------------------------

    async def connect(self, websocket: WebSocket) -> None:
        await websocket.accept()
        async with self._lock:
            self._connections.append(websocket)
        logger.info(
            "WebSocket client connected (%d total)", len(self._connections)
        )

    async def disconnect(self, websocket: WebSocket) -> None:
        async with self._lock:
            try:
                self._connections.remove(websocket)
            except ValueError:
                pass
        logger.info(
            "WebSocket client disconnected (%d total)", len(self._connections)
        )

    # ------------------------------------------------------------------
    # Broadcasting
    # ------------------------------------------------------------------

    async def broadcast(self, data: str) -> None:
        """Send *data* to all connected clients, removing stale ones."""
        async with self._lock:
            clients = list(self._connections)

        dead: list[WebSocket] = []
        for ws in clients:
            try:
                await ws.send_text(data)
            except Exception:
                dead.append(ws)

        if dead:
            async with self._lock:
                for ws in dead:
                    try:
                        self._connections.remove(ws)
                    except ValueError:
                        pass

    async def broadcast_telemetry(self, mavlink: MAVLinkManager) -> None:
        """Build a telemetry snapshot from *mavlink* state and broadcast."""
        st = mavlink.state
        snapshot = TelemetrySnapshot(
            timestamp=time.time(),
            connected=st.connected,
            armed=st.armed,
            mode=st.mode,
            system_status=st.system_status,
            heading=st.heading,
            attitude=AttitudeModel(
                roll=st.roll,
                pitch=st.pitch,
                yaw=st.yaw,
                rollspeed=st.rollspeed,
                pitchspeed=st.pitchspeed,
                yawspeed=st.yawspeed,
            ),
            position=PositionModel(
                lat=st.lat,
                lon=st.lon,
                alt_msl=st.alt_msl,
                alt_rel=st.alt_rel,
            ),
            velocity=VelocityModel(
                vx=st.vx,
                vy=st.vy,
                vz=st.vz,
                groundspeed=st.groundspeed,
                airspeed=st.airspeed,
            ),
            gps=GPSModel(
                fix_type=st.fix_type,
                satellites_visible=st.satellites_visible,
                hdop=st.hdop,
            ),
            battery=BatteryModel(
                voltage=st.battery_voltage,
                current=st.battery_current,
                remaining=st.battery_remaining,
            ),
        )
        await self.broadcast(snapshot.model_dump_json())

    # ------------------------------------------------------------------
    # Background broadcaster
    # ------------------------------------------------------------------

    def start_broadcaster(self, mavlink: MAVLinkManager) -> None:
        """Schedule the background broadcaster coroutine."""
        self._broadcaster_task = asyncio.ensure_future(
            self._broadcaster_loop(mavlink)
        )
        logger.info(
            "WebSocket telemetry broadcaster started (interval=%.2f s)",
            settings.ws_telemetry_interval,
        )

    def stop_broadcaster(self) -> None:
        if self._broadcaster_task is not None and not self._broadcaster_task.done():
            self._broadcaster_task.cancel()
        logger.info("WebSocket telemetry broadcaster stopped")

    async def _broadcaster_loop(self, mavlink: MAVLinkManager) -> None:
        while True:
            try:
                await asyncio.sleep(settings.ws_telemetry_interval)
                if self._connections:
                    await self.broadcast_telemetry(mavlink)
            except asyncio.CancelledError:
                break
            except Exception as exc:
                logger.error("Broadcaster loop error: %s", exc)

    # ------------------------------------------------------------------
    # WebSocket endpoint handler
    # ------------------------------------------------------------------

    async def handle_client(
        self,
        websocket: WebSocket,
        mavlink: MAVLinkManager,
    ) -> None:
        """Accept *websocket* and keep it alive until the client disconnects.

        Sends an initial telemetry snapshot immediately on connect, then
        relies on the background broadcaster for subsequent frames.
        """
        await self.connect(websocket)
        try:
            # Immediate snapshot so the client has data right away
            await self.broadcast_telemetry(mavlink)
            # Keep connection alive; the broadcaster pushes frames
            while True:
                try:
                    # Wait for client messages (ping/pong or close)
                    await asyncio.wait_for(websocket.receive_text(), timeout=30.0)
                except asyncio.TimeoutError:
                    # Send a ping to keep the connection alive
                    await websocket.send_text('{"type":"ping"}')
        except WebSocketDisconnect:
            pass
        except Exception as exc:
            logger.debug("WebSocket handler exception: %s", exc)
        finally:
            await self.disconnect(websocket)
