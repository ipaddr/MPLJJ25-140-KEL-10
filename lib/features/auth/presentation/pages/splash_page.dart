import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Using Timer to navigate to onboarding after 3 seconds
    Timer(const Duration(seconds: 3), () {
      // Use GoRouter instead of Navigator
      if (mounted) {
        context.go(RouteNames.onboarding);
      }
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
