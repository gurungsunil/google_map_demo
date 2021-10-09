import 'dart:convert';

import 'package:flutter_google_map_demo/env.dart';
import 'package:flutter_google_map_demo/model/direction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Api {
  String baseUrl = "https://maps.googleapis.com/maps/api/directions/json?";

  Future<Direction> fetchDistance(LatLng origin, LatLng destination) async {
    String org = "${origin.latitude},${origin.longitude}";
    String dest = "${destination.latitude},${destination.longitude}";
    Uri uri = Uri.parse("${baseUrl}origin=$org&destination=$dest&key=$MAP_API_KEY");
    var response = await http.get(uri);
    var jsonData = jsonDecode(response.body);
    if ((jsonData["routes"] as List).isNotEmpty) {
      return Direction.fromJson(jsonData);
    } else {
      return null;
    }
  }
}
