import 'package:flutter/material.dart';

class AdminStatisticCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool? trendUp;

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
      width: 160, // REDUCED from 180
      padding: const EdgeInsets.all(12), // REDUCED from 16
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(12), // REDUCED from 16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08), // REDUCED opacity
            blurRadius: 8, // REDUCED from 15
            offset: const Offset(0, 4), // REDUCED from (0, 6)
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ADDED to prevent overflow
        children: [
          // Header with Icon and Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6), // REDUCED from 10
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8), // REDUCED from 10
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16, // REDUCED from 20
                ),
              ),
              if (trend != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ), // REDUCED
                  decoration: BoxDecoration(
                    color:
                        (trendUp ?? true)
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          (trendUp ?? true)
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (trendUp ?? true)
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 8, // REDUCED from 10
                        color: (trendUp ?? true) ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          fontSize: 8, // REDUCED from 9
                          fontWeight: FontWeight.w600,
                          color: (trendUp ?? true) ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8), // REDUCED from 12
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 24, // REDUCED from 28
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4), // REDUCED from 6
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 11, // REDUCED from 12
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
}
