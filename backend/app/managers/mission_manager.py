"""Mission Manager.

Handles upload, download, clearing and monitoring of ArduPilot missions
via the MAVLink MISSION_ITEM_INT protocol (recommended over MISSION_ITEM
for ArduPilot 4.x).

Protocol overview (upload)
--------------------------
GCS → MISSION_COUNT
Vehicle → MISSION_REQUEST_INT(0)
GCS → MISSION_ITEM_INT(0)
Vehicle → MISSION_REQUEST_INT(1)
… repeat …
Vehicle → MISSION_ACK

Protocol overview (download)
----------------------------
GCS → MISSION_REQUEST_LIST
Vehicle → MISSION_COUNT(n)
GCS → MISSION_REQUEST_INT(0)
Vehicle → MISSION_ITEM_INT(0)
… repeat …
"""

from __future__ import annotations

import logging
import math
import time
from typing import Optional

import pymavlink.mavutil as mavutil

from app.config import settings
from app.managers.mavlink_manager import MAVLinkManager
from app.models.mission import MissionItem

logger = logging.getLogger(__name__)


class MissionManager:
    """Upload, download and manage ArduPilot missions."""

    def __init__(self, mavlink: MAVLinkManager) -> None:
        self._mav = mavlink
        self._current_seq: int = -1

        # Subscribe to MISSION_CURRENT to track active waypoint
        self._mav.subscribe("MISSION_CURRENT", self._on_mission_current)

    # ------------------------------------------------------------------
    # Event handlers
    # ------------------------------------------------------------------

    def _on_mission_current(self, msg: object) -> None:
        self._current_seq = msg.seq  # type: ignore[attr-defined]

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def get_current_waypoint(self) -> int:
        """Return the currently active waypoint index (-1 if unknown)."""
        return self._current_seq

    def upload_mission(self, items: list[MissionItem]) -> bool:
        """Upload *items* to the vehicle.  Returns True on success.

        Raises
        ------
        RuntimeError
            If not connected or if the vehicle does not ACK the mission.
        """
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        count = len(items)
        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component
        timeout = settings.mission_timeout

        logger.info("Uploading mission: %d items", count)

        # 1. Send MISSION_COUNT
        mav.mission_count_send(ts, tc, count, mavutil.mavlink.MAV_MISSION_TYPE_MISSION)

        uploaded = 0
        deadline = time.time() + timeout

        while uploaded < count:
            if time.time() > deadline:
                raise RuntimeError(f"Mission upload timed out after {timeout}s")

            req = self._mav.wait_for_message(
                "MISSION_REQUEST_INT",
                timeout=settings.mission_timeout,
                condition=lambda m: m.target_system == settings.mavlink_source_system,  # noqa: B023
            )
            if req is None:
                # Fallback: also accept MISSION_REQUEST (legacy)
                req = self._mav.wait_for_message(
                    "MISSION_REQUEST",
                    timeout=2.0,
                )
            if req is None:
                raise RuntimeError("No MISSION_REQUEST received from vehicle")

            seq = req.seq
            if seq >= count:
                raise RuntimeError(f"Vehicle requested out-of-range seq {seq}")

            item = items[seq]
            self._send_mission_item_int(mav, ts, tc, item)
            uploaded = seq + 1
            logger.debug("Sent item %d/%d", uploaded, count)

        # Wait for MISSION_ACK
        ack = self._mav.wait_for_message(
            "MISSION_ACK",
            timeout=timeout,
        )
        if ack is None:
            raise RuntimeError("No MISSION_ACK received")
        if ack.type != mavutil.mavlink.MAV_MISSION_ACCEPTED:
            raise RuntimeError(f"Mission rejected: type={ack.type}")

        logger.info("Mission uploaded successfully (%d items)", count)
        return True

    def download_mission(self) -> list[MissionItem]:
        """Download the current mission from the vehicle.

        Returns
        -------
        list[MissionItem]
            Ordered list of mission items (may be empty).
        """
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component
        timeout = settings.mission_timeout

        logger.info("Downloading mission from vehicle")

        # 1. Request mission list
        mav.mission_request_list_send(ts, tc, mavutil.mavlink.MAV_MISSION_TYPE_MISSION)

        count_msg = self._mav.wait_for_message("MISSION_COUNT", timeout=timeout)
        if count_msg is None:
            raise RuntimeError("No MISSION_COUNT received")

        count = count_msg.count
        logger.info("Vehicle reports %d mission items", count)

        if count == 0:
            return []

        items: list[MissionItem] = []
        for seq in range(count):
            # Request each item (prefer MISSION_REQUEST_INT for ArduPilot 4.x)
            mav.mission_request_int_send(ts, tc, seq, mavutil.mavlink.MAV_MISSION_TYPE_MISSION)

            msg = self._mav.wait_for_message(
                "MISSION_ITEM_INT",
                timeout=timeout,
                condition=lambda m, s=seq: m.seq == s,
            )
            if msg is None:
                raise RuntimeError(f"Timeout waiting for MISSION_ITEM_INT seq={seq}")

            items.append(self._msg_to_mission_item(msg))
            logger.debug("Received item %d/%d", seq + 1, count)

        # Send ACK
        mav.mission_ack_send(ts, tc, mavutil.mavlink.MAV_MISSION_ACCEPTED,
                             mavutil.mavlink.MAV_MISSION_TYPE_MISSION)
        logger.info("Mission download complete (%d items)", len(items))
        return items

    def clear_mission(self) -> bool:
        """Clear the entire mission on the vehicle."""
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component

        mav.mission_clear_all_send(ts, tc, mavutil.mavlink.MAV_MISSION_TYPE_MISSION)

        ack = self._mav.wait_for_message("MISSION_ACK", timeout=settings.mission_timeout)
        if ack is None:
            raise RuntimeError("No MISSION_ACK after clear")

        if ack.type != mavutil.mavlink.MAV_MISSION_ACCEPTED:
            raise RuntimeError(f"Mission clear rejected: type={ack.type}")

        logger.info("Mission cleared")
        return True

    def set_current_waypoint(self, seq: int) -> bool:
        """Jump to waypoint *seq* in an active AUTO mission."""
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component

        mav.mission_set_current_send(ts, tc, seq)
        logger.info("Set current waypoint to %d", seq)
        return True

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _send_mission_item_int(
        mav: object,
        ts: int,
        tc: int,
        item: MissionItem,
    ) -> None:
        lat_int = round(item.lat * 1e7)
        lon_int = round(item.lon * 1e7)
        param4 = item.param4 if not math.isnan(item.param4) else 0.0

        mav.mission_item_int_send(  # type: ignore[attr-defined]
            ts,
            tc,
            item.seq,
            item.frame,
            item.command,
            item.current,
            item.autocontinue,
            item.param1,
            item.param2,
            item.param3,
            param4,
            lat_int,
            lon_int,
            item.alt,
            item.mission_type,
        )

    @staticmethod
    def _msg_to_mission_item(msg: object) -> MissionItem:
        return MissionItem(
            seq=msg.seq,              # type: ignore[attr-defined]
            frame=msg.frame,
            command=msg.command,
            current=msg.current,
            autocontinue=msg.autocontinue,
            param1=msg.param1,
            param2=msg.param2,
            param3=msg.param3,
            param4=msg.param4,
            lat=msg.x / 1e7,
            lon=msg.y / 1e7,
            alt=msg.z,
            mission_type=msg.mission_type,
        )
