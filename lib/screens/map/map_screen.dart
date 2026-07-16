import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location_service.dart';
import '../../widgets/gps_info_card.dart';
import '../../widgets/drone_marker.dart';
import '../../widgets/home_marker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  StreamSubscription<Position>? _positionSubscription;

  LatLng _currentPosition = const LatLng(28.6139, 77.2090);
  LatLng? _homePosition;

  final List<LatLng> _flightPath = [];

  double _speed = 0;
  double _accuracy = 0;
  double _altitude = 0;
  double _heading = 0;

  bool _loading = true;
  bool _followDrone = true;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    final position = await _locationService.getCurrentLocation();

    _currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    _homePosition = _currentPosition;

    _speed = position.speed;
    _accuracy = position.accuracy;
    _altitude = position.altitude;
    _heading = position.heading;

    _flightPath.add(_currentPosition);

    setState(() {
      _loading = false;
    });

    _mapController.move(_currentPosition, 17);

    _positionSubscription =
        _locationService.getLiveLocation().listen((position) {

      _currentPosition = LatLng(
        position.latitude,
        position.longitude,
      );

      _speed = position.speed;
      _accuracy = position.accuracy;
      _altitude = position.altitude;
      _heading = position.heading;

      _flightPath.add(_currentPosition);

      if (_followDrone) {
        _mapController.move(
          _currentPosition,
          _mapController.camera.zoom,
        );
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  double get distanceFromHome {

    if (_homePosition == null) return 0;

    const Distance distance = Distance();

    return distance.as(
      LengthUnit.Meter,
      _homePosition!,
      _currentPosition,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor: const Color(0xff061B34),

      appBar: AppBar(
        title: const Text("Live Mission Map"),
        centerTitle: true,
        backgroundColor: const Color(0xff102A43),
      ),

      body: Stack(

        children: [

          FlutterMap(

            mapController: _mapController,

            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 17,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),

            children: [

              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.varuna.ai",
              ),

              CurrentLocationLayer(),

              PolylineLayer(

                polylines: [

                  Polyline(
                    points: _flightPath,
                    strokeWidth: 4,
                    color: Colors.cyan,
                  ),

                ],

              ),

              MarkerLayer(

                markers: [

                  Marker(

                    point: _currentPosition,

                    width: 45,

                    height: 45,

                    child: const DroneMarker(),

                  ),

                  if (_homePosition != null)

                    Marker(

                      point: _homePosition!,

                      width: 45,

                      height: 45,

                      child: const HomeMarker(),

                    ),

                ],

              ),
            ],

          ),

          Positioned(
            left: 10,
            right: 10,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Card(
                  color: const Color(0xCC102A43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [

                            const Text(
                              "HOME DISTANCE",
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "${distanceFromHome.toStringAsFixed(1)} m",
                              style: const TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                          ],
                        ),

                        const SizedBox(height: 10),

                        GPSInfoCard(
                          latitude: _currentPosition.latitude,
                          longitude: _currentPosition.longitude,
                          speed: _speed,
                          accuracy: _accuracy,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            Expanded(
                              child: Card(
                                color: const Color(0xFF0D2A49),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [

                                      const Text(
                                        "Altitude",
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${_altitude.toStringAsFixed(1)} m",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Card(
                                color: const Color(0xFF0D2A49),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [

                                      const Text(
                                        "Heading",
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "${_heading.toStringAsFixed(0)}°",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          FloatingActionButton(
            heroTag: "follow",
            backgroundColor:
                _followDrone ? Colors.green : Colors.grey,
            onPressed: () {
              setState(() {
                _followDrone = !_followDrone;
              });
            },
            child: Icon(
              _followDrone
                  ? Icons.gps_fixed
                  : Icons.gps_not_fixed,
            ),
          ),

          const SizedBox(height: 12),

          FloatingActionButton(
            heroTag: "center",
            backgroundColor: Colors.cyan,
            onPressed: () {
              _mapController.move(
                _currentPosition,
                18,
              );
            },
            child: const Icon(Icons.my_location),
          ),

        ],
      ),

    );
  }
}