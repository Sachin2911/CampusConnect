import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campusconectv2/reusable_wdgets/reusable_widget.dart';
import 'package:campusconectv2/content/content_home.dart';
import 'package:campusconectv2/content/content_profile.dart';
import 'package:campusconectv2/utils/color_utils.dart';

BoxDecoration _backgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      hexStringToColor("#0e81ed"),
      hexStringToColor("#283cbf"),
      Colors.white,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

class ContentSearch extends StatefulWidget {
  const ContentSearch({super.key});

  @override
  State<ContentSearch> createState() => _ContentSearchState();
}

class _ContentSearchState extends State<ContentSearch> {
  int index = 1;

  final screens = [
    const ContentHome(),
    const ContentSearch(),
    const ContentProfile(),
  ];

  final items = <Widget>[
    const Icon(Icons.home, size: 30),
    const Icon(Icons.search, size: 30),
    const Icon(Icons.favorite, size: 30),
    const Icon(Icons.settings, size: 30),
    const Icon(Icons.person, size: 30),
  ];

  // Function to get active coordinates from Firestore
  Future<Map<String, List<List<double>>>> getActiveCoordinates() async {
    Map<String, List<List<double>>> coordinatesMap = {};

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('active').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        String uid = doc.id; // Firebase UID (document name)
        double latitude = doc['latitude'];
        double longitude = doc['longitude'];

        if (!coordinatesMap.containsKey(uid)) {
          // If the uid is not already in the map, add it with an empty list
          coordinatesMap[uid] = [];
        }

        // Append latitude and longitude to the corresponding uid's list
        coordinatesMap[uid]!.add([latitude, longitude]);
      }
    } catch (e) {
      print("Error fetching active coordinates: $e");
    }

    return coordinatesMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Container(
        decoration: _backgroundDecoration,
        child: Column(
          children: [
            commonButton(context, "Get Active Coordinates", () async {
              // Call the function to get the active coordinates
              Map<String, List<List<double>>> coordinatesMap =
                  await getActiveCoordinates();

              // Print the result for demonstration
              coordinatesMap.forEach((uid, coordinates) {
                print("UID: $uid, Coordinates: $coordinates");
              });
            }),
          ],
        ),
      ),
    );
  }
}
