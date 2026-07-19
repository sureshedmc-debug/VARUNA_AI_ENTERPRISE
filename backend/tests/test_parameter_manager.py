"""Tests for ParameterManager.

All tests use a mocked MAVLink connection.
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest

from app.managers.mavlink_manager import MAVLinkManager
from app.managers.parameter_manager import ParameterManager
from app.models.parameter import MavParamType, Parameter


def make_param_value_msg(name: str, value: float, index: int = 0, count: int = 2) -> MagicMock:
    msg = MagicMock()
    msg.param_id = name.ljust(16, "\x00")
    msg.param_value = value
    msg.param_type = MavParamType.REAL32
    msg.param_index = index
    msg.param_count = count
    return msg


class TestParameterManager:
    def test_get_cached_parameters_empty(
        self, parameter_manager: ParameterManager
    ) -> None:
        assert parameter_manager.get_cached_parameters() == []

    def test_on_param_value_populates_cache(
        self, parameter_manager: ParameterManager
    ) -> None:
        msg = make_param_value_msg("ARMING_CHECK", 1.0, 0, 10)
        parameter_manager._on_param_value(msg)

        cached = parameter_manager.get_cached_parameters()
        assert len(cached) == 1
        assert cached[0].name == "ARMING_CHECK"
        assert cached[0].value == pytest.approx(1.0)

    def test_on_param_value_updates_existing(
        self, parameter_manager: ParameterManager
    ) -> None:
        msg1 = make_param_value_msg("ARMING_CHECK", 1.0, 0, 10)
        msg2 = make_param_value_msg("ARMING_CHECK", 0.0, 0, 10)
        parameter_manager._on_param_value(msg1)
        parameter_manager._on_param_value(msg2)
        cached = parameter_manager.get_cached_parameters()
        assert len(cached) == 1
        assert cached[0].value == pytest.approx(0.0)

    def test_get_parameter_from_cache(
        self, parameter_manager: ParameterManager
    ) -> None:
        msg = make_param_value_msg("FS_THR_ENABLE", 1.0, 1, 10)
        parameter_manager._on_param_value(msg)
        result = parameter_manager.get_parameter("FS_THR_ENABLE")
        assert result is not None
        assert result.name == "FS_THR_ENABLE"

    def test_get_parameter_live_request(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        expected = make_param_value_msg("PILOT_ACCEL_Z", 250.0, 42, 100)

        def mock_wait(msg_type: str, timeout: float = 5.0, condition=None) -> MagicMock:
            return expected

        mavlink_manager.wait_for_message = mock_wait
        result = parameter_manager.get_parameter("PILOT_ACCEL_Z")
        assert result is not None
        assert result.value == pytest.approx(250.0)

    def test_get_parameter_not_found_returns_none(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        mavlink_manager.wait_for_message = MagicMock(return_value=None)
        result = parameter_manager.get_parameter("NONEXISTENT")
        assert result is None

    def test_set_parameter_success(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        ack_msg = make_param_value_msg("ARMING_CHECK", 0.0, 0, 10)

        def mock_wait(msg_type: str, timeout: float = 5.0, condition=None) -> MagicMock:
            return ack_msg

        mavlink_manager.wait_for_message = mock_wait
        result = parameter_manager.set_parameter("ARMING_CHECK", 0.0)
        assert result is not None
        assert result.value == pytest.approx(0.0)

    def test_set_parameter_no_ack(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        mavlink_manager.wait_for_message = MagicMock(return_value=None)
        result = parameter_manager.set_parameter("ARMING_CHECK", 1.0)
        assert result is None

    def test_set_parameter_disconnected(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        mavlink_manager.state.update(connected=False)
        with pytest.raises(RuntimeError, match="Not connected"):
            parameter_manager.set_parameter("ARMING_CHECK", 1.0)

    def test_fetch_all_disconnected(
        self, mavlink_manager: MAVLinkManager, parameter_manager: ParameterManager
    ) -> None:
        mavlink_manager.state.update(connected=False)
        with pytest.raises(RuntimeError, match="Not connected"):
            parameter_manager.fetch_all()

    def test_clear_cache(self, parameter_manager: ParameterManager) -> None:
        msg = make_param_value_msg("ARMING_CHECK", 1.0, 0, 10)
        parameter_manager._on_param_value(msg)
        assert len(parameter_manager.get_cached_parameters()) == 1
        parameter_manager.clear_cache()
        assert parameter_manager.get_cached_parameters() == []

    def test_multiple_parameters_sorted_by_index(
        self, parameter_manager: ParameterManager
    ) -> None:
        for i, name in enumerate(["BETA", "ALPHA", "GAMMA"]):
            msg = make_param_value_msg(name, float(i), i, 3)
            parameter_manager._on_param_value(msg)
        cached = parameter_manager.get_cached_parameters()
        assert [p.index for p in cached] == [0, 1, 2]
