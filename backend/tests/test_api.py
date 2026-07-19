"""Integration tests for REST API endpoints.

These tests use the FastAPI TestClient with mocked managers so no physical
hardware is required.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient

from app.models.mission import MissionItem
from app.models.parameter import Parameter


class TestHealthEndpoint:
    def test_health_returns_200(self, client: TestClient) -> None:
        resp = client.get("/api/v1/health")
        assert resp.status_code == 200

    def test_health_connected(self, client: TestClient) -> None:
        data = resp = client.get("/api/v1/health").json()
        assert data["mavlink_connected"] is True
        assert data["status"] == "ok"

    def test_health_includes_version(self, client: TestClient) -> None:
        data = client.get("/api/v1/health").json()
        assert "app_version" in data
        assert "app_name" in data

    def test_health_includes_mode(self, client: TestClient) -> None:
        data = client.get("/api/v1/health").json()
        assert data["vehicle_mode"] == "STABILIZE"


class TestTelemetryEndpoint:
    def test_telemetry_returns_200(self, client: TestClient) -> None:
        resp = client.get("/api/v1/telemetry")
        assert resp.status_code == 200

    def test_telemetry_fields_present(self, client: TestClient) -> None:
        data = client.get("/api/v1/telemetry").json()
        assert "attitude" in data
        assert "position" in data
        assert "velocity" in data
        assert "gps" in data
        assert "battery" in data
        assert "connected" in data

    def test_telemetry_connected_true(self, client: TestClient) -> None:
        data = client.get("/api/v1/telemetry").json()
        assert data["connected"] is True

    def test_telemetry_battery_voltage(self, client: TestClient) -> None:
        data = client.get("/api/v1/telemetry").json()
        assert data["battery"]["voltage"] == pytest.approx(12.6)

    def test_telemetry_gps_fix(self, client: TestClient) -> None:
        data = client.get("/api/v1/telemetry").json()
        assert data["gps"]["fix_type"] == 3
        assert data["gps"]["satellites_visible"] == 12

    def test_telemetry_position(self, client: TestClient) -> None:
        data = client.get("/api/v1/telemetry").json()
        assert data["position"]["lat"] == pytest.approx(12.9716)
        assert data["position"]["lon"] == pytest.approx(77.5946)


class TestMissionEndpoint:
    def test_get_mission_disconnected_returns_503(self, client: TestClient) -> None:
        client.app.state.mavlink.state.update(connected=False)
        resp = client.get("/api/v1/mission")
        assert resp.status_code == 503
        # Restore
        client.app.state.mavlink.state.update(connected=True)

    def test_get_mission_connected(self, client: TestClient) -> None:
        mission_mgr = client.app.state.mission_manager
        mission_mgr.download_mission = MagicMock(return_value=[])
        resp = client.get("/api/v1/mission")
        assert resp.status_code == 200
        assert resp.json()["count"] == 0

    def test_post_mission_uploads(self, client: TestClient) -> None:
        mission_mgr = client.app.state.mission_manager
        mission_mgr.upload_mission = MagicMock(return_value=True)

        payload = {
            "items": [
                {
                    "seq": 0,
                    "frame": 3,
                    "command": 22,  # NAV_TAKEOFF
                    "current": 0,
                    "autocontinue": 1,
                    "param1": 0,
                    "param2": 0,
                    "param3": 0,
                    "param4": 0,
                    "lat": 12.9716,
                    "lon": 77.5946,
                    "alt": 20.0,
                    "mission_type": 0,
                },
                {
                    "seq": 1,
                    "frame": 3,
                    "command": 16,  # NAV_WAYPOINT
                    "current": 0,
                    "autocontinue": 1,
                    "param1": 0,
                    "param2": 5,
                    "param3": 0,
                    "param4": 0,
                    "lat": 12.9800,
                    "lon": 77.6000,
                    "alt": 30.0,
                    "mission_type": 0,
                },
            ]
        }
        resp = client.post("/api/v1/mission", json=payload)
        assert resp.status_code == 201
        assert resp.json()["count"] == 2

    def test_delete_mission(self, client: TestClient) -> None:
        mission_mgr = client.app.state.mission_manager
        mission_mgr.clear_mission = MagicMock(return_value=True)
        resp = client.delete("/api/v1/mission")
        assert resp.status_code == 204

    def test_get_current_waypoint(self, client: TestClient) -> None:
        resp = client.get("/api/v1/mission/current")
        assert resp.status_code == 200
        assert "seq" in resp.json()

    def test_set_current_waypoint(self, client: TestClient) -> None:
        mission_mgr = client.app.state.mission_manager
        mission_mgr.set_current_waypoint = MagicMock(return_value=True)
        resp = client.post("/api/v1/mission/current", json={"seq": 2})
        assert resp.status_code == 200
        assert resp.json()["seq"] == 2


class TestParameterEndpoint:
    def test_get_parameters_returns_list(self, client: TestClient) -> None:
        param_mgr = client.app.state.parameter_manager
        param_mgr.get_cached_parameters = MagicMock(
            return_value=[
                Parameter(name="ARMING_CHECK", value=1.0, param_type=9, index=0),
                Parameter(name="FS_THR_ENABLE", value=1.0, param_type=9, index=1),
            ]
        )
        resp = client.get("/api/v1/parameters")
        assert resp.status_code == 200
        data = resp.json()
        assert data["count"] == 2
        assert data["parameters"][0]["name"] == "ARMING_CHECK"

    def test_get_single_parameter(self, client: TestClient) -> None:
        param_mgr = client.app.state.parameter_manager
        param_mgr.get_parameter = MagicMock(
            return_value=Parameter(name="ARMING_CHECK", value=1.0, param_type=9, index=0)
        )
        resp = client.get("/api/v1/parameters/ARMING_CHECK")
        assert resp.status_code == 200
        assert resp.json()["name"] == "ARMING_CHECK"

    def test_get_missing_parameter_returns_404(self, client: TestClient) -> None:
        param_mgr = client.app.state.parameter_manager
        param_mgr.get_parameter = MagicMock(return_value=None)
        resp = client.get("/api/v1/parameters/NONEXISTENT")
        assert resp.status_code == 404

    def test_set_parameter(self, client: TestClient) -> None:
        param_mgr = client.app.state.parameter_manager
        param_mgr.set_parameter = MagicMock(
            return_value=Parameter(name="FS_THR_ENABLE", value=2.0, param_type=9, index=1)
        )
        resp = client.put("/api/v1/parameters/FS_THR_ENABLE", json={"value": 2.0})
        assert resp.status_code == 200
        assert resp.json()["value"] == pytest.approx(2.0)


class TestCommandEndpoint:
    def _mock_ack(self, result: int = 0) -> MagicMock:
        ack = MagicMock()
        ack.result = result
        return ack

    def test_arm_success(self, client: TestClient) -> None:
        client.app.state.mavlink.send_command_long_and_wait = MagicMock(
            return_value=self._mock_ack(0)
        )
        resp = client.post("/api/v1/command/arm", json={})
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    def test_arm_force(self, client: TestClient) -> None:
        mavlink = client.app.state.mavlink
        mavlink.send_command_long_and_wait = MagicMock(return_value=self._mock_ack(0))
        resp = client.post("/api/v1/command/arm", json={"force": True})
        assert resp.status_code == 200
        call_kwargs = mavlink.send_command_long_and_wait.call_args
        assert call_kwargs.kwargs.get("param2") == 21196.0

    def test_disarm_success(self, client: TestClient) -> None:
        client.app.state.mavlink.send_command_long_and_wait = MagicMock(
            return_value=self._mock_ack(0)
        )
        resp = client.post("/api/v1/command/disarm")
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    def test_change_mode(self, client: TestClient) -> None:
        client.app.state.mavlink.set_mode = MagicMock(return_value=True)
        resp = client.post("/api/v1/command/mode", json={"mode": "LOITER"})
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    def test_change_mode_unknown(self, client: TestClient) -> None:
        client.app.state.mavlink.set_mode = MagicMock(return_value=False)
        resp = client.post("/api/v1/command/mode", json={"mode": "INVALID_MODE"})
        assert resp.status_code == 400

    def test_takeoff(self, client: TestClient) -> None:
        client.app.state.mavlink.send_command_long_and_wait = MagicMock(
            return_value=self._mock_ack(0)
        )
        resp = client.post("/api/v1/command/takeoff", json={"altitude": 10.0})
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    def test_land(self, client: TestClient) -> None:
        client.app.state.mavlink.send_command_long_and_wait = MagicMock(
            return_value=self._mock_ack(0)
        )
        resp = client.post("/api/v1/command/land")
        assert resp.status_code == 200

    def test_rtl(self, client: TestClient) -> None:
        client.app.state.mavlink.set_mode = MagicMock(return_value=True)
        resp = client.post("/api/v1/command/rtl")
        assert resp.status_code == 200
        assert resp.json()["success"] is True

    def test_command_no_ack_returns_504(self, client: TestClient) -> None:
        client.app.state.mavlink.send_command_long_and_wait = MagicMock(
            return_value=None
        )
        resp = client.post("/api/v1/command/arm", json={})
        assert resp.status_code == 504

    def test_command_disconnected_returns_503(self, client: TestClient) -> None:
        client.app.state.mavlink.state.update(connected=False)
        resp = client.post("/api/v1/command/arm", json={})
        assert resp.status_code == 503
        client.app.state.mavlink.state.update(connected=True)
