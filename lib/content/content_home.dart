import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gradeovl/utils/color_utils.dart';
import 'package:permission_handler/permission_handler.dart';

BoxDecoration _backgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      hexStringToColor("#1835f0"),
      hexStringToColor("#283cbf"),
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

class ContentHome extends StatefulWidget {
  const ContentHome({super.key});

  @override
  _ContentHomeState createState() => _ContentHomeState();
}

class _ContentHomeState extends State<ContentHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    //_getCurrentUser();
    _requestLocationPermissions(); // Request location permissions when the app is launched
  }

  Future<void> _requestLocationPermissions() async {
    if (await Permission.location.isGranted) {
      // Location permissions already granted
      _getCurrentLocation();
    } else {
      // Request location permissions
      final status = await Permission.location.request();
      if (status.isGranted) {
        _getCurrentLocation();
      } else if (status.isDenied) {
        // The user denied the permission
        print("Location permissions denied by the user.");
        // Optionally, you can show a dialog to explain why location permissions are needed
        // and provide a way for the user to go to the app settings and grant permissions manually.
      } else if (status.isPermanentlyDenied) {
        // The user permanently denied the permission
        print("Location permissions permanently denied by the user.");
        // You can show a dialog explaining that the user must grant permissions manually
        // through the app settings.
      }
    }
  }

  void _generateCircles() {
    if (_currentPosition != null) {
      final List<LatLng> coordinates = _generateRandomCoordinates();
      final CircleId circleId1 = CircleId("circle1");
      final CircleId circleId2 = CircleId("circle2");
      final CircleId circleId3 = CircleId("circle3");

      setState(() {
        _circles.clear();
        _circles.add(Circle(
          circleId: circleId1,
          center: coordinates[0],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
        _circles.add(Circle(
          circleId: circleId2,
          center: coordinates[1],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
        _circles.add(Circle(
          circleId: circleId3,
          center: coordinates[2],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _generateCircles(); // Generate circles after getting the current location
      });
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentPosition?.latitude ?? 0,
                _currentPosition?.longitude ?? 0,
              ),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  // Generate 3 random LatLng coordinates near the current location
  List<LatLng> _generateRandomCoordinates() {
    final double latitude = _currentPosition?.latitude ?? 0;
    final double longitude = _currentPosition?.longitude ?? 0;
    final double offset =
        0.001; // Adjust this value to control the distance of the circles

    return [
      LatLng(latitude + offset, longitude + offset),
      LatLng(latitude - offset, longitude + offset),
      LatLng(latitude, longitude - offset),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _backgroundDecoration,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Flexible(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          _currentPosition?.latitude ?? 0,
                          _currentPosition?.longitude ?? 0,
                        ),
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      circles: _circles, // Add the circles to the map
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ContentHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPosition != null) {
      // Generate circles only when the current position is available
      final List<LatLng> coordinates = _generateRandomCoordinates();
      final CircleId circleId1 = CircleId("circle1");
      final CircleId circleId2 = CircleId("circle2");
      final CircleId circleId3 = CircleId("circle3");

      setState(() {
        _circles.clear();
        _circles.add(Circle(
          circleId: circleId1,
          center: coordinates[0],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
        _circles.add(Circle(
          circleId: circleId2,
          center: coordinates[1],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
        _circles.add(Circle(
          circleId: circleId3,
          center: coordinates[2],
          radius: 10, // Adjust the radius of the circle as needed
          fillColor: Colors.red.withOpacity(0.5),
          strokeColor: Colors.red,
          strokeWidth: 2,
        ));
      });
    }
  }
}
