import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminContentCardWidget extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminContentCardWidget({
    Key? key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dipublikasikan':
        return Colors.green;
      case 'Draf':
        return Colors.orange;
      case 'Diarsip':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(content['status']);
    final publishDate = content['publish_date'] as DateTime?;
    final formattedDate =
        publishDate != null
            ? DateFormat('dd MMM yyyy').format(publishDate)
            : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              content['title'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8.0),
            // Status and Date
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
                    content['status'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Publish Date
                Text(
                  'Tanggal: $formattedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            // Action Buttons
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Align buttons to the right
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20.0),
                  color: Colors.orange,
                  onPressed: onEdit,
                  tooltip: 'Edit Konten',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20.0),
                  color: Colors.red,
                  onPressed: onDelete,
                  tooltip: 'Hapus Konten',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
