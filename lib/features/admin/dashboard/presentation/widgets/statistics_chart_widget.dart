import 'package:flutter/material.dart';

/// Widget untuk menampilkan grafik statistik
class StatisticsChartWidget extends StatelessWidget {
  final Map<String, int> applicationsByStatus;
  final Map<String, int> usersByStatus;

  // UI Constants
  static const double _borderRadius = 20;
  static const double _contentPadding = 16;
  static const double _iconSize = 18;
  static const double _smallIconSize = 14;
  static const double _microIconSize = 12;
  static const double _sectionSpacing = 20;
  static const double _itemSpacing = 12;
  static const double _smallSpacing = 6;
  static const double _progressBarHeight = 5;
  static const double _statusBarMargin = 4;
  static const double _headerFontSize = 16;
  static const double _sectionFontSize = 14;
  static const double _labelFontSize = 12;
  static const double _microFontSize = 12;

  const StatisticsChartWidget({
    super.key,
    required this.applicationsByStatus,
    required this.usersByStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content - Scrollable to prevent overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applications Section
                  _buildSectionHeader(
                    'Pengajuan berdasarkan Status',
                    Icons.assignment_rounded,
                    Colors.purple,
                  ),
                  const SizedBox(height: _itemSpacing),
                  _buildStatusBars(applicationsByStatus),
                  
                  const SizedBox(height: _sectionSpacing),
                  
                  // Users Section
                  _buildSectionHeader(
                    'Pengguna berdasarkan Status',
                    Icons.people_rounded,
                    Colors.teal,
                  ),
                  const SizedBox(height: _itemSpacing),
                  _buildUserStatusBars(),
                  
                  // Bottom padding to prevent overflow
                  const SizedBox(height: _sectionSpacing),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun dekorasi container utama
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.white.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.8)),
    );
  }

  /// Membangun header widget
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_contentPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.green.shade50.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_smallSpacing),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_smallSpacing),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              color: Colors.green.shade700,
              size: _iconSize,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Analisis Statistik',
            style: TextStyle(
              fontSize: _headerFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun header section
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_smallSpacing),
          ),
          child: Icon(icon, color: color, size: _smallIconSize),
        ),
        const SizedBox(width: _smallSpacing),
        Text(
          title,
          style: TextStyle(
            fontSize: _sectionFontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Membangun bars untuk status aplikasi
  Widget _buildStatusBars(Map<String, int> statusData) {
    return Column(
      children: [
        _buildStatusBar(
          'Baru',
          statusData['new'] ?? 0,
          Colors.blue,
          Icons.fiber_new_rounded,
        ),
        _buildStatusBar(
          'Diproses',
          statusData['processing'] ?? 0,
          Colors.orange,
          Icons.hourglass_empty_rounded,
        ),
        _buildStatusBar(
          'Disetujui',
          statusData['approved'] ?? 0,
          Colors.green,
          Icons.check_circle_rounded,
        ),
        _buildStatusBar(
          'Ditolak',
          statusData['rejected'] ?? 0,
          Colors.red,
          Icons.cancel_rounded,
        ),
      ],
    );
  }

  /// Membangun bars untuk status pengguna
  Widget _buildUserStatusBars() {
    return Column(
      children: [
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
      ],
    );
  }

  /// Membangun bar status individual
  Widget _buildStatusBar(String label, int value, Color color, IconData icon) {
    final maxValue = _getMaxValue();
    final percentage = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: _statusBarMargin),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: color, size: _microIconSize),
              ),
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: _labelFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildValueBadge(value, color),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          _buildProgressBar(percentage, color),
        ],
      ),
    );
  }

  /// Membangun badge nilai
  Widget _buildValueBadge(int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_smallSpacing),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: _microFontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// Membangun progress bar
  Widget _buildProgressBar(double percentage, Color color) {
    return Container(
      height: _progressBarHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_progressBarHeight / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: percentage < 0.05 ? 0.05 : percentage,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(_progressBarHeight / 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mendapatkan nilai maksimum untuk persentase bar
  int _getMaxValue() {
    final allValues = [...applicationsByStatus.values, ...usersByStatus.values];
    return allValues.isEmpty ? 100 : allValues.reduce((a, b) => a > b ? a : b);
  }
}