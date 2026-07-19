"""Command router.

POST /api/v1/command/arm       – Arm the vehicle
POST /api/v1/command/disarm    – Disarm the vehicle
POST /api/v1/command/mode      – Change flight mode
POST /api/v1/command/takeoff   – Guided takeoff
POST /api/v1/command/land      – Initiate landing
POST /api/v1/command/rtl       – Return to launch
"""

from __future__ import annotations

import logging

import pymavlink.mavutil as mavutil
from fastapi import APIRouter, HTTPException, status

from app.dependencies import MAVLinkDep
from app.models.command import (
    ArmRequest,
    CommandResponse,
    ModeRequest,
    TakeoffRequest,
)

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/command", tags=["Commands"])

# MAV_RESULT enum values
_MAV_RESULT_ACCEPTED = 0
_MAV_RESULT_DENIED = 2


def _require_connection(mavlink: MAVLinkDep) -> None:
    if not mavlink.is_connected:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Not connected to vehicle",
        )


@router.post("/arm", response_model=CommandResponse, summary="Arm vehicle")
async def arm(body: ArmRequest, mavlink: MAVLinkDep) -> CommandResponse:
    """Arm the vehicle motors.

    Set ``force=true`` to bypass pre-arm checks (for ground testing only).
    """
    _require_connection(mavlink)
    force_param = 21196.0 if body.force else 0.0
    ack = mavlink.send_command_long_and_wait(
        mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM,
        param1=1.0,
        param2=force_param,
    )
    if ack is None:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="No COMMAND_ACK received",
        )
    result: int = ack.result
    return CommandResponse(
        success=result == _MAV_RESULT_ACCEPTED,
        result=result,
        message="Armed" if result == _MAV_RESULT_ACCEPTED else f"Denied (result={result})",
    )


@router.post("/disarm", response_model=CommandResponse, summary="Disarm vehicle")
async def disarm(mavlink: MAVLinkDep) -> CommandResponse:
    """Disarm the vehicle motors."""
    _require_connection(mavlink)
    ack = mavlink.send_command_long_and_wait(
        mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM,
        param1=0.0,
    )
    if ack is None:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="No COMMAND_ACK received",
        )
    result = ack.result
    return CommandResponse(
        success=result == _MAV_RESULT_ACCEPTED,
        result=result,
        message="Disarmed" if result == _MAV_RESULT_ACCEPTED else f"Denied (result={result})",
    )


@router.post("/mode", response_model=CommandResponse, summary="Change flight mode")
async def change_mode(body: ModeRequest, mavlink: MAVLinkDep) -> CommandResponse:
    """Change the ArduPilot flight mode.

    Common modes: ``STABILIZE``, ``ALT_HOLD``, ``LOITER``, ``AUTO``,
    ``GUIDED``, ``RTL``, ``LAND``, ``POSHOLD``.
    """
    _require_connection(mavlink)
    success = mavlink.set_mode(body.mode)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown or unsupported mode: {body.mode}",
        )
    return CommandResponse(success=True, result=0, message=f"Mode set to {body.mode}")


@router.post("/takeoff", response_model=CommandResponse, summary="Guided takeoff")
async def takeoff(body: TakeoffRequest, mavlink: MAVLinkDep) -> CommandResponse:
    """Command a guided takeoff to *altitude* metres above the home position.

    The vehicle must be armed and in GUIDED mode before issuing this command.
    """
    _require_connection(mavlink)
    ack = mavlink.send_command_long_and_wait(
        mavutil.mavlink.MAV_CMD_NAV_TAKEOFF,
        param7=body.altitude,
    )
    if ack is None:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="No COMMAND_ACK received",
        )
    result = ack.result
    return CommandResponse(
        success=result == _MAV_RESULT_ACCEPTED,
        result=result,
        message=(
            f"Takeoff to {body.altitude} m"
            if result == _MAV_RESULT_ACCEPTED
            else f"Takeoff denied (result={result})"
        ),
    )


@router.post("/land", response_model=CommandResponse, summary="Initiate landing")
async def land(mavlink: MAVLinkDep) -> CommandResponse:
    """Command the vehicle to land at the current position."""
    _require_connection(mavlink)
    ack = mavlink.send_command_long_and_wait(
        mavutil.mavlink.MAV_CMD_NAV_LAND,
    )
    if ack is None:
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail="No COMMAND_ACK received",
        )
    result = ack.result
    return CommandResponse(
        success=result == _MAV_RESULT_ACCEPTED,
        result=result,
        message="Landing" if result == _MAV_RESULT_ACCEPTED else f"Land denied (result={result})",
    )


@router.post("/rtl", response_model=CommandResponse, summary="Return to launch")
async def rtl(mavlink: MAVLinkDep) -> CommandResponse:
    """Command the vehicle to return to and land at its home position."""
    _require_connection(mavlink)
    success = mavlink.set_mode("RTL")
    if not success:
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="Failed to set RTL mode",
        )
    return CommandResponse(success=True, result=0, message="RTL mode activated")
