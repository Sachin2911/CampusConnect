import 'package:flutter/material.dart';
import 'package:testapp/utils/color_utils.dart';

class ContentSettings extends StatefulWidget {
  const ContentSettings({super.key});

  @override
  State<ContentSettings> createState() => _ContentSettingsState();
}

class _ContentSettingsState extends State<ContentSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hexStringToColor("#40c590"),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(),
    );
  }
}
