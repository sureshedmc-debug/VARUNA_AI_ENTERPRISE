class DroneModel {
  final bool connected;

  final double battery;

  final int satellites;

  final double altitude;

  final double speed;

  final double heading;

  final double latitude;

  final double longitude;

  final String mode;

  const DroneModel({
    required this.connected,
    required this.battery,
    required this.satellites,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.latitude,
    required this.longitude,
    required this.mode,
  });

  factory DroneModel.demo() {
    return const DroneModel(
      connected: true,
      battery: 98,
      satellites: 18,
      altitude: 15.2,
      speed: 2.5,
      heading: 125,
      latitude: 28.6139,
      longitude: 77.2090,
      mode: "LOITER",
    );
  }
}