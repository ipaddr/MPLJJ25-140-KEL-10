import 'package:flutter/material.dart';

class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<Color> gradient;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.gradient,
  });
}