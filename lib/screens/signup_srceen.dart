// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusconectv2/reusable_wdgets/reusable_widget.dart';
import 'package:campusconectv2/screens/home_screen.dart';
import 'package:campusconectv2/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();

  String _selectedYear = '1st Year'; // Default value for year of study
  String _selectedDegree = 'Computer Sciences'; // Default value for degree

  // List of options for the year of study for drop-down
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("#1835f0"),
          hexStringToColor("#283cbf"),
          Colors.white,
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                reusableTextField("First Name", Icons.person_outline, false,
                    _nameTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Email", Icons.person_outline, false,
                    _emailTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outline, true,
                    _passwordTextController),
                const SizedBox(height: 20),
                // Drop-down for year of study
                DropdownButtonFormField<String>(
                    value: _selectedYear,
                    items: yearOfStudyOptions.map((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedYear = newValue!;
                      });
                    },
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                        // Customize the underline of the dropdown
                        enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ))),
                const SizedBox(height: 20),
                // Drop-down for degree
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
                    //Changing the color of the arrow and the underline of the dropdown
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                        // Customize the underline of the dropdown
                        enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    )) // Set the color of the underline
                    ),

                const SizedBox(height: 20),

                commonButton(context, "SIGN UP", () {
                  //Ensures that the email ends with wits.ac.za
                  if (!_emailTextController.text
                      .endsWith("students.wits.ac.za")) {
                    // Show an error message if the email address is invalid
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: const Text(
                              "Invalid email address. Please use a students.wits.ac.za email."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                    return;
                  }
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
                    User? user = FirebaseAuth.instance.currentUser;
                    String? uid = user?.uid;
                    final CollectionReference usersCollection =
                        FirebaseFirestore.instance.collection('users');
                    usersCollection.doc(uid).set({
                      'name': _nameTextController.text,
                      'year': _selectedYear,
                      'degree': _selectedDegree,
                      'studentnr': _emailTextController.text.substring(0, 7),
                      'email': _emailTextController.text,
                    }).then((_) {
                      print("User data stored successfully!");
                    }).catchError((error) {
                      print("Failed to store user data: $error");
                    });
                  }).then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                  }).onError((error, stackTrace) {});
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
