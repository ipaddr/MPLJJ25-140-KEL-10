import 'package:flutter/material.dart';
import '../../data/models/onboarding_data.dart';

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
    // Calculate responsive sizes - UKURAN DIPERKECIL DRASTIS
    final isSmallScreen = screenSize.height < 700;
    final iconSize =
        isSmallScreen
            ? screenSize.width * 0.2
            : screenSize.width * 0.22; // Diperkecil drastis
    final titleFontSize = isSmallScreen ? 16.0 : 18.0; // Diperkecil drastis
    final descriptionFontSize =
        isSmallScreen ? 11.0 : 12.0; // Diperkecil drastis

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main Icon - SANGAT KECIL
          Container(
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
              margin: EdgeInsets.all(isSmallScreen ? 8 : 10), // Sangat kecil
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
              child: Icon(
                data.icon,
                size: iconSize * 0.3, // Sangat kecil
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16), // Sangat kecil
          // Title - KOMPAK
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: data.color.withValues(alpha: 0.9),
              fontFamily: 'Poppins',
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: isSmallScreen ? 4 : 6), // Sangat kecil
          // Subtitle - MINI
          Container(
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
          ),

          SizedBox(height: isSmallScreen ? 8 : 12), // Sangat kecil
          // Description - SINGKAT
          Container(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: descriptionFontSize,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
                height: 1.2,
              ),
              maxLines: isSmallScreen ? 2 : 3, // Sangat dibatasi
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(height: isSmallScreen ? 8 : 12), // Sangat kecil
          // Feature highlights - MINI atau HILANG
          if (screenSize.height > 650) _buildFeatureHighlights(isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights(bool isSmallScreen) {
    List<String> features;

    switch (data.title) {
      case "Program Bantuan Sosial":
        features = ["Modal", "UMKM"]; // Diperpendek
        break;
      case "Chatbot AI Pintar":
        features = ["24/7", "AI"]; // Diperpendek
        break;
      case "Kesejahteraan Bersama":
        features = ["Progress", "Target"]; // Diperpendek
        break;
      default:
        features = [];
    }

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
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 2 : 3),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: data.color,
                size: isSmallScreen ? 8 : 10, // Sangat kecil
              ),
            ),
            SizedBox(height: isSmallScreen ? 2 : 3),
            Text(
              feature,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 7 : 8, // Sangat kecil
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
