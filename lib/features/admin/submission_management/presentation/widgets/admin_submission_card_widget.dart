import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class AdminSubmissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> submission;
  final VoidCallback onViewDetail;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const AdminSubmissionCardWidget({
    Key? key,
    required this.submission,
    required this.onViewDetail,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Baru':
        return Colors.blue;
      case 'Diproses':
        return Colors.orange;
      case 'Disetujui':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(submission['status']);
    final submissionDate = submission['submission_date'] as DateTime?;
    final formattedDate =
        submissionDate != null
            ? DateFormat('dd MMM yyyy').format(submissionDate)
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
            // User and Program Name
            Text(
              '${submission['user_name'] ?? 'N/A'} - ${submission['program_name'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    submission['status'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Submission Date
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
                  icon: const Icon(Icons.visibility, size: 20.0),
                  color: Colors.blue,
                  onPressed: onViewDetail,
                  tooltip: 'Lihat Detail',
                ),
                // Only show Approve/Reject for certain statuses (example: Baru, Diproses)
                if (submission['status'] == 'Baru' ||
                    submission['status'] == 'Diproses')
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 20.0,
                        ),
                        color: Colors.green,
                        onPressed: onApprove,
                        tooltip: 'Setujui',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 20.0),
                        color: Colors.red,
                        onPressed: onReject,
                        tooltip: 'Tolak',
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
