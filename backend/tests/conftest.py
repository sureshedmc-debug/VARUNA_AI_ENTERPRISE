"""Shared pytest fixtures for VARUNA AI Enterprise backend tests.

All fixtures use a mocked MAVLinkManager so tests can run without a
physical Pixhawk or serial port.
"""

from __future__ import annotations

import threading
from typing import Any
from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

from app.managers.mavlink_manager import MAVLinkManager, TelemetryState
from app.managers.mission_manager import MissionManager
from app.managers.parameter_manager import ParameterManager
from app.websocket.manager import WebSocketManager


# ---------------------------------------------------------------------------
# Mock MAVLink connection helpers
# ---------------------------------------------------------------------------

def make_mock_mav() -> MagicMock:
    """Return a mock pymavlink mavfile that behaves like a connected vehicle."""
    mav_proto = MagicMock()
    conn = MagicMock()
    conn.mav = mav_proto
    conn.target_system = 1
    conn.target_component = 1
    return conn


def make_connected_mavlink_manager() -> MAVLinkManager:
    """Return a MAVLinkManager that is pre-configured as connected with
    a mock underlying connection.

    The reader and heartbeat threads are NOT started to keep tests fast.
    """
    manager = MAVLinkManager()
    mock_conn = make_mock_mav()
    manager._connection = mock_conn
    manager.state.update(
        connected=True,
        mode="STABILIZE",
        armed=False,
        vehicle_type=2,  # MAV_TYPE_QUADROTOR
        autopilot_type=3,  # MAV_AUTOPILOT_ARDUPILOTMEGA
        battery_voltage=12.6,
        battery_current=1.0,
        battery_remaining=95,
        fix_type=3,
        satellites_visible=12,
        hdop=0.9,
        lat=12.9716,
        lon=77.5946,
        alt_msl=920.0,
        alt_rel=0.0,
        roll=0.0,
        pitch=0.0,
        yaw=45.0,
        heading=45.0,
        groundspeed=0.0,
        airspeed=0.0,
    )
    return manager


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture()
def mavlink_manager() -> MAVLinkManager:
    return make_connected_mavlink_manager()


@pytest.fixture()
def mission_manager(mavlink_manager: MAVLinkManager) -> MissionManager:
    return MissionManager(mavlink_manager)


@pytest.fixture()
def parameter_manager(mavlink_manager: MAVLinkManager) -> ParameterManager:
    return ParameterManager(mavlink_manager)


@pytest.fixture()
def ws_manager() -> WebSocketManager:
    return WebSocketManager()


@pytest.fixture()
def client(mavlink_manager: MAVLinkManager) -> TestClient:
    """TestClient with mocked managers injected via app.state."""
    from app.main import create_app

    test_app = create_app()

    # Pre-populate app.state so lifespan is bypassed in tests
    mission_mgr = MissionManager(mavlink_manager)
    parameter_mgr = ParameterManager(mavlink_manager)
    ws_mgr = WebSocketManager()

    test_app.state.mavlink = mavlink_manager
    test_app.state.mission_manager = mission_mgr
    test_app.state.parameter_manager = parameter_mgr
    test_app.state.ws_manager = ws_mgr

    return TestClient(test_app, raise_server_exceptions=True)
