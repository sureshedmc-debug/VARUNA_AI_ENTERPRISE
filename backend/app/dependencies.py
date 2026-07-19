"""FastAPI dependency providers.

Centralises access to the singleton manager instances so that routers
can declare them as FastAPI ``Depends`` injections.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Annotated

from fastapi import Depends, Request

from app.managers.mavlink_manager import MAVLinkManager
from app.managers.mission_manager import MissionManager
from app.managers.parameter_manager import ParameterManager
from app.websocket.manager import WebSocketManager


def get_mavlink(request: Request) -> MAVLinkManager:
    return request.app.state.mavlink  # type: ignore[attr-defined]


def get_mission_manager(request: Request) -> MissionManager:
    return request.app.state.mission_manager  # type: ignore[attr-defined]


def get_parameter_manager(request: Request) -> ParameterManager:
    return request.app.state.parameter_manager  # type: ignore[attr-defined]


def get_ws_manager(request: Request) -> WebSocketManager:
    return request.app.state.ws_manager  # type: ignore[attr-defined]


MAVLinkDep = Annotated[MAVLinkManager, Depends(get_mavlink)]
MissionDep = Annotated[MissionManager, Depends(get_mission_manager)]
ParameterDep = Annotated[ParameterManager, Depends(get_parameter_manager)]
WebSocketDep = Annotated[WebSocketManager, Depends(get_ws_manager)]
