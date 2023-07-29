// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campusconectv2/reusable_wdgets/reusable_widget.dart';
import 'package:campusconectv2/screens/home_screen.dart';
import 'package:campusconectv2/screens/reset_password.dart';
import 'package:campusconectv2/screens/signup_srceen.dart';
import 'package:campusconectv2/services/firebase_services.dart';
import 'package:campusconectv2/utils/color_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              logoWidget('assets/images/CampusConnect.png'),
              const SizedBox(
                height: 30,
              ),
              reusableTextField("Enter Username", Icons.person_outline, false,
                  _emailTextController),
              const SizedBox(height: 20),
              reusableTextField("Enter Password", Icons.lock_outline, true,
                  _passwordTextController),
              forgetPassword(context),
              commonButton(context, "LOG IN", () {
                FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: _emailTextController.text,
                        password: _passwordTextController.text)
                    .then((value) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                });
              }),
              signUpOption(),
              commonButton(context, "GOOGLE LOGIN", () async {
                await FirebaseServices().signInWithGoogle();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              })
            ],
          ),
        )),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have account? ",
            style: TextStyle(color: hexStringToColor("#283cbf"))),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpScreen()));
          },
          child: Text(
            "Sign Up",
            style: TextStyle(
                color: hexStringToColor("#f2f3fa"),
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}

Widget forgetPassword(BuildContext context) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ResetPassword()));
        },
      ));
}
