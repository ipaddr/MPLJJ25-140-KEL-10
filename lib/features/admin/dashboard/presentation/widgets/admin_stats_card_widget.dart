import 'package:flutter/material.dart';

/// Widget kartu statistik untuk dashboard admin
class AdminStatisticCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

  // UI Constants
  static const double _cardWidth = 160;
  static const double _cardPadding = 12;
  static const double _iconContainerPadding = 6;
  static const double _borderRadius = 12;
  static const double _iconSize = 16;
  static const double _verticalSpacing = 8;
  static const double _tinySpacing = 4;
  static const double _titleFontSize = 11;
  static const double _valueFontSize = 24;
  static const double _trendFontSize = 8;
  static const double _trendIconSize = 8;

  const AdminStatisticCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      padding: const EdgeInsets.all(_cardPadding),
      decoration: _buildCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Icon and Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconContainer(),
              if (trend != null) _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: _verticalSpacing),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: _valueFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: _tinySpacing),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Membangun dekorasi kartu
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
      ),
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.8),
        width: 1,
      ),
    );
  }

  /// Membangun container ikon
  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(_iconContainerPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: _iconSize,
      ),
    );
  }

  /// Membangun indikator tren
  Widget _buildTrendIndicator() {
    final isTrendUp = trendUp ?? true;
    final trendColor = isTrendUp ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: trendColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTrendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: _trendIconSize,
            color: trendColor,
          ),
          const SizedBox(width: 2),
          Text(
            trend!,
            style: TextStyle(
              fontSize: _trendFontSize,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }
}