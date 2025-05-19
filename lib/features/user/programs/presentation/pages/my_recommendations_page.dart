import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/recommendation_card_widget.dart';

class MyRecommendationsPage extends StatelessWidget {
  const MyRecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> recommendedPrograms = [
      'Program Bantuan Kesehatan',
      'Beasiswa Pendidikan Anak',
      'Modal Usaha Kecil',
      'Bantuan Pangan Keluarga',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.userDashboard);
          },
        ),
        title: const Text(
          "Rekomendasi Program Saya",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
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
      ),
    );
  }
}
