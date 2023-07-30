// ignore_for_file: non_constant_identifier_names, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../reusable_wdgets/reusable_widget.dart';
import '../utils/color_utils.dart';

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
  const ContentSearch({Key? key}) : super(key: key);

  @override
  State<ContentSearch> createState() => _ContentSearchState();
}

class _ContentSearchState extends State<ContentSearch> {
  List<String> group_names = [];
  List<int> group_sizes = [];
  List<String> filteredGroupNames = [];
  bool groupsFetched = false;
  String default_search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: _backgroundDecoration,
        child: Column(
          children: [
            uncommonButton(context, "Get Groups", () async {
              // Check if groups have already been fetched
              if (!groupsFetched) {
                FirebaseFirestore.instance.collection("groups").get().then(
                  (querySnapshot) {
                    print("Successfully completed");
                    setState(() {
                      group_names.clear();
                      group_sizes.clear();
                      filteredGroupNames.clear();
                      for (var docSnapshot in querySnapshot.docs) {
                        group_names.add(docSnapshot.id);
                        group_sizes.add(docSnapshot.data()['members'].length);
                        filteredGroupNames.addAll(group_names);
                        filteredGroupNames =
                            filteredGroupNames.toSet().toList();
                      }
                      print(group_names);
                      print(group_sizes);
                      groupsFetched = true;
                    });
                  },
                  onError: (e) => print("Error completing: $e"),
                );
              }
            }),
            Expanded(
              child: SizedBox(
                width: 350,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            filteredGroupNames = group_names
                                .where((name) => name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search for groups...',
                          hintStyle: TextStyle(color: Colors.white),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredGroupNames.length,
                        itemBuilder: (context, index) {
                          return _buildGroupCard(
                            filteredGroupNames[index],
                            group_sizes[
                                group_names.indexOf(filteredGroupNames[index])],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(String groupName, int groupSize) {
    return Card(
      elevation: 12.0,
      child: ListTile(
        title: Text(
          groupName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text("Group Size: $groupSize"),
      ),
    );
  }
}
