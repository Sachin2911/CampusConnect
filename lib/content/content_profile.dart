import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusconectv2/reusable_wdgets/reusable_widget.dart';
import 'package:campusconectv2/screens/home_screen.dart';
import 'package:campusconectv2/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package

BoxDecoration _backgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      hexStringToColor("#1835f0"),
      hexStringToColor("#1835f0"),
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

Future<Position?> _getCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  } catch (e) {
    print("Error getting current location: $e");
    return null;
  }
}

class ContentProfile extends StatefulWidget {
  const ContentProfile({super.key});

  @override
  State<ContentProfile> createState() => _ContentProfileState();
}

class _ContentProfileState extends State<ContentProfile> {
  User? user = FirebaseAuth.instance.currentUser;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  bool _isActive = false; // variable to track button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#0e81ed"),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: usersCollection.doc(user?.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text("Error loading user data");
                }
                // Get user data from the snapshot
                Map<String, dynamic> userData =
                    snapshot.data?.data() as Map<String, dynamic>;
                String name = userData['name'] ?? '';
                String degree = userData['degree'] ?? '';
                String year = userData['year'] ?? '';

                // Display user profile information above the active button
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.black,
                      radius: 70,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Name: $name",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Degree: $degree",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Year: $year",
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(90)),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_isActive) {
                              // User is currently active, so we need to delete their record from the "active" collection
                              User? user = FirebaseAuth.instance.currentUser;
                              String? uid = user?.uid;
                              if (uid != null) {
                                await FirebaseFirestore.instance
                                    .collection('active')
                                    .doc(uid)
                                    .delete();
                                setState(() {
                                  _isActive =
                                      false; // Set the button state to inactive
                                });
                              }
                            } else {
                              // Use null-aware access operator (?.) to conditionally access uid
                              String? uid = user?.uid;
                              if (uid != null) {
                                print("User UID: $uid");
                              } else {
                                // User is not authenticated or signed out
                                print("User is not authenticated.");
                              }
                              Position? position = await _getCurrentLocation();
                              if (position != null) {
                                // Create a new document under the "active" collection with the user's latitude
                                await FirebaseFirestore.instance
                                    .collection('active')
                                    .doc(uid)
                                    .set({
                                  'latitude': position.latitude,
                                  'longitude': position.longitude,
                                });
                                setState(() {
                                  _isActive =
                                      true; // Set the button state to active
                                });
                              }
                            }
                          },
                          // ignore: sort_child_properties_last
                          child: Text(
                            _isActive ? "Set InActive" : "Active",
                            style: TextStyle(
                                color: _isActive ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return _isActive ? Colors.red : Colors.white;
                              }),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
