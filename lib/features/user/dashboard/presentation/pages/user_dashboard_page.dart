import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extend body behind app bar for gradient
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      extendBody: true,
      // AppBar with gradient
      appBar: AppBar(title: const Text("Dashboard")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome banner
            Container(
              height: 120, // Adjust height as needed
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Feature cards in a column layout
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                // Wrap ListView in a Card for rounded corners and shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Program Bantuan Card
                      _buildFeatureCard(
                        context,
                        title: 'Lihat Program Bantuan',
                        imagePath: 'assets/images/credit_card.png',
                        onTap: () {
                          // Navigate to Program Explorer
                          context.go(RouteNames.programExplorer);
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Konsultasi AI Card
                      _buildFeatureCard(
                        context,
                        title: 'Konsultasi AI',
                        imagePath: 'assets/images/chat.png',
                        onTap: () {
                          context.goNamed('chatbot');
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Rekomendasi Program Card
                      _buildFeatureCard(
                        context,
                        title: 'Rekomendasi Program Saya',
                        imagePath: 'assets/images/growth.png',
                        onTap: () {
                          // Navigate to Personalized Recommendations
                          context.go(RouteNames.programRecommendations);
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Edukasi Card
                      _buildFeatureCard(
                        context,
                        title: 'Edukasi & Tips Keuangan',
                        imagePath: 'assets/images/education.png',
                        onTap: () {
                          context.goNamed('education');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 0, // Beranda is the first item
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white, // White card background as in the image
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ), // Slightly less rounded corners
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 40,
                height: 40,
              ), // Smaller icon size
              const SizedBox(height: 12.0), // Increased spacing
              Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
