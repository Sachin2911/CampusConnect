import 'package:flutter/material.dart';

class JobDetailsDialog extends StatelessWidget {
  final String companyName;
  final String? companyLogo;
  final String description;
  final String location;
  final String position;
  final String deadline;

  const JobDetailsDialog({
    super.key,
    required this.companyName,
    this.companyLogo,
    required this.description,
    required this.location,
    required this.position,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (companyLogo != null)
                    Center(
                      child: Image.network(
                        companyLogo!,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  const SizedBox(height: 8.0),
                  Text(
                    companyName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(description),
                  const SizedBox(height: 8.0),
                  Text("Location: $location"),
                  const SizedBox(height: 8.0),
                  Text("Position: $position"),
                  const SizedBox(height: 8.0),
                  Text("Deadline: $deadline"),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
