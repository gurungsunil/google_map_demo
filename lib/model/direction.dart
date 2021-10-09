import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction{
  final LatLngBounds bounds;
  final List polyline;
  final String totalDistance;
  final String totalDuration;

  Direction({this.bounds, this.polyline, this.totalDistance, this.totalDuration});

  // Direction.fromJson(Map<String, dynamic> json):
  //     bounds= json["bounds"];
}