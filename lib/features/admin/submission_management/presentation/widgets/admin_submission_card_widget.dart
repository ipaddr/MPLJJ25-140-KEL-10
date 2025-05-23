import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminSubmissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> submission;
  final VoidCallback onViewDetail;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const AdminSubmissionCardWidget({
    super.key,
    required this.submission,
    required this.onViewDetail,
    required this.onApprove,
    required this.onReject,
  });

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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Baru':
        return Icons.new_releases;
      case 'Diproses':
        return Icons.hourglass_empty;
      case 'Disetujui':
        return Icons.check_circle;
      case 'Ditolak':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = submission[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final status = _safeGetString('status', 'Baru');
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final submissionDate = submission['submission_date'] as DateTime?;
    final formattedDate =
        submissionDate != null
            ? DateFormat('dd MMM yyyy, HH:mm').format(submissionDate)
            : 'N/A';

    final submissionId = _safeGetString('id');
    final displayId =
        submissionId.length > 8 ? submissionId.substring(0, 8) : submissionId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'ID: $displayId...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // User Name
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _safeGetString('user_name', 'Nama tidak tersedia'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Program Name
              Row(
                children: [
                  Icon(Icons.assignment, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _safeGetString('program_name', 'Program tidak tersedia'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Submission Date
              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Diajukan: $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // View Detail Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.visibility, size: 20.0),
                      color: Colors.blue,
                      onPressed: onViewDetail,
                      tooltip: 'Lihat Detail',
                      padding: const EdgeInsets.all(8),
                    ),
                  ),

                  // Show Approve/Reject buttons only for pending statuses
                  if (status == 'Baru' || status == 'Diproses') ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.check_circle_outline,
                          size: 20.0,
                        ),
                        color: Colors.green,
                        onPressed: onApprove,
                        tooltip: 'Setujui',
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.cancel_outlined, size: 20.0),
                        color: Colors.red,
                        onPressed: onReject,
                        tooltip: 'Tolak',
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
