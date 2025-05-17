import 'package:flutter/material.dart';

class AdminProgramCardWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminProgramCardWidget({
    Key? key,
    required this.program,
    required this.onViewDetail,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return Colors.green;
      case 'Selesai':
        return Colors.orange;
      case 'Ditutup':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(program['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Program Name
            Text(
              program['nama_program'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Category and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori: ${program['kategori'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    program['status'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Total Submissions
            Text(
              'Pengajuan: ${program['jumlah_pengajuan'] ?? 0}',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12.0),
            // Action Buttons
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20.0),
                  color: Colors.blue,
                  onPressed: onViewDetail,
                  tooltip: 'Lihat Detail',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20.0),
                  color: Colors.orange,
                  onPressed: onEdit,
                  tooltip: 'Edit Program',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20.0),
                  color: Colors.red,
                  onPressed: onDelete,
                  tooltip: 'Hapus Program',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
