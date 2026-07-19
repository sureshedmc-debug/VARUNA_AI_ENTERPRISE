"""Command request/response models.

Covers the most common in-flight and pre-flight commands supported by
ArduPilot 4.6.x via MAVLink COMMAND_LONG / COMMAND_INT.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class ArmRequest(BaseModel):
    """Optional body for POST /api/v1/command/arm."""

    force: bool = Field(
        False,
        description="Force-arm even if pre-arm checks fail (use with caution)",
    )


class ModeRequest(BaseModel):
    """Payload for POST /api/v1/command/mode."""

    mode: str = Field(
        ...,
        description=(
            "ArduPilot flight mode name, e.g. STABILIZE, ALT_HOLD, LOITER, "
            "AUTO, GUIDED, LAND, RTL, POSHOLD, DRIFT, ACRO, FLIP"
        ),
    )


class TakeoffRequest(BaseModel):
    """Payload for POST /api/v1/command/takeoff."""

    altitude: float = Field(
        ...,
        gt=0,
        le=500,
        description="Target altitude above home in metres",
    )


class CommandResponse(BaseModel):
    """Generic response for fire-and-wait command endpoints."""

    success: bool
    result: int = Field(0, description="MAV_RESULT enum value returned by vehicle")
    message: str = ""
