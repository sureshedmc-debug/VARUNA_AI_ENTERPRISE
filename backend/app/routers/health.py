"""Health-check router.

GET /api/v1/health  – Returns service liveness, MAVLink status, and
                      basic vehicle information.
"""

from __future__ import annotations

import time

from fastapi import APIRouter

from app.config import settings
from app.dependencies import MAVLinkDep
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1/health", tags=["Health"])


class HealthResponse(BaseModel):
    status: str
    timestamp: float
    app_name: str
    app_version: str
    mavlink_connected: bool
    vehicle_mode: str
    vehicle_armed: bool
    mavlink_connection: str


@router.get("", response_model=HealthResponse, summary="Service health check")
async def health_check(mavlink: MAVLinkDep) -> HealthResponse:
    """Returns HTTP 200 while the service is running.

    ``mavlink_connected`` reflects the current connection state to the
    Pixhawk 2.4.8.  The endpoint itself always returns 200 to allow load
    balancers and container orchestrators to distinguish *service alive*
    from *vehicle connected*.
    """
    st = mavlink.state
    return HealthResponse(
        status="ok",
        timestamp=time.time(),
        app_name=settings.app_name,
        app_version=settings.app_version,
        mavlink_connected=st.connected,
        vehicle_mode=st.mode,
        vehicle_armed=st.armed,
        mavlink_connection=settings.mavlink_connection,
    )
