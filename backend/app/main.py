"""VARUNA AI Enterprise – FastAPI application factory.

This module creates and configures the FastAPI application instance.
The ``lifespan`` context manager handles startup/shutdown of the
MAVLink connection, manager singletons and the WebSocket broadcaster.
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import AsyncIterator

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.managers.mavlink_manager import MAVLinkManager
from app.managers.mission_manager import MissionManager
from app.managers.parameter_manager import ParameterManager
from app.routers import command, health, mission, parameter, telemetry
from app.websocket.manager import WebSocketManager

logging.basicConfig(
    level=logging.DEBUG if settings.debug else logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Application lifespan: start managers on startup, stop on shutdown."""
    logger.info("Starting %s v%s", settings.app_name, settings.app_version)

    # Initialise singletons and attach to app.state for dependency injection
    mavlink = MAVLinkManager()
    mission_mgr = MissionManager(mavlink)
    parameter_mgr = ParameterManager(mavlink)
    ws_mgr = WebSocketManager()

    app.state.mavlink = mavlink
    app.state.mission_manager = mission_mgr
    app.state.parameter_manager = parameter_mgr
    app.state.ws_manager = ws_mgr

    # Start MAVLink background threads
    mavlink.start()

    # Start WebSocket telemetry broadcaster
    ws_mgr.start_broadcaster(mavlink)

    logger.info("All managers started – API ready")
    yield

    # Graceful shutdown
    logger.info("Shutting down …")
    ws_mgr.stop_broadcaster()
    mavlink.stop()
    logger.info("Shutdown complete")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        description=(
            "Production-ready FastAPI backend for autonomous drone operations. "
            "Designed for Raspberry Pi 3A+ + Pixhawk 2.4.8 + ArduPilot 4.6.x."
        ),
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    # CORS – allow all origins for companion-computer / GCS use-case
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Routers
    app.include_router(health.router)
    app.include_router(telemetry.router)
    app.include_router(mission.router)
    app.include_router(parameter.router)
    app.include_router(command.router)

    return app


# Module-level app instance used by uvicorn
app = create_app()
