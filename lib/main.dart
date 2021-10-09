import 'dart:async';

import 'package:flutter/material.dart';
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

  PermissionStatus _permissionGranted;
  CameraPosition _initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 18.5,
  );

  // static final CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
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
          : Container(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialLocation,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                minMaxZoomPreference: MinMaxZoomPreference(0, 18.5),
                markers: {
                  Marker(
                    draggable: true,
                    markerId: MarkerId("1"),
                    position: LatLng(37.42796133580664, -122.085749655962),
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: const InfoWindow(
                      title: 'My Current Location',
                    ),
                  ),
                  // if (_myLocationMarker != null) _myLocationMarker,
                  // if (_destination != null) _destination
                },
                onLongPress: _handleOnTabGesture,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraMove: _handleOnCameraMove,
              ),
            ),
      // floatingActionButton:
      //     IconButton(icon: Icon(Icons.my_location), onPressed: checkLocationPermission),
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
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    location.changeSettings(
      accuracy: LocationAccuracy.navigation,
    );
    _locationData = await location.getLocation();

    _initialLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(_locationData.latitude, _locationData.longitude),
        tilt: 59.440717697143555);
  }

  void _handleOnTabGesture(LatLng argument) {
    print(argument);
    setState(() {
      _destination = Marker(
        draggable: true,
        markerId: const MarkerId("destination"),
        position: argument,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'My Current Location',
        ),
      );
    });
  }

  void _handleOnCameraMove(CameraPosition position) async {
    final GoogleMapController controller = await _controller.future;
  }
}
