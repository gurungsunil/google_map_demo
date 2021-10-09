import 'package:flutter_google_map_demo/env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Api {
  String baseUrl="https://maps.googleapis.com/maps/api/directions/json?";

  Future<Map<String, dynamic>> fetchDistance(LatLng origin,LatLng destination) async{
    print(origin);
    print(destination);

    Uri uri= Uri.parse("${baseUrl}origin=$origin&destination=$destination&key=$MAP_API_KEY");
    var response = http.get(uri);
    return null;
  }
}