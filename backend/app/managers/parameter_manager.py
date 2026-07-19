"""Parameter Manager.

Reads, caches and writes ArduPilot parameters via MAVLink PARAM_REQUEST_LIST /
PARAM_REQUEST_READ / PARAM_SET messages.

ArduPilot 4.6.x exposes ~1000+ tunable parameters.  This manager provides:

- Bulk fetch of all parameters (with timeout / progress tracking)
- Single-parameter read (from cache or live request)
- Single-parameter write with ACK verification
- Thread-safe parameter cache
"""

from __future__ import annotations

import logging
import threading
import time
from typing import Optional

import pymavlink.mavutil as mavutil

from app.config import settings
from app.managers.mavlink_manager import MAVLinkManager
from app.models.parameter import Parameter

logger = logging.getLogger(__name__)


class ParameterManager:
    """Thread-safe ArduPilot parameter read/write manager."""

    def __init__(self, mavlink: MAVLinkManager) -> None:
        self._mav = mavlink
        self._cache: dict[str, Parameter] = {}
        self._cache_lock = threading.Lock()
        self._param_count: int = 0
        self._fetch_complete = threading.Event()

        # Subscribe to PARAM_VALUE to populate cache as they arrive
        self._mav.subscribe("PARAM_VALUE", self._on_param_value)

    # ------------------------------------------------------------------
    # Event handler
    # ------------------------------------------------------------------

    def _on_param_value(self, msg: object) -> None:
        name: str = msg.param_id.rstrip("\x00")  # type: ignore[attr-defined]
        param = Parameter(
            name=name,
            value=msg.param_value,    # type: ignore[attr-defined]
            param_type=msg.param_type, # type: ignore[attr-defined]
            index=msg.param_index,     # type: ignore[attr-defined]
        )
        with self._cache_lock:
            self._cache[name] = param
            if msg.param_count > 0:  # type: ignore[attr-defined]
                self._param_count = msg.param_count  # type: ignore[attr-defined]

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def fetch_all(self, timeout: Optional[float] = None) -> list[Parameter]:
        """Request all parameters from the vehicle and wait for them.

        Returns the cached parameter list.  Safe to call multiple times.

        Parameters
        ----------
        timeout:
            Override the default fetch timeout from settings.
        """
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        to = timeout or settings.param_fetch_timeout
        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component

        logger.info("Requesting all parameters …")
        with self._cache_lock:
            self._cache.clear()
            self._param_count = 0

        mav.param_request_list_send(ts, tc)  # type: ignore[attr-defined]

        deadline = time.time() + to
        last_count = -1
        stall_start = time.time()

        while time.time() < deadline:
            time.sleep(0.2)
            with self._cache_lock:
                received = len(self._cache)
                expected = self._param_count

            if received != last_count:
                last_count = received
                stall_start = time.time()
                if expected > 0:
                    logger.debug("Parameters: %d / %d", received, expected)

            if expected > 0 and received >= expected:
                break

            # If stalled for > 3 s, re-request missing params
            if expected > 0 and time.time() - stall_start > 3.0:
                logger.debug("Parameter fetch stalled – re-requesting missing params")
                with self._cache_lock:
                    received_indices = {p.index for p in self._cache.values() if p.index >= 0}
                for idx in range(expected):
                    if idx not in received_indices:
                        mav.param_request_read_send(ts, tc, b"", idx)  # type: ignore[attr-defined]
                stall_start = time.time()

        with self._cache_lock:
            params = sorted(self._cache.values(), key=lambda p: p.index)

        logger.info("Fetched %d parameters", len(params))
        return params

    def get_parameter(self, name: str) -> Optional[Parameter]:
        """Return a parameter by name.

        Checks the cache first; falls back to a live PARAM_REQUEST_READ
        if not cached.
        """
        with self._cache_lock:
            if name in self._cache:
                return self._cache[name]

        # Not in cache – request directly
        if not self._mav.is_connected:
            return None

        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component

        param_id = name.encode("ascii").ljust(16, b"\x00")
        mav.param_request_read_send(ts, tc, param_id, -1)  # type: ignore[attr-defined]

        msg = self._mav.wait_for_message(
            "PARAM_VALUE",
            timeout=5.0,
            condition=lambda m: m.param_id.rstrip("\x00") == name,
        )
        if msg is None:
            return None

        param = Parameter(
            name=name,
            value=msg.param_value,
            param_type=msg.param_type,
            index=msg.param_index,
        )
        with self._cache_lock:
            self._cache[name] = param
        return param

    def set_parameter(self, name: str, value: float) -> Optional[Parameter]:
        """Write *value* to parameter *name* and wait for ACK.

        Returns the updated Parameter on success, or None on failure.

        Raises
        ------
        RuntimeError
            If not connected.
        """
        if not self._mav.is_connected:
            raise RuntimeError("Not connected to vehicle")

        mav = self._mav.mav
        ts = self._mav.target_system
        tc = self._mav.target_component

        # Determine param type from cache (default REAL32)
        with self._cache_lock:
            cached = self._cache.get(name)

        param_type = cached.param_type if cached else mavutil.mavlink.MAV_PARAM_TYPE_REAL32

        param_id = name.encode("ascii").ljust(16, b"\x00")
        mav.param_set_send(ts, tc, param_id, value, param_type)  # type: ignore[attr-defined]

        ack = self._mav.wait_for_message(
            "PARAM_VALUE",
            timeout=5.0,
            condition=lambda m: m.param_id.rstrip("\x00") == name,
        )
        if ack is None:
            logger.error("No PARAM_VALUE ACK for %s", name)
            return None

        updated = Parameter(
            name=name,
            value=ack.param_value,
            param_type=ack.param_type,
            index=ack.param_index,
        )
        with self._cache_lock:
            self._cache[name] = updated
        logger.info("Parameter %s set to %s", name, updated.value)
        return updated

    def get_cached_parameters(self) -> list[Parameter]:
        """Return all currently cached parameters (no vehicle request)."""
        with self._cache_lock:
            return sorted(self._cache.values(), key=lambda p: p.index)

    def clear_cache(self) -> None:
        """Clear the parameter cache."""
        with self._cache_lock:
            self._cache.clear()
            self._param_count = 0
