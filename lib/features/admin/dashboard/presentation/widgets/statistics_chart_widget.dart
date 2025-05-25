import 'package:flutter/material.dart';

class StatisticsChartWidget extends StatelessWidget {
  final Map<String, int> applicationsByStatus;
  final Map<String, int> usersByStatus;

  const StatisticsChartWidget({
    super.key,
    required this.applicationsByStatus,
    required this.usersByStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16), // REDUCED from 20
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade50,
                  Colors.green.shade50.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // REDUCED from 8
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.green.shade700,
                    size: 18, // REDUCED from 20
                  ),
                ),
                const SizedBox(width: 10), // REDUCED from 12
                Text(
                  'Analisis Statistik',
                  style: TextStyle(
                    fontSize: 16, // REDUCED from 18
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
          ),

          // Content - SCROLLABLE UNTUK PREVENT OVERFLOW
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16), // REDUCED from 20
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applications Section
                  _buildSectionHeader(
                    'Pengajuan berdasarkan Status',
                    Icons.assignment_rounded,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12), // REDUCED from 16
                  _buildStatusBar(
                    'Baru',
                    applicationsByStatus['new'] ?? 0,
                    Colors.blue,
                    Icons.fiber_new_rounded,
                  ),
                  _buildStatusBar(
                    'Diproses',
                    applicationsByStatus['processing'] ?? 0,
                    Colors.orange,
                    Icons.hourglass_empty_rounded,
                  ),
                  _buildStatusBar(
                    'Disetujui',
                    applicationsByStatus['approved'] ?? 0,
                    Colors.green,
                    Icons.check_circle_rounded,
                  ),
                  _buildStatusBar(
                    'Ditolak',
                    applicationsByStatus['rejected'] ?? 0,
                    Colors.red,
                    Icons.cancel_rounded,
                  ),
                  const SizedBox(height: 20), // REDUCED from 24
                  // Users Section
                  _buildSectionHeader(
                    'Pengguna berdasarkan Status',
                    Icons.people_rounded,
                    Colors.teal,
                  ),
                  const SizedBox(height: 12), // REDUCED from 16
                  _buildStatusBar(
                    'Aktif',
                    usersByStatus['active'] ?? 0,
                    Colors.green,
                    Icons.person_rounded,
                  ),
                  _buildStatusBar(
                    'Menunggu Verifikasi',
                    usersByStatus['pending'] ?? 0,
                    Colors.orange,
                    Icons.pending_rounded,
                  ),
                  _buildStatusBar(
                    'Ditangguhkan',
                    usersByStatus['suspended'] ?? 0,
                    Colors.red,
                    Icons.person_off_rounded,
                  ),

                  // BOTTOM PADDING UNTUK PREVENT OVERFLOW
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4), // REDUCED from 6
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 14), // REDUCED from 16
        ),
        const SizedBox(width: 6), // REDUCED from 8
        Text(
          title,
          style: TextStyle(
            fontSize: 14, // REDUCED from 16
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, IconData icon) {
    final maxValue = _getMaxValue();
    final percentage = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4), // REDUCED from 6
      padding: const EdgeInsets.all(10), // REDUCED from 12
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10), // REDUCED from 12
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3), // REDUCED from 4
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: color, size: 12), // REDUCED from 14
              ),
              const SizedBox(width: 6), // REDUCED from 8
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12, // REDUCED from 14
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ), // REDUCED
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6), // REDUCED from 8
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 12, // REDUCED from 14
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6), // REDUCED from 8
          Container(
            height: 5, // REDUCED from 6
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2.5), // REDUCED from 3
            ),
            child: FractionallySizedBox(
              widthFactor: percentage < 0.05 ? 0.05 : percentage,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 3, // REDUCED from 4
                      offset: const Offset(0, 1.5), // REDUCED from (0, 2)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getMaxValue() {
    final allValues = [...applicationsByStatus.values, ...usersByStatus.values];
    return allValues.isEmpty ? 100 : allValues.reduce((a, b) => a > b ? a : b);
  }
}
