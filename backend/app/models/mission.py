"""Mission data models.

Represents ArduPilot mission items compatible with the MAVLink MISSION_ITEM_INT
protocol used by Pixhawk 2.4.8 running ArduPilot 4.6.x.
"""

from __future__ import annotations

from enum import IntEnum
from typing import Optional

from pydantic import BaseModel, Field


class MavFrame(IntEnum):
    """MAV_FRAME enum subset – most commonly used frames."""

    GLOBAL = 0          # WGS84 absolute altitude
    GLOBAL_RELATIVE = 3  # WGS84, altitude relative to home


class MavCmd(IntEnum):
    """MAV_CMD subset used for mission items."""

    NAV_WAYPOINT = 16
    NAV_LOITER_UNLIM = 17
    NAV_LOITER_TURNS = 18
    NAV_LOITER_TIME = 19
    NAV_RETURN_TO_LAUNCH = 20
    NAV_LAND = 21
    NAV_TAKEOFF = 22
    DO_SET_ROI = 201
    DO_CHANGE_SPEED = 178
    DO_SET_HOME = 179
    CONDITION_DELAY = 112
    CONDITION_DISTANCE = 114


class MissionItem(BaseModel):
    """A single waypoint / command in a mission."""

    seq: int = Field(..., ge=0, description="Waypoint sequence number")
    frame: int = Field(
        MavFrame.GLOBAL_RELATIVE,
        description="MAV_FRAME coordinate frame",
    )
    command: int = Field(
        MavCmd.NAV_WAYPOINT,
        description="MAV_CMD mission command",
    )
    current: int = Field(0, description="1 if this is the current waypoint")
    autocontinue: int = Field(1, description="Autocontinue to next waypoint")
    param1: float = Field(0.0, description="Hold time (s) / acceptance radius")
    param2: float = Field(0.0, description="Acceptance radius (m)")
    param3: float = Field(0.0, description="Pass-through / loiter radius")
    param4: float = Field(float("nan"), description="Yaw angle (NaN = auto)")
    lat: float = Field(0.0, description="Latitude in degrees")
    lon: float = Field(0.0, description="Longitude in degrees")
    alt: float = Field(0.0, description="Altitude in metres (relative to home)")
    mission_type: int = Field(0, description="MAV_MISSION_TYPE (0=main mission)")


class MissionUploadRequest(BaseModel):
    """Payload for POST /api/v1/mission."""

    items: list[MissionItem] = Field(
        ...,
        min_length=1,
        description="Ordered list of mission items",
    )


class MissionResponse(BaseModel):
    """Response for mission read / upload operations."""

    count: int = Field(0, description="Number of mission items")
    items: list[MissionItem] = Field(default_factory=list)


class MissionCurrentResponse(BaseModel):
    """Current active waypoint information."""

    seq: int = Field(-1, description="Active waypoint sequence number, -1 if none")


class SetCurrentWaypointRequest(BaseModel):
    """Payload for POST /api/v1/mission/current."""

    seq: int = Field(..., ge=0, description="Target waypoint sequence number")
