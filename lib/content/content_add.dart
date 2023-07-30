import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusconectv2/reusable_wdgets/reusable_widget.dart';
import 'package:campusconectv2/screens/home_screen.dart';
import 'package:campusconectv2/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'content_territory.dart';

class ContentAdd extends StatefulWidget {
  const ContentAdd({super.key});

  @override
  State<ContentAdd> createState() => _ContentAddState();
}

class _ContentAddState extends State<ContentAdd> {
  // Controllers for group and desc
  final TextEditingController _groupNameTextController =
      TextEditingController();
  final TextEditingController _groupDescTextController =
      TextEditingController();

  //Function to open a dialogue box that displays an adapted version of the home map
  void _showMapPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Map"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
            child:
                const ContentTerritory(), // Your ContentHome widget with the map
          ),
        );
      },
    );
  }

  final List<String> yearOfStudyOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
  ];
  //List of degree options for the dropdown
  final List<String> degreeOptions = [
    'Computer Sciences',
    'Mechanical Engineering',
    'Biomedical Engineering'
  ];
  User? user = FirebaseAuth.instance.currentUser;

  final String _selectedYear = '1st Year'; // Default value for year of study
  String _selectedDegree = 'Computer Sciences';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: hexStringToColor("#0e81ed"),
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 350,
              child: Column(children: [
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Group Name", Icons.person_outline, false,
                    _groupNameTextController),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Description", Icons.person_outline, false,
                    _groupDescTextController),
                const SizedBox(
                  height: 30,
                ),
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                        value: _selectedDegree,
                        items: degreeOptions.map((String degree) {
                          return DropdownMenuItem<String>(
                            value: degree,
                            child: Text(
                              degree,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDegree = newValue!;
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ))),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownButtonFormField<String>(
                        value: _selectedYear,
                        items: yearOfStudyOptions.map((String degree) {
                          return DropdownMenuItem<String>(
                            value: degree,
                            child: Text(
                              degree,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDegree = newValue!;
                          });
                        },
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ))),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: GestureDetector(
                    onTap: _showMapPopup,
                    child: logoWidget('assets/images/castle.png'),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text('Pick your base!!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(
                  height: 15,
                ),
                commonButton(context, 'Create Group!!', () {
                  final CollectionReference usersCollection =
                      FirebaseFirestore.instance.collection('groups');
                  usersCollection.doc(_groupNameTextController.text).set({
                    'members': [user?.uid],
                    'description': _groupDescTextController.text,
                    'year': _selectedYear,
                    'degree': _selectedDegree,
                  }).then((value) => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const HomeScreen()))
                      });
                }),
              ]),
            ),
          ],
        ));
  }
}
