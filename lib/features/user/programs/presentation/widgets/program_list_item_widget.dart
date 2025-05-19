import 'package:flutter/material.dart';

class ProgramListItemWidget extends StatelessWidget {
  final String programName;
  final String programCategory;
  final VoidCallback onTap;

  const ProgramListItemWidget({
    super.key,
    required this.programName,
    required this.programCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              programName,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Kategori: $programCategory',
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: onTap, // Connect the callback here
                child: const Text('Lihat Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
