import 'package:flutter/material.dart';

class OnboardingSliderWidget extends StatelessWidget {
  final int pageIndex; // Or any other parameter to determine content

  const OnboardingSliderWidget({super.key, required this.pageIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Onboarding Page ${pageIndex + 1}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
