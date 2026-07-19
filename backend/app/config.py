"""Application configuration via pydantic-settings.

All settings are read from environment variables prefixed with ``VARUNA_``
or from a ``.env`` file in the working directory.
"""

from __future__ import annotations

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # ── Application ──────────────────────────────────────────────────────────
    app_name: str = "VARUNA AI Enterprise"
    app_version: str = "1.0.0"
    debug: bool = False

    # ── MAVLink / Pixhawk 2.4.8 ──────────────────────────────────────────────
    # Serial on Raspberry Pi 3A+:  /dev/serial0  (GPIO UART) or /dev/ttyUSB0
    # UDP for simulation:           udpin:0.0.0.0:14550
    mavlink_connection: str = "/dev/serial0"
    mavlink_baud: int = 57600
    mavlink_source_system: int = Field(default=255, ge=1, le=255)
    mavlink_source_component: int = Field(default=0, ge=0, le=255)
    mavlink_timeout: float = 5.0          # seconds to wait for a message
    mavlink_heartbeat_interval: float = 1.0
    mavlink_reconnect_delay: float = 2.0  # initial back-off delay
    mavlink_max_reconnect_delay: float = 30.0

    # ── HTTP server ───────────────────────────────────────────────────────────
    host: str = "0.0.0.0"
    port: int = 8000

    # ── WebSocket telemetry ───────────────────────────────────────────────────
    ws_telemetry_interval: float = 0.1   # seconds between broadcast frames (10 Hz)

    # ── Operational timeouts ──────────────────────────────────────────────────
    param_fetch_timeout: float = 30.0    # wait for all parameters
    mission_timeout: float = 30.0        # mission upload/download
    command_ack_timeout: float = 5.0     # wait for COMMAND_ACK

    model_config = {
        "env_file": ".env",
        "env_prefix": "VARUNA_",
        "case_sensitive": False,
        "extra": "ignore",
    }


settings = Settings()
