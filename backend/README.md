# VARUNA AI Enterprise – Backend

Production-ready FastAPI backend for autonomous drone operations using Pixhawk 2.4.8 / ArduPilot 4.6.x on Raspberry Pi 3A+.

---

## Hardware

| Component | Specification |
|-----------|--------------|
| Companion computer | Raspberry Pi 3A+ |
| Flight controller | Pixhawk 2.4.8 |
| Firmware | ArduPilot 4.6.x (ArduCopter or ArduPlane) |
| Connection | UART `/dev/serial0` @ 57600 baud (GPIO pins 8/10) |

---

## Software Stack

- **Python** 3.11
- **FastAPI** – async REST + WebSocket API
- **pymavlink** – MAVLink 2 protocol implementation
- **uvicorn** – ASGI server
- **pydantic** – data models & validation

---

## Quick Start

```bash
# 1. Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Edit .env to match your hardware setup

# 4. Run the server
python manager.py
# or
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

---

## API Overview

### REST Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Service health + MAVLink status |
| GET | `/api/v1/telemetry` | Latest telemetry snapshot |
| GET | `/api/v1/mission` | Download current mission |
| POST | `/api/v1/mission` | Upload a new mission |
| DELETE | `/api/v1/mission` | Clear mission on vehicle |
| GET | `/api/v1/mission/current` | Get active waypoint index |
| POST | `/api/v1/mission/current` | Jump to waypoint |
| GET | `/api/v1/parameters` | Fetch all parameters |
| GET | `/api/v1/parameters/{name}` | Fetch single parameter |
| PUT | `/api/v1/parameters/{name}` | Set parameter value |
| POST | `/api/v1/command/arm` | Arm vehicle |
| POST | `/api/v1/command/disarm` | Disarm vehicle |
| POST | `/api/v1/command/mode` | Change flight mode |
| POST | `/api/v1/command/takeoff` | Guided takeoff |
| POST | `/api/v1/command/land` | Initiate landing |
| POST | `/api/v1/command/rtl` | Return to launch |

### WebSocket

| Path | Description |
|------|-------------|
| `ws://host:8000/ws/telemetry` | 10 Hz real-time telemetry stream |

#### Telemetry Frame (JSON)
```json
{
  "timestamp": 1720000000.0,
  "connected": true,
  "armed": false,
  "mode": "GUIDED",
  "attitude": {"roll": 0.0, "pitch": 0.0, "yaw": 0.0},
  "position": {"lat": 12.9716, "lon": 77.5946, "alt_msl": 920.0, "alt_rel": 0.0},
  "velocity": {"vx": 0.0, "vy": 0.0, "vz": 0.0, "groundspeed": 0.0, "airspeed": 0.0},
  "gps": {"fix_type": 3, "satellites_visible": 12, "hdop": 0.9},
  "battery": {"voltage": 12.6, "current": 1.2, "remaining": 95},
  "heading": 45.0
}
```

---

## Architecture

```
backend/
├── app/
│   ├── main.py              # FastAPI application factory
│   ├── config.py            # Settings (pydantic-settings)
│   ├── dependencies.py      # FastAPI dependency providers
│   ├── models/              # Pydantic request/response models
│   │   ├── telemetry.py
│   │   ├── mission.py
│   │   ├── parameter.py
│   │   └── command.py
│   ├── managers/            # Business logic / MAVLink interaction
│   │   ├── mavlink_manager.py   # Enterprise MAVLink connection manager
│   │   ├── mission_manager.py   # Mission upload/download/monitor
│   │   └── parameter_manager.py # Parameter read/write with cache
│   ├── routers/             # FastAPI route handlers
│   │   ├── health.py
│   │   ├── telemetry.py
│   │   ├── mission.py
│   │   ├── parameter.py
│   │   └── command.py
│   └── websocket/
│       └── manager.py       # WebSocket connection pool + broadcaster
├── tests/
│   ├── conftest.py          # Shared fixtures / mocked MAVLink
│   ├── test_api.py          # REST endpoint integration tests
│   ├── test_mission_manager.py
│   ├── test_parameter_manager.py
│   └── test_reconnect.py    # Reconnection logic tests
├── manager.py               # CLI entry point (uvicorn launcher)
├── requirements.txt
├── pytest.ini
└── .env.example
```

---

## Configuration Reference

All settings are prefixed with `VARUNA_` and can be set via environment variables or `.env` file.

| Variable | Default | Description |
|----------|---------|-------------|
| `VARUNA_MAVLINK_CONNECTION` | `/dev/serial0` | MAVLink connection string |
| `VARUNA_MAVLINK_BAUD` | `57600` | Serial baud rate |
| `VARUNA_MAVLINK_SOURCE_SYSTEM` | `255` | GCS system ID |
| `VARUNA_MAVLINK_TIMEOUT` | `5.0` | Message receive timeout (s) |
| `VARUNA_MAVLINK_RECONNECT_DELAY` | `2.0` | Initial reconnect delay (s) |
| `VARUNA_MAVLINK_MAX_RECONNECT_DELAY` | `30.0` | Max reconnect delay (s) |
| `VARUNA_HOST` | `0.0.0.0` | HTTP bind address |
| `VARUNA_PORT` | `8000` | HTTP port |
| `VARUNA_WS_TELEMETRY_INTERVAL` | `0.1` | Telemetry broadcast period (s) |
| `VARUNA_PARAM_FETCH_TIMEOUT` | `30.0` | All-param fetch timeout (s) |
| `VARUNA_MISSION_TIMEOUT` | `30.0` | Mission op timeout (s) |
| `VARUNA_COMMAND_ACK_TIMEOUT` | `5.0` | Command ACK timeout (s) |

---

## Running Tests

```bash
cd backend
pytest -q
# or with coverage
pytest --cov=app --cov-report=term-missing
```

---

## Raspberry Pi Setup Notes

Enable UART on `/dev/serial0`:
```bash
# /boot/config.txt
enable_uart=1
dtoverlay=disable-bt   # free UART from Bluetooth
```

Wire Pixhawk TELEM2 to Raspberry Pi GPIO:
- Pi TX (pin 8)  → Pixhawk RX
- Pi RX (pin 10) → Pixhawk TX
- GND → GND

Set ArduPilot parameters:
```
SERIAL2_BAUD = 57
SERIAL2_PROTOCOL = 2   (MAVLink 2)
```
