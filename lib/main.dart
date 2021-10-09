import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_google_map_demo/api/api.dart';
import 'package:flutter_google_map_demo/model/direction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Flutter Map Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  bool _isBusy = false;
  Marker _destination;
  Marker _origin;
  LocationData _locationData;

  Direction _direction;

  PermissionStatus _permissionGranted;

  CameraPosition _initialLocation;

  @override
  void initState() {
    super.initState();
    _initialLocation = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 16.5,
    );
    _isBusy = true;
    checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        brightness: Brightness.dark,
      ),
      body: _isBusy
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.deepOrangeAccent),
              ),
            )
          : Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Container(
                    child: GoogleMap(
                      mapType: MapType.terrain,
                      initialCameraPosition: _initialLocation,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                      minMaxZoomPreference: MinMaxZoomPreference(0, 18.5),
                      markers: {
                        if (_origin != null) _origin,
                        if (_destination != null) _destination
                      },
                      polylines: {
                        if (_direction != null)
                          Polyline(
                            polylineId: const PolylineId("overview_polyline"),
                            color: Colors.deepOrange,
                            width: 4,
                            points: _direction.polyline
                                .map((e) => LatLng(e.latitude, e.longitude))
                                .toList(),
                          )
                      },
                      onTap: (argument) => _updateMarkerCoordinates(argument, "destination"),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      onCameraMove: _handleOnCameraMove,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Future<void> fetchMyLocation(CameraPosition position) async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(position));
  // }

  Future<void> checkLocationPermission() async {
    Location location = new Location();
    bool _serviceEnabled;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    print(_permissionGranted);
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    await location.changeSettings(
      accuracy: LocationAccuracy.high,
    );
    _locationData = await location.getLocation();

    _initialLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_locationData.latitude, _locationData.longitude),
        tilt: 35,
        zoom: 16.5);

    _isBusy = false;
    _updateMarkerCoordinates(LatLng(_locationData.latitude, _locationData.longitude), "origin");
  }

  void _updateMarkerCoordinates(LatLng argument, String type) async {
    if (type == "origin") {
      _origin = Marker(
          draggable: true,
          markerId: const MarkerId("origin"),
          position: argument,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(
            title: 'Your Location (Origin)',
          ),
          onDragEnd: (LatLng data) {
            _updateMarkerCoordinates(data, "origin");
          });
    } else {
      _destination = Marker(
          draggable: true,
          markerId: const MarkerId("destination"),
          position: argument,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(
            title: 'Your destination',
          ),
          onDragEnd: (LatLng data) {
            _updateMarkerCoordinates(data, "destination");
          });
    }
    if (_origin != null && _destination != null) {
      _fetchDirection();
    }
  }

  void _fetchDirection() async {
    Direction dd = await Api().fetchDistance(_origin.position, _destination.position);
    setState(() {
      _direction = dd;
    });
  }

  void _handleOnCameraMove(CameraPosition position) async {
    final GoogleMapController controller = await _controller.future;
  }

  @override
  void dispose() async {
    super.dispose();
    final GoogleMapController controller = await _controller.future;
    controller.dispose();
  }
}
