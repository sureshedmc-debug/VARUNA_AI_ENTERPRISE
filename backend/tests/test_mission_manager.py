"""Tests for MissionManager.

All tests mock the underlying MAVLink connection so no hardware is needed.
"""

from __future__ import annotations

import threading
from typing import Any
from unittest.mock import MagicMock, patch

import pymavlink.mavutil as mavutil
import pytest

from app.managers.mavlink_manager import MAVLinkManager
from app.managers.mission_manager import MissionManager
from app.models.mission import MissionItem


def make_mission_items(count: int = 3) -> list[MissionItem]:
    items = []
    for i in range(count):
        items.append(
            MissionItem(
                seq=i,
                frame=3,
                command=16 if i > 0 else 22,
                current=1 if i == 0 else 0,
                autocontinue=1,
                param1=0,
                param2=5,
                param3=0,
                param4=0,
                lat=12.9716 + i * 0.001,
                lon=77.5946 + i * 0.001,
                alt=20.0 + i * 10,
                mission_type=0,
            )
        )
    return items


def make_mission_item_int_msg(item: MissionItem) -> MagicMock:
    msg = MagicMock()
    msg.get_type.return_value = "MISSION_ITEM_INT"
    msg.seq = item.seq
    msg.frame = item.frame
    msg.command = item.command
    msg.current = item.current
    msg.autocontinue = item.autocontinue
    msg.param1 = item.param1
    msg.param2 = item.param2
    msg.param3 = item.param3
    msg.param4 = item.param4
    msg.x = int(item.lat * 1e7)
    msg.y = int(item.lon * 1e7)
    msg.z = item.alt
    msg.mission_type = item.mission_type
    return msg


class TestMissionManager:
    def test_upload_mission_success(self, mavlink_manager: MAVLinkManager) -> None:
        items = make_mission_items(2)
        mgr = MissionManager(mavlink_manager)

        call_seq = [0]

        def mock_wait_for(msg_type: str, timeout: float = 5.0, condition: Any = None) -> Any:
            if msg_type == "MISSION_REQUEST_INT":
                req = MagicMock()
                req.seq = call_seq[0]
                req.target_system = 255
                call_seq[0] += 1
                return req
            if msg_type == "MISSION_ACK":
                ack = MagicMock()
                ack.type = mavutil.mavlink.MAV_MISSION_ACCEPTED
                return ack
            return None

        mavlink_manager.wait_for_message = mock_wait_for
        result = mgr.upload_mission(items)
        assert result is True

    def test_upload_mission_ack_rejected(self, mavlink_manager: MAVLinkManager) -> None:
        items = make_mission_items(1)
        mgr = MissionManager(mavlink_manager)

        call_seq = [0]

        def mock_wait_for(msg_type: str, timeout: float = 5.0, condition: Any = None) -> Any:
            if msg_type == "MISSION_REQUEST_INT":
                req = MagicMock()
                req.seq = call_seq[0]
                req.target_system = 255
                call_seq[0] += 1
                return req
            if msg_type == "MISSION_ACK":
                ack = MagicMock()
                ack.type = mavutil.mavlink.MAV_MISSION_ERROR
                return ack
            return None

        mavlink_manager.wait_for_message = mock_wait_for
        with pytest.raises(RuntimeError, match="rejected"):
            mgr.upload_mission(items)

    def test_upload_mission_no_request(self, mavlink_manager: MAVLinkManager) -> None:
        items = make_mission_items(1)
        mgr = MissionManager(mavlink_manager)
        mavlink_manager.wait_for_message = MagicMock(return_value=None)
        with pytest.raises(RuntimeError):
            mgr.upload_mission(items)

    def test_upload_mission_disconnected(self, mavlink_manager: MAVLinkManager) -> None:
        mavlink_manager.state.update(connected=False)
        mgr = MissionManager(mavlink_manager)
        with pytest.raises(RuntimeError, match="Not connected"):
            mgr.upload_mission(make_mission_items(1))

    def test_download_mission_empty(self, mavlink_manager: MAVLinkManager) -> None:
        mgr = MissionManager(mavlink_manager)

        def mock_wait(msg_type: str, timeout: float = 5.0, condition: Any = None) -> Any:
            if msg_type == "MISSION_COUNT":
                m = MagicMock()
                m.count = 0
                return m
            return None

        mavlink_manager.wait_for_message = mock_wait
        result = mgr.download_mission()
        assert result == []

    def test_download_mission_items(self, mavlink_manager: MAVLinkManager) -> None:
        items_to_send = make_mission_items(2)
        mgr = MissionManager(mavlink_manager)
        item_calls = [0]

        def mock_wait(msg_type: str, timeout: float = 5.0, condition: Any = None) -> Any:
            if msg_type == "MISSION_COUNT":
                m = MagicMock()
                m.count = len(items_to_send)
                return m
            if msg_type == "MISSION_ITEM_INT":
                idx = item_calls[0]
                item_calls[0] += 1
                return make_mission_item_int_msg(items_to_send[idx])
            return None

        mavlink_manager.wait_for_message = mock_wait
        result = mgr.download_mission()
        assert len(result) == 2
        assert result[0].seq == 0
        assert result[1].seq == 1

    def test_clear_mission_success(self, mavlink_manager: MAVLinkManager) -> None:
        mgr = MissionManager(mavlink_manager)

        def mock_wait(msg_type: str, timeout: float = 5.0, condition: Any = None) -> Any:
            ack = MagicMock()
            ack.type = mavutil.mavlink.MAV_MISSION_ACCEPTED
            return ack

        mavlink_manager.wait_for_message = mock_wait
        assert mgr.clear_mission() is True

    def test_clear_mission_no_ack(self, mavlink_manager: MAVLinkManager) -> None:
        mgr = MissionManager(mavlink_manager)
        mavlink_manager.wait_for_message = MagicMock(return_value=None)
        with pytest.raises(RuntimeError, match="No MISSION_ACK"):
            mgr.clear_mission()

    def test_set_current_waypoint(self, mavlink_manager: MAVLinkManager) -> None:
        mgr = MissionManager(mavlink_manager)
        assert mgr.set_current_waypoint(3) is True

    def test_get_current_waypoint_default(self, mavlink_manager: MAVLinkManager) -> None:
        mgr = MissionManager(mavlink_manager)
        assert mgr.get_current_waypoint() == -1

    def test_mission_current_callback_updates_seq(
        self, mavlink_manager: MAVLinkManager
    ) -> None:
        mgr = MissionManager(mavlink_manager)
        msg = MagicMock()
        msg.seq = 5
        mgr._on_mission_current(msg)
        assert mgr.get_current_waypoint() == 5
