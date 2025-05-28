import 'package:flutter/material.dart';
import '../../data/models/onboarding_data.dart';

/// Widget slider untuk halaman onboarding
///
/// Menampilkan konten setiap slide onboarding dengan
/// icon, judul, subjudul, dan deskripsi
class OnboardingSliderWidget extends StatelessWidget {
  final OnboardingData data;
  final Size screenSize;

  const OnboardingSliderWidget({
    super.key,
    required this.data,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive sizes
    final isSmallScreen = screenSize.height < 700;
    final iconSize =
        isSmallScreen ? screenSize.width * 0.2 : screenSize.width * 0.22;
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final descriptionFontSize = isSmallScreen ? 11.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMainIcon(iconSize, isSmallScreen),
          SizedBox(height: isSmallScreen ? 12 : 16),
          _buildTitle(titleFontSize),
          SizedBox(height: isSmallScreen ? 4 : 6),
          _buildSubtitle(isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildDescription(descriptionFontSize, isSmallScreen),
          SizedBox(height: isSmallScreen ? 8 : 12),
          if (screenSize.height > 650) _buildFeatureHighlights(isSmallScreen),
        ],
      ),
    );
  }

  /// Widget ikon utama
  Widget _buildMainIcon(double iconSize, bool isSmallScreen) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            data.gradient[0].withValues(alpha: 0.15),
            data.gradient[1].withValues(alpha: 0.08),
            Colors.transparent,
          ],
          stops: const [0.3, 0.7, 1.0],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(isSmallScreen ? 8 : 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: data.color.withValues(alpha: 0.25),
              blurRadius: isSmallScreen ? 6 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(data.icon, size: iconSize * 0.3, color: Colors.white),
      ),
    );
  }

  /// Widget judul
  Widget _buildTitle(double fontSize) {
    return Text(
      data.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: data.color.withValues(alpha: 0.9),
        fontFamily: 'Poppins',
        height: 1.1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Widget subjudul
  Widget _buildSubtitle(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: data.color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Text(
        data.subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isSmallScreen ? 9 : 10,
          fontWeight: FontWeight.w600,
          color: data.color.withValues(alpha: 0.8),
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Widget deskripsi
  Widget _buildDescription(double fontSize, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
      child: Text(
        data.description,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade700,
          fontFamily: 'Poppins',
          height: 1.2,
        ),
        maxLines: isSmallScreen ? 2 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Widget highlight fitur
  Widget _buildFeatureHighlights(bool isSmallScreen) {
    final features = _getFeatures();

    if (features.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            features
                .map((feature) => _buildFeatureItem(feature, isSmallScreen))
                .toList(),
      ),
    );
  }

  /// Mendapatkan fitur berdasarkan judul
  List<String> _getFeatures() {
    switch (data.title) {
      case "Program Bantuan Sosial":
        return ["Modal", "UMKM"];
      case "Chatbot AI Pintar":
        return ["24/7", "AI"];
      case "Kesejahteraan Bersama":
        return ["Progress", "Target"];
      default:
        return [];
    }
  }

  /// Widget item fitur
  Widget _buildFeatureItem(String feature, bool isSmallScreen) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 4 : 6,
          horizontal: isSmallScreen ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: data.color.withValues(alpha: 0.15),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFeatureIcon(isSmallScreen),
            SizedBox(height: isSmallScreen ? 2 : 3),
            _buildFeatureText(feature, isSmallScreen),
          ],
        ),
      ),
    );
  }

  /// Widget ikon fitur
  Widget _buildFeatureIcon(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 2 : 3),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_rounded,
        color: data.color,
        size: isSmallScreen ? 8 : 10,
      ),
    );
  }

  /// Widget teks fitur
  Widget _buildFeatureText(String feature, bool isSmallScreen) {
    return Text(
      feature,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isSmallScreen ? 7 : 8,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
        fontFamily: 'Poppins',
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
