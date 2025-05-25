import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminSubmissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> submission;
  final VoidCallback onViewDetail;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit; // ✅ NEW: Add edit callback

  const AdminSubmissionCardWidget({
    super.key,
    required this.submission,
    required this.onViewDetail,
    required this.onApprove,
    required this.onReject,
    required this.onEdit, // ✅ NEW: Required edit callback
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Colors.blue;
      case 'diproses':
      case 'reviewed':
        return Colors.orange;
      case 'disetujui':
      case 'approved':
        return Colors.green;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Icons.fiber_new_rounded;
      case 'diproses':
      case 'reviewed':
        return Icons.hourglass_empty_rounded;
      case 'disetujui':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'ditolak':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
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
    final formattedDate = submissionDate != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(submissionDate)
        : 'N/A';

    final submissionId = _safeGetString('id');
    final displayId = submissionId.length > 8 ? submissionId.substring(0, 8) : submissionId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetail,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _safeGetString('user_name', 'U')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _safeGetString('user_name', 'Nama tidak tersedia'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.1),
                            statusColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
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
                const SizedBox(height: 16),

                // Program Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Program Bantuan',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _safeGetString('program_name', 'Program tidak tersedia'),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ID and Actions Row
                Row(
                  children: [
                    // Submission ID
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ID: $displayId...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View Detail Button
                        _buildActionButton(
                          icon: Icons.visibility_rounded,
                          color: Colors.blue,
                          onPressed: onViewDetail,
                          tooltip: 'Lihat Detail',
                        ),
                        const SizedBox(width: 8),

                        // ✅ NEW: Edit Button (always available)
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: Colors.orange,
                          onPressed: onEdit,
                          tooltip: 'Edit Status',
                        ),

                        // Quick Action Buttons (only for pending statuses)
                        if (status.toLowerCase() == 'baru' || 
                            status.toLowerCase() == 'pending' || 
                            status.toLowerCase() == 'diproses' ||
                            status.toLowerCase() == 'reviewed') ...[
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.check_circle_rounded,
                            color: Colors.green,
                            onPressed: onApprove,
                            tooltip: 'Setujui',
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.cancel_rounded,
                            color: Colors.red,
                            onPressed: onReject,
                            tooltip: 'Tolak',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Helper method for consistent action buttons
  Widget _buildActionButton({
    required IconData icon,
    required MaterialColor color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: color.shade700,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}