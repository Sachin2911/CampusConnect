import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/content/job_details_dialog.dart';
import 'package:testapp/screens/home_screen.dart';

class ContentFavorite extends StatefulWidget {
  const ContentFavorite({super.key});

  @override
  State<ContentFavorite> createState() => _ContentFavoriteState();
}

class _ContentFavoriteState extends State<ContentFavorite>
    with SingleTickerProviderStateMixin {
  final int _totalProfiles = 7; // Number of profiles to display
  final List<Color> _swipeColors = [Colors.red, Colors.green];
  final List<IconData> _swipeIcons = [Icons.thumb_down, Icons.thumb_up];
  int _currentIndex = 0;
  List<DocumentSnapshot> _profiles = []; // To store all profiles from Firestore

  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetchProfiles() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('jobs').get();

      setState(() {
        _profiles = querySnapshot.docs;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _handleSwipe(bool liked) {
    if (_currentIndex < _totalProfiles) {
      setState(() {
        _currentIndex++;
      });

      if (_currentIndex == _totalProfiles) {
        // After the last profile, show "Test Complete" dialog
        showDialog(
          context: context,
          builder: (context) => _buildSwipeDialog(
            liked ? "Test Complete" : "Test Incomplete",
            liked,
          ),
        );

        // Wait for 3 seconds before navigating to ContentHome
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        });
      } else {
        // After each swipe, show the next profile and animate thumbs up/down
        showAnimatedDialog(context, liked);
      }
    }
  }

  void showAnimatedDialog(BuildContext context, bool liked) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSwipeDialog(
        liked ? "Great!!" : "I Agree",
        liked,
      ),
    );
    _controller.forward(from: 0.0).whenCompleteOrCancel(() {
      Navigator.of(context).pop();
    });
  }

  Widget _buildSwipeDialog(String message, bool liked) {
    final bool isTestComplete = message == "Test Complete";
    final IconData iconData =
        isTestComplete ? Icons.check_circle : _swipeIcons[liked ? 1 : 0];
    final Color backgroundColor =
        isTestComplete ? Colors.blue : _swipeColors[liked ? 1 : 0];

    return Center(
      child: SlideTransition(
        position: _animation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconData,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Start Matching"),
      ),
      body: _currentIndex < _totalProfiles
          ? _profiles.isNotEmpty // Check if _profiles list is not empty
              ? _buildProfileCard(_profiles[_currentIndex])
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : const Center(
              child: Text("Test Complete"),
            ),
    );
  }

  Widget _buildProfileCard(DocumentSnapshot profile) {
    final Map<String, dynamic>? data = profile.data() as Map<String, dynamic>?;

    return GestureDetector(
      onTap: () {
        // Show the custom dialog when the card is tapped
        showDialog(
          context: context,
          builder: (context) => JobDetailsDialog(
            companyName: data?['companyName'] ?? '',
            companyLogo: data?['companyLogo'],
            description: data?['description'] ?? '',
            location: data?['location'] ?? '',
            position: data?['position'] ?? '',
            deadline: data?['deadline'] ?? '',
          ),
        );
      },
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          _handleSwipe(true); // Swipe right (liked)
        } else if (details.delta.dx < 0) {
          _handleSwipe(false); // Swipe left (disliked)
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildJobCardHeader(data),
            const SizedBox(height: 16),
            Expanded(
              child: _buildJobCardContent(data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCardHeader(Map<String, dynamic>? data) {
    final bool hasCompanyLogo = data?.containsKey('companyLogo') ?? false;

    return Row(
      children: [
        if (hasCompanyLogo)
          CircleAvatar(
            backgroundImage: NetworkImage(data?['companyLogo'] ?? ''),
          )
        else
          const CircleAvatar(
            backgroundColor: Colors.green,
          ),
        const SizedBox(width: 16),
        Expanded(
          // Wrap the company name with Expanded
          child: Text(
            data?['companyName'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildJobCardContent(Map<String, dynamic>? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          data?['position'] ?? '',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data?['description'] ?? '',
          maxLines: 17, // Limit the description to 5 lines
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Deadline: ${data?['deadline'] ?? ''}",
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
