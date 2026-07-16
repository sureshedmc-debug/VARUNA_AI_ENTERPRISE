enum DroneState {
  disconnected,
  connecting,
  ready,
  armed,
  takingOff,
  flying,
  returningHome,
  landing,
  landed,
  emergency,
}

class DroneStateModel {
  final DroneState state;
  final bool connected;
  final bool armed;
  final bool readyToFly;
  final String flightMode;
  final double battery;
  final double altitude;
  final double heading;
  final int satellites;

  const DroneStateModel({
    required this.state,
    required this.connected,
    required this.armed,
    required this.readyToFly,
    required this.flightMode,
    required this.battery,
    required this.altitude,
    required this.heading,
    required this.satellites,
  });

  factory DroneStateModel.initial() {
    return const DroneStateModel(
      state: DroneState.disconnected,
      connected: false,
      armed: false,
      readyToFly: false,
      flightMode: 'DISCONNECTED',
      battery: 100,
      altitude: 0,
      heading: 0,
      satellites: 0,
    );
  }

  DroneStateModel copyWith({
    DroneState? state,
    bool? connected,
    bool? armed,
    bool? readyToFly,
    String? flightMode,
    double? battery,
    double? altitude,
    double? heading,
    int? satellites,
  }) {
    return DroneStateModel(
      state: state ?? this.state,
      connected: connected ?? this.connected,
      armed: armed ?? this.armed,
      readyToFly: readyToFly ?? this.readyToFly,
      flightMode: flightMode ?? this.flightMode,
      battery: battery ?? this.battery,
      altitude: altitude ?? this.altitude,
      heading: heading ?? this.heading,
      satellites: satellites ?? this.satellites,
    );
  }

  Map<String,dynamic> toMap() => {
    'state': state.name,
    'connected': connected,
    'armed': armed,
    'readyToFly': readyToFly,
    'flightMode': flightMode,
    'battery': battery,
    'altitude': altitude,
    'heading': heading,
    'satellites': satellites,
  };

  factory DroneStateModel.fromMap(Map<String,dynamic> map) {
    return DroneStateModel(
      state: DroneState.values.firstWhere(
        (e)=>e.name==map['state'],
        orElse: ()=>DroneState.disconnected,
      ),
      connected: map['connected'] ?? false,
      armed: map['armed'] ?? false,
      readyToFly: map['readyToFly'] ?? false,
      flightMode: map['flightMode'] ?? 'UNKNOWN',
      battery: (map['battery'] as num?)?.toDouble() ?? 100,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0,
      satellites: map['satellites'] ?? 0,
    );
  }
}

