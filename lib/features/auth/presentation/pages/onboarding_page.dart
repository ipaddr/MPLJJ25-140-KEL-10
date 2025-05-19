import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Navigate to login page using GoRouter
      if (mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  void _skipPages() {
    // Navigate to login page using GoRouter
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: const [
                // Replace with your actual onboarding screen widgets
                OnboardingScreen(
                  imageAsset:
                      'assets/images/onboarding1.png', // Replace with your asset path
                  text:
                      "Dapatkan akses ke berbagai program bantuan sosial dan usaha mikro.",
                ),
                OnboardingScreen(
                  imageAsset:
                      'assets/images/onboarding2.png', // Replace with your asset path
                  text: "Konsultasikan kebutuhanmu dengan chatbot pintar kami.",
                ),
                OnboardingScreen(
                  imageAsset:
                      'assets/images/onboarding3.png', // Replace with your asset path
                  text:
                      "Bersama SocioCare, capai kesejahteraan yang kamu impikan.",
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_currentPage < 2)
                      ElevatedButton(
                        onPressed: _skipPages,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Lewati",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? "Mulai" : "Selanjutnya",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
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
}

// Basic placeholder widget for individual onboarding screens
class OnboardingScreen extends StatelessWidget {
  final String imageAsset;
  final String text;

  const OnboardingScreen({
    super.key,
    required this.imageAsset,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            height: 200, // Adjust as needed
          ),
          const SizedBox(height: 40),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
