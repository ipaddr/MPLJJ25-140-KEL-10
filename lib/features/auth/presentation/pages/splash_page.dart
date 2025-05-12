import 'package:flutter/material.dart';
import 'dart:async';
import 'package:socio_care/features/auth/presentation/pages/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Menambahkan timer untuk berpindah ke halaman onboarding setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for logo
            Image.asset(
              'assets/images/socio_care_logo.png', // Replace with your logo asset path
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            // Placeholder for tagline
            Text(
              'Akses Mudah, Hidup Sejahtera', // Replace with your tagline
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
