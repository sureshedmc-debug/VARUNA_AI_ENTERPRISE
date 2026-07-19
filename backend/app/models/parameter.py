"""Parameter data models.

ArduPilot exposes hundreds of configuration parameters accessible via
MAVLink PARAM_REQUEST_LIST / PARAM_SET messages.
"""

from __future__ import annotations

from enum import IntEnum
from typing import Union

from pydantic import BaseModel, Field


class MavParamType(IntEnum):
    """MAV_PARAM_TYPE enum."""

    UINT8 = 1
    INT8 = 2
    UINT16 = 3
    INT16 = 4
    UINT32 = 5
    INT32 = 6
    UINT64 = 7
    INT64 = 8
    REAL32 = 9
    REAL64 = 10


class Parameter(BaseModel):
    """A single ArduPilot parameter."""

    name: str = Field(..., description="Parameter identifier (max 16 chars)")
    value: float = Field(..., description="Current parameter value")
    param_type: int = Field(
        MavParamType.REAL32,
        description="MAV_PARAM_TYPE of this parameter",
    )
    index: int = Field(-1, description="Parameter index in vehicle list, -1 unknown")


class ParameterSetRequest(BaseModel):
    """Payload for PUT /api/v1/parameters/{name}."""

    value: float = Field(..., description="New parameter value")


class ParameterListResponse(BaseModel):
    """Response for GET /api/v1/parameters."""

    count: int = Field(0, description="Total number of parameters")
    parameters: list[Parameter] = Field(default_factory=list)
