import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradeovl/reusable_wdgets/reusable_widget.dart';
import 'package:gradeovl/screens/home_screen.dart';
import 'package:gradeovl/utils/color_utils.dart';
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

  // Define the options for year of study and degree
  final List<String> yearOfStudyOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
  ];
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedYear = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Drop-down for degree
                DropdownButtonFormField<String>(
                  value: _selectedDegree,
                  items: degreeOptions.map((String degree) {
                    return DropdownMenuItem<String>(
                      value: degree,
                      child: Text(degree),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDegree = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                commonButton(context, "SIGN UP", () {
                  // Now you can use the selected values of year of study and degree
                  String selectedYear = _selectedYear;
                  String selectedDegree = _selectedDegree;

                  final CollectionReference usersCollection =
                      FirebaseFirestore.instance.collection('users');
                  usersCollection.doc(_emailTextController.text).set({
                    'year': _selectedYear,
                    'degree': _selectedDegree,
                    'email': _emailTextController.text,
                  }).then((_) {
                    print("User data stored successfully!");
                  }).catchError((error) {
                    print("Failed to store user data: $error");
                  });
                  // Your sign-up logic here
                  FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text)
                      .then((value) {
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
