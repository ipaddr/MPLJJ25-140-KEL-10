import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/recommendation_card_widget.dart'; // Adjust import path as needed

class MyRecommendationsPage extends StatelessWidget {
  const MyRecommendationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Placeholder data - replace with data fetched from BLoC/Cubit
    final List<String> recommendedPrograms = [
      'Program Bantuan Kesehatan',
      'Beasiswa Pendidikan Anak',
      'Modal Usaha Kecil',
      'Bantuan Pangan Keluarga',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Rekomendasi Program Saya')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: recommendedPrograms.length,
        itemBuilder: (context, index) {
          return RecommendationCardWidget(
            programName: recommendedPrograms[index],
            onTap: () {
              // Generate a programId for demonstration purposes
              final String programId = 'rec-program-${index + 1}';

              // Navigate to program detail using GoRouter
              context.push(
                '/user/programs/$programId',
                extra: {
                  'isRecommended': true, // Coming from recommendations page
                },
              );
            },
          );
        },
      ),
    );
  }
}
