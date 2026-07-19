"""Telemetry router.

GET  /api/v1/telemetry       – Latest telemetry snapshot (REST)
WS   /ws/telemetry           – Real-time telemetry stream (WebSocket, 10 Hz)
"""

from __future__ import annotations

from fastapi import APIRouter, WebSocket

from app.dependencies import MAVLinkDep, WebSocketDep
from app.models.telemetry import TelemetrySnapshot
from app.websocket.manager import WebSocketManager
import time

router = APIRouter(tags=["Telemetry"])


@router.get(
    "/api/v1/telemetry",
    response_model=TelemetrySnapshot,
    summary="Get current telemetry snapshot",
)
async def get_telemetry(mavlink: MAVLinkDep) -> TelemetrySnapshot:
    """Returns the latest telemetry data captured from the vehicle.

    This is a point-in-time snapshot.  For real-time streaming use the
    WebSocket endpoint ``/ws/telemetry``.
    """
    st = mavlink.state
    from app.models.telemetry import (
        AttitudeModel,
        BatteryModel,
        GPSModel,
        PositionModel,
        VelocityModel,
    )

    return TelemetrySnapshot(
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


@router.websocket("/ws/telemetry")
async def telemetry_websocket(
    websocket: WebSocket,
    mavlink: MAVLinkDep,
    ws_manager: WebSocketDep,
) -> None:
    """Real-time telemetry stream at 10 Hz (configurable via VARUNA_WS_TELEMETRY_INTERVAL).

    The server broadcasts a :class:`TelemetrySnapshot` JSON frame every
    ``ws_telemetry_interval`` seconds.  The client may send any text to
    keep the connection alive; the server echoes ``{"type":"ping"}`` every
    30 seconds of inactivity.
    """
    await ws_manager.handle_client(websocket, mavlink)
