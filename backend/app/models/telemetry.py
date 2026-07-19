"""Telemetry data models.

These Pydantic models represent the real-time state of the vehicle as reported
by ArduPilot 4.6.x over MAVLink.  They are used both for the REST telemetry
snapshot endpoint and as the JSON frame broadcast over the WebSocket.
"""

from __future__ import annotations

from pydantic import BaseModel, Field


class AttitudeModel(BaseModel):
    """Vehicle attitude in radians (from ATTITUDE MAVLink message)."""

    roll: float = Field(0.0, description="Roll angle in radians")
    pitch: float = Field(0.0, description="Pitch angle in radians")
    yaw: float = Field(0.0, description="Yaw angle in radians")
    rollspeed: float = Field(0.0, description="Roll angular speed rad/s")
    pitchspeed: float = Field(0.0, description="Pitch angular speed rad/s")
    yawspeed: float = Field(0.0, description="Yaw angular speed rad/s")


class PositionModel(BaseModel):
    """Global position (from GLOBAL_POSITION_INT)."""

    lat: float = Field(0.0, description="Latitude in degrees")
    lon: float = Field(0.0, description="Longitude in degrees")
    alt_msl: float = Field(0.0, description="Altitude above mean sea level (m)")
    alt_rel: float = Field(0.0, description="Altitude above home position (m)")


class VelocityModel(BaseModel):
    """Vehicle velocity (from VFR_HUD + GLOBAL_POSITION_INT)."""

    vx: float = Field(0.0, description="X velocity m/s (North positive)")
    vy: float = Field(0.0, description="Y velocity m/s (East positive)")
    vz: float = Field(0.0, description="Z velocity m/s (down positive)")
    groundspeed: float = Field(0.0, description="Ground speed m/s")
    airspeed: float = Field(0.0, description="Indicated airspeed m/s")


class GPSModel(BaseModel):
    """GPS status (from GPS_RAW_INT)."""

    fix_type: int = Field(0, description="GPS fix type: 0=No GPS, 3=3D Fix, 6=RTK")
    satellites_visible: int = Field(0, description="Number of visible satellites")
    hdop: float = Field(99.99, description="Horizontal dilution of position")


class BatteryModel(BaseModel):
    """Battery status (from SYS_STATUS / BATTERY_STATUS)."""

    voltage: float = Field(0.0, description="Battery voltage in volts")
    current: float = Field(0.0, description="Current draw in amps (-1 if unknown)")
    remaining: int = Field(-1, description="Remaining capacity 0-100%, -1 unknown")


class TelemetrySnapshot(BaseModel):
    """Full telemetry snapshot returned by GET /api/v1/telemetry and
    broadcast over the WebSocket.
    """

    timestamp: float = Field(0.0, description="Unix timestamp of this snapshot")
    connected: bool = Field(False, description="MAVLink connection active")
    armed: bool = Field(False, description="Vehicle armed state")
    mode: str = Field("UNKNOWN", description="ArduPilot flight mode string")
    system_status: int = Field(0, description="MAV_STATE enum value")
    heading: float = Field(0.0, description="Compass heading in degrees 0-359")
    attitude: AttitudeModel = Field(default_factory=AttitudeModel)
    position: PositionModel = Field(default_factory=PositionModel)
    velocity: VelocityModel = Field(default_factory=VelocityModel)
    gps: GPSModel = Field(default_factory=GPSModel)
    battery: BatteryModel = Field(default_factory=BatteryModel)
