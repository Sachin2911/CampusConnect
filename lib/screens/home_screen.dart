import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:testapp/content/content_favorite.dart';
import 'package:testapp/content/content_home.dart';
import 'package:testapp/content/content_profile.dart';
import 'package:testapp/content/content_search.dart';
import 'package:testapp/content/content_settings.dart';
import 'package:testapp/utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 1;

  final screens = [
    const ContentHome(),
    const ContentSearch(),
    const ContentFavorite(),
    const ContentSettings(),
    const ContentProfile()
  ];
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      const Icon(Icons.home, size: 30),
      const Icon(Icons.search, size: 30),
      const Icon(Icons.favorite, size: 30),
      const Icon(Icons.settings, size: 30),
      const Icon(Icons.person, size: 30)
    ];
    return Scaffold(
      backgroundColor: hexStringToColor("#87deb9"),
      body: screens[index],
      // body: Center(
      //   child: ElevatedButton(
      //       onPressed: () {
      //         FirebaseAuth.instance.signOut().then((value) {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => const SignInScreen()));
      //         });
      //       },
      //       child: const Text("Logout")),
      // ),
      bottomNavigationBar: CurvedNavigationBar(
        index: index,
        backgroundColor: hexStringToColor("#40c590"),
        height: 60,
        animationDuration: const Duration(milliseconds: 400),
        items: items,
        onTap: (index) => setState(() {
          // Setting index to the current index
          this.index = index;
        }),
      ),
    );
  }
}
