import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
  final String? startAddress;
  final String? endAddress;

  const Direction({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
    required this.startAddress,
    required this.endAddress,
  });

  factory Direction.fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) {
      return Direction(
        bounds: LatLngBounds(
            northeast: const LatLng(0, 0), southwest: const LatLng(0, 0)),
        polylinePoints: [],
        totalDistance: '0 km',
        totalDuration: '0 mins',
        startAddress: '',
        endAddress: '',
      );
    }

    final data = Map<String, dynamic>.from(map['routes'][0]);

    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    final polylinePoints =
        PolylinePoints().decodePolyline(data['overview_polyline']['points']);

    return Direction(
      bounds: bounds,
      polylinePoints: polylinePoints,
      totalDistance: data['legs'][0]['distance']['text'],
      totalDuration: data['legs'][0]['duration']['text'],
      startAddress: data['legs'][0]['start_address'],
      endAddress: data['legs'][0]['end_address'],
    );
  }
}
