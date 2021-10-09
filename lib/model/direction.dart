import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction {
  LatLngBounds bounds;
  List<PointLatLng> polyline;
  String totalDistance;
  String totalDuration;

  Direction({this.bounds, this.polyline, this.totalDistance, this.totalDuration});

  Direction.fromJson(Map<String, dynamic> json)
      : bounds = _parseLatLngBound(json["routes"][0]),
        polyline =
            PolylinePoints().decodePolyline(json["routes"][0]["overview_polyline"]["points"]),
        totalDistance = json["routes"][0]["legs"][0]["distance"]["text"],
        totalDuration = json["routes"][0]["legs"][0]["duration"]["text"];

  static LatLngBounds _parseLatLngBound(Map<String, dynamic> json) {
    final northEast = json["bounds"]["northeast"];
    final southWest = json["bounds"]["southwest"];
    return LatLngBounds(
        southwest: LatLng(southWest["lat"], northEast["lng"]),
        northeast: LatLng(northEast["lat"], southWest["lng"]));
  }
}
