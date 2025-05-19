import 'package:flutter/material.dart';

class AdminUserCardWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminUserCardWidget({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Terverifikasi':
        return Colors.green;
      case 'Menunggu Verifikasi':
        return Colors.orange;
      case 'Diblokir':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(user['status']);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Email
            Text(
              user['nama_lengkap'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              user['email'] ?? 'N/A',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12.0),
            // Additional Info (Location, Penghasilan)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lokasi: ${user['lokasi'] ?? 'N/A'}'),
                Text('Penghasilan: ${user['penghasilan'] ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 12.0),
            // Status and Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
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
                    user['status'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Action Buttons (Edit and Delete)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20.0),
                      color: Colors.blue,
                      onPressed: onEdit,
                      tooltip: 'Edit Pengguna',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20.0),
                      color: Colors.red,
                      onPressed: onDelete,
                      tooltip: 'Hapus Pengguna',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
