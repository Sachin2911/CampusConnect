import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ContentHome extends StatefulWidget {
  const ContentHome({super.key});

  @override
  _ContentHomeState createState() => _ContentHomeState();
}

class _ContentHomeState extends State<ContentHome> {
  //Creating set to store markers
  Set<Marker> _markers = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Position? _currentPosition;

  //Problem with marker load, boolean to force marker load if not true
  bool _markersGenerated = false;

  //Calling the _initializeMap function on build
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_markersGenerated) {
      _getActiveCoordinates().then((coordinates) {
        _generateMarkers(coordinates);
      });
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
        //Auto generated Marker Id's
        final MarkerId markerId = MarkerId("marker$i");
        final LatLng position = coordinates[i];

        // Getting all the latitude and longitude for each document in active
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

            _markers.add(Marker(
              markerId: markerId,
              position: position,
              onTap: () {
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
      _getCurrentLocation();
    } else {
      final status = await Permission.location.request();
      if (status.isGranted) {
        _getCurrentLocation();
      } else if (status.isDenied) {
        print("Location permissions denied by the user.");
      } else if (status.isPermanentlyDenied) {
        print("Location permissions permanently denied by the user.");
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
      List<LatLng> coordinates = await _getActiveCoordinates();
      _generateMarkers(coordinates);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
              markers: _markers,
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
