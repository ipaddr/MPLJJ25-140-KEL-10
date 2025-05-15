import 'package:flutter/material.dart';

class RecommendationCardWidget extends StatelessWidget {
  final String programName;
  final VoidCallback onTap;

  const RecommendationCardWidget({
    Key? key,
    required this.programName,
    required this.onTap,
  }) : super(key: key);

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
              programName, // Use the passed programName
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Deskripsi singkat atau alasan direkomendasikan.',
              style: TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onTap, // Use the passed onTap callback
                  child: const Text('Lihat Detail'),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement apply to program action
                  },
                  child: const Text('Ajukan Sekarang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
