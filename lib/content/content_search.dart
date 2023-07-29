import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/content/content_home.dart';
import 'package:testapp/content/job_details_dialog.dart';
import 'package:testapp/utils/color_utils.dart';

import 'content_favorite.dart';
import 'content_profile.dart';
import 'content_settings.dart';

BoxDecoration _backgroundDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [
      hexStringToColor("#40c590"),
      hexStringToColor("#40c590"),
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
  final int _batchSize = 10; // Number of records to display at a time
  late ScrollController _scrollController;
  List<DocumentSnapshot> _allJobs = []; // To store all records from Firestore
  List<DocumentSnapshot> _filteredJobs =
      []; // To store filtered records based on search
  int _currentBatchSize = 0; // To track the current batch size to display
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchJobs();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchJobs() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('jobs').get();

      setState(() {
        _allJobs = querySnapshot.docs;
        _currentBatchSize = _batchSize;
        _filteredJobs = List.from(_allJobs);
      });
    } catch (e) {
      // Handle error
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Show more records when the user reaches the end of the list
      setState(() {
        _currentBatchSize += _batchSize;
      });
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final Map<String, dynamic>? data = job.data() as Map<String, dynamic>?;
        final String companyName = data?['companyName']?.toLowerCase() ?? '';
        final String location = data?['location']?.toLowerCase() ?? '';
        final String description = data?['description']?.toLowerCase() ?? '';
        return companyName.contains(query) ||
            location.contains(query) ||
            description.contains(query);
      }).toList();
    });
  }

  Widget _buildJobCard(DocumentSnapshot job) {
    final Map<String, dynamic>? data = job.data() as Map<String, dynamic>?;

    final bool hasCompanyLogo = data?.containsKey('companyLogo') ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: ListTile(
          leading: hasCompanyLogo
              ? CircleAvatar(
                  backgroundImage: NetworkImage(data!['companyLogo']),
                )
              : const CircleAvatar(
                  backgroundColor: Colors.green,
                ),
          title: Text(
            data?['companyName'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(data?['location'] ?? ''),
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
        ),
      ),
    );
  }

  int index = 1;

  final screens = [
    const ContentHome(),
    const ContentSearch(),
    const ContentFavorite(),
    const ContentSettings(),
    const ContentProfile()
  ];

  final items = <Widget>[
    const Icon(Icons.home, size: 30),
    const Icon(Icons.search, size: 30),
    const Icon(Icons.favorite, size: 30),
    const Icon(Icons.settings, size: 30),
    const Icon(Icons.person, size: 30)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _backgroundDecoration,
        child: Column(
          children: [
            const SizedBox(
                height: 30), // Add padding to bring the search bar down
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                color: Colors.white, // Set the background color to white
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Search Jobs",
                            border: InputBorder.none,
                          ),
                          onChanged: (_) {
                            _onSearchChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.all(16.0), // Add some padding to the list
                controller: _scrollController,
                itemCount: _currentBatchSize < _filteredJobs.length
                    ? _currentBatchSize +
                        1 // +1 for a loading indicator at the end
                    : _currentBatchSize,
                itemBuilder: (context, index) {
                  if (index < _filteredJobs.length) {
                    return _buildJobCard(_filteredJobs[index]);
                  } else if (_currentBatchSize < _filteredJobs.length) {
                    // Show a loading indicator at the end while more data is being fetched
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const SizedBox(); // Placeholder to avoid errors when reaching the end of the list
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
