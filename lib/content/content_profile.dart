import 'package:flutter/material.dart';
import 'package:testapp/utils/color_utils.dart';

class ContentProfile extends StatefulWidget {
  const ContentProfile({super.key});

  @override
  State<ContentProfile> createState() => _ContentProfileState();
}

class _ContentProfileState extends State<ContentProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#40c590"),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Container(),
    );
  }
}
