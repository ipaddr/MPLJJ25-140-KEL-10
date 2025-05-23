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
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Statistik Detail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengajuan berdasarkan Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusBar(
                    'Baru',
                    applicationsByStatus['new'] ?? 0,
                    Colors.blue,
                  ),
                  _buildStatusBar(
                    'Diproses',
                    applicationsByStatus['processing'] ?? 0,
                    Colors.orange,
                  ),
                  _buildStatusBar(
                    'Disetujui',
                    applicationsByStatus['approved'] ?? 0,
                    Colors.green,
                  ),
                  _buildStatusBar(
                    'Ditolak',
                    applicationsByStatus['rejected'] ?? 0,
                    Colors.red,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pengguna berdasarkan Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusBar(
                    'Aktif',
                    usersByStatus['active'] ?? 0,
                    Colors.green,
                  ),
                  _buildStatusBar(
                    'Menunggu Verifikasi',
                    usersByStatus['pending'] ?? 0,
                    Colors.orange,
                  ),
                  _buildStatusBar(
                    'Ditangguhkan',
                    usersByStatus['suspended'] ?? 0,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor: value > 0 ? (value / 100).clamp(0.1, 1.0) : 0.1,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
