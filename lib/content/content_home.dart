import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:campusconectv2/utils/color_utils.dart';
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
  Set<Marker> _markers = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Circle> _circles = {};

  bool _markersGenerated =
      false; // Add a boolean flag to track marker generation

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _getCurrentLocation only if markers are not already generated
    if (!_markersGenerated) {
      // Fetch the active coordinates and generate markers
      _getActiveCoordinates().then((coordinates) {
        _generateMarkers(coordinates);
      });

      // Get the current location and generate circles
      //_getCurrentLocation();
    }
  }

  void _initializeMap() async {
    // Fetch the active coordinates
    List<LatLng> coordinates = await _getActiveCoordinates();

    // Generate markers and display them on the map
    _generateMarkers(coordinates);

    // Get the current location and generate circles
    _getCurrentLocation();
  }

  Future<void> _generateMarkers(List<LatLng> coordinates) async {
    if (coordinates.isNotEmpty) {
      // Clear the existing markers before adding new ones
      _markers.clear();

      for (int i = 0; i < coordinates.length; i++) {
        final MarkerId markerId = MarkerId("marker$i");
        final LatLng position = coordinates[i];

        // Fetch the list of documents from the "active" collection
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('active').get();
        for (QueryDocumentSnapshot docSnapshot in snapshot.docs) {
          String uid = docSnapshot.id;
          // Fetch the user's name from Firestore using the UID
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (userSnapshot.exists) {
            Map<String, dynamic> userData =
                userSnapshot.data() as Map<String, dynamic>;
            String name = userData['group'] ?? "Unknown User";

            // Add the marker with the user's name
            _markers.add(Marker(
              markerId: markerId,
              position: position,
              onTap: () {
                // Show the info window when the marker is tapped
                setState(() {
                  _markers = _markers.map((marker) {
                    if (marker.markerId == markerId) {
                      return marker.copyWith(
                        infoWindowParam: InfoWindow(
                          title: name,
                          snippet: "Tap to view details",
                        ),
                      );
                    } else {
                      return marker.copyWith(infoWindowParam: null);
                    }
                  }).toSet();
                });
              },
            ));
          }
        }
      }

      setState(() {
        _markersGenerated = true;
      });
    }
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

  Future<List<LatLng>> _getActiveCoordinates() async {
    List<LatLng> coordinates = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('active').get();
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((doc) {
        double latitude = doc['latitude'] ?? 0;
        double longitude = doc['longitude'] ?? 0;
        coordinates.add(LatLng(latitude, longitude));
      });
    }
    return coordinates;
  }

  void _generateCircles(List<LatLng> coordinates) {
    if (coordinates.isNotEmpty) {
      setState(() {
        _circles.clear();
        for (int i = 0; i < coordinates.length; i++) {
          final CircleId circleId = CircleId("circle$i");
          _circles.add(Circle(
            circleId: circleId,
            center: coordinates[i],
            radius: 30, // Adjust the radius of the circle as needed
            fillColor: Colors.red.withOpacity(0.5),
            strokeColor: Colors.red,
            strokeWidth: 2,
          ));
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
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

      // Fetch the active coordinates and generate circles
      List<LatLng> coordinates = await _getActiveCoordinates();
      _generateCircles(coordinates);

      // Generate markers and display them on the map
      _generateMarkers(coordinates);
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
                markers: _markers, // Add the markers to the map
                onTap: (_) {
                  // Close all info windows when the map is tapped
                  setState(() {
                    _markers = _markers.map((marker) {
                      return marker.copyWith(infoWindowParam: null);
                    }).toSet();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 26.0, bottom: 16.0),
              child: FloatingActionButton(
                backgroundColor: Colors.blue, // Set background color to blue
                foregroundColor: Colors.white, // Set icon color to white
                onPressed: () {
                  // Call the _initializeMap method to reload the map
                  _initializeMap();
                },
                child: Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ContentHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPosition != null) {
      _getActiveCoordinates().then((coordinates) {
        _generateMarkers(coordinates);
      });
    }
  }
}
