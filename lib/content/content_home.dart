// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ContentHome extends StatefulWidget {
  const ContentHome({super.key});

  @override
  _ContentHomeState createState() => _ContentHomeState();
}

class _ContentHomeState extends State<ContentHome> {
  final Set<Marker> _markers = {};
  User? user = FirebaseAuth.instance.currentUser;

  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _markersGenerated = false;

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
    List<LatLng> coordinates = await _getActiveCoordinates();
    _generateMarkers(coordinates);
    _getCurrentLocation();
  }

  void _generateMarkers(List<LatLng> coordinates) async {
    if (coordinates.isNotEmpty) {
      _markers.clear();

      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('active').get();
      for (int i = 0; i < coordinates.length; i++) {
        final MarkerId markerId = MarkerId("marker$i");
        final LatLng position = coordinates[i];
        QueryDocumentSnapshot? matchingDoc;
        for (QueryDocumentSnapshot docSnapshot in snapshot.docs) {
          double latitude = docSnapshot['latitude'] ?? 0;
          double longitude = docSnapshot['longitude'] ?? 0;
          if (position.latitude == latitude &&
              position.longitude == longitude) {
            matchingDoc = docSnapshot;
            break;
          }
        }

        if (matchingDoc != null) {
          String uid = matchingDoc.id;
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
              infoWindow: InfoWindow(
                title: name,
                snippet: "Tap to view details",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Join Group"),
                        content: Text("Do you want to join $name's group?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () async {
                              String? uidUser = user?.uid;
                              print("Join button pressed for $name");
                              await FirebaseFirestore.instance
                                  .collection('groups')
                                  .doc(name)
                                  .update({
                                'members': FieldValue.arrayUnion([uidUser])
                              });
                              Navigator.pop(context);
                            },
                            child: const Text("Join"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ));
          }
        }
      }

      setState(() {
        _markersGenerated = true;
      });
    }
  }

  Future<List<LatLng>> _getActiveCoordinates() async {
    List<LatLng> coordinates = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('active').get();
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        double latitude = doc['latitude'] ?? 0;
        double longitude = doc['longitude'] ?? 0;
        coordinates.add(LatLng(latitude, longitude));
      }
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
                child: const Icon(Icons.refresh),
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
