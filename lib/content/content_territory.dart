// ignore_for_file: unused_import, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ContentTerritory extends StatefulWidget {
  const ContentTerritory({Key? key}) : super(key: key);

  @override
  _ContentTerritoryState createState() => _ContentTerritoryState();
}

class _ContentTerritoryState extends State<ContentTerritory> {
  final List<Circle> _circles = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() async {
    List<LatLng> coordinates = await _getActiveCoordinates();

    List<Circle> circles = [
      Circle(
        circleId: const CircleId("circle0"),
        center: const LatLng(-26.1901982, 28.0268558),
        radius: 30,
        fillColor: Colors.red.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.red,
      ),
      Circle(
        circleId: const CircleId("circle1"),
        center: const LatLng(-26.1888679, 28.0251828),
        radius: 30,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.blue,
      ),
      Circle(
        circleId: const CircleId("circle2"),
        center: const LatLng(-26.1894389, 28.0258493),
        radius: 30,
        fillColor: Colors.green.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.green,
      ),
      Circle(
        circleId: const CircleId("circle3"),
        center: const LatLng(-26.1897609, 28.0257173),
        radius: 30,
        fillColor: Colors.yellow.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.yellow,
      ),

      Circle(
        circleId: const CircleId("circle4"),
        center: const LatLng(-26.1902368, 28.0268363),
        radius: 30,
        fillColor: Colors.purple.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.purple,
      ),
      // Add more Circle objects as needed
    ];

    _generateCircles(coordinates, circles);

    _getCurrentLocation();
  }

  void _generateCircles(List<LatLng> coordinates, List<Circle> circles) {
    if (coordinates.isNotEmpty) {
      _circles.clear();

      for (int i = 0; i < coordinates.length; i++) {
        if (circles.isNotEmpty && i < circles.length) {
          _circles.add(circles[i]);
        }
      }

      setState(() {});
    }
  }

  Future<List<LatLng>> _getActiveCoordinates() async {
    List<LatLng> coordinates = [];
    List<Circle> circles = [
      Circle(
        circleId: const CircleId("circle0"),
        center: const LatLng(-26.1901982, 28.0268558),
        radius: 30,
        fillColor: Colors.red.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.red,
      ),
      Circle(
        circleId: const CircleId("circle1"),
        center: const LatLng(-26.1888679, 28.0251828),
        radius: 30,
        fillColor: Colors.blue.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.blue,
      ),
      Circle(
        circleId: const CircleId("circle2"),
        center: const LatLng(-26.1894389, 28.0258493),
        radius: 30,
        fillColor: Colors.green.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.green,
      ),
      Circle(
        circleId: const CircleId("circle3"),
        center: const LatLng(-26.1897609, 28.0257173),
        radius: 30,
        fillColor: Colors.yellow.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.yellow,
      ),
      Circle(
        circleId: const CircleId("circle4"),
        center: const LatLng(-26.1902368, 28.0268363),
        radius: 30,
        fillColor: Colors.purple.withOpacity(0.5),
        strokeWidth: 2,
        strokeColor: Colors.purple,
      ),
    ];

    for (Circle circle in circles) {
      coordinates.add(circle.center);
    }

    return coordinates;
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _moveToPosition(position);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  void _moveToPosition(Position position) {
    LatLng latLng = LatLng(position.latitude, position.longitude);
    GoogleMapController? controller = _mapController;
    if (controller != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 17),
      );
    }
  }

  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-26.1901982, 28.0268558),
                zoom: 10,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              circles: _circles.toSet(),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 26.0, bottom: 16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                onPressed: () {
                  _initializeMap();
                },
                child: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
