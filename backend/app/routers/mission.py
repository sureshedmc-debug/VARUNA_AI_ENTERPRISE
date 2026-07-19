"""Mission router.

GET    /api/v1/mission           – Download current mission from vehicle
POST   /api/v1/mission           – Upload a new mission to vehicle
DELETE /api/v1/mission           – Clear mission on vehicle
GET    /api/v1/mission/current   – Get active waypoint index
POST   /api/v1/mission/current   – Set (jump to) a waypoint
"""

from __future__ import annotations

import logging

from fastapi import APIRouter, HTTPException, Response, status

from app.dependencies import MAVLinkDep, MissionDep
from app.models.mission import (
    MissionCurrentResponse,
    MissionResponse,
    MissionUploadRequest,
    SetCurrentWaypointRequest,
)

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/mission", tags=["Mission"])


@router.get("", response_model=MissionResponse, summary="Download mission from vehicle")
async def download_mission(
    mavlink: MAVLinkDep,
    mission: MissionDep,
) -> MissionResponse:
    """Download the current mission stored on the vehicle."""
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    try:
        items = mission.download_mission()
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc
    return MissionResponse(count=len(items), items=items)


@router.post(
    "",
    response_model=MissionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload mission to vehicle",
)
async def upload_mission(
    body: MissionUploadRequest,
    mavlink: MAVLinkDep,
    mission: MissionDep,
) -> MissionResponse:
    """Upload a new mission to the vehicle.

    The mission must contain at least one item.  Sequence numbers (``seq``)
    must start at 0 and be contiguous; if they are not the server will
    re-assign them automatically.
    """
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )

    # Normalise sequence numbers
    for idx, item in enumerate(body.items):
        item.seq = idx

    try:
        mission.upload_mission(body.items)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc
    return MissionResponse(count=len(body.items), items=body.items)


@router.delete(
    "",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Clear mission on vehicle",
)
async def clear_mission(
    mavlink: MAVLinkDep,
    mission: MissionDep,
) -> Response:
    """Remove all mission items from the vehicle."""
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    try:
        mission.clear_mission()
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get(
    "/current",
    response_model=MissionCurrentResponse,
    summary="Get active waypoint index",
)
async def get_current_waypoint(mission: MissionDep) -> MissionCurrentResponse:
    """Return the index of the currently active waypoint (-1 if none)."""
    return MissionCurrentResponse(seq=mission.get_current_waypoint())


@router.post(
    "/current",
    response_model=MissionCurrentResponse,
    summary="Jump to a mission waypoint",
)
async def set_current_waypoint(
    body: SetCurrentWaypointRequest,
    mavlink: MAVLinkDep,
    mission: MissionDep,
) -> MissionCurrentResponse:
    """Set the active waypoint in an ongoing AUTO mission."""
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )
    try:
        mission.set_current_waypoint(body.seq)
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=str(exc),
        ) from exc
    return MissionCurrentResponse(seq=body.seq)
