import 'package:flutter/material.dart';

/// Model class untuk data onboarding
///
/// Menyimpan seluruh informasi yang diperlukan untuk menampilkan
/// satu halaman dalam onboarding sequence
class OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final List<Color> gradient;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.gradient,
  });
}