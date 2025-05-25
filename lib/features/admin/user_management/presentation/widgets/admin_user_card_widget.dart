import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      case 'Ditangguhkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Terverifikasi':
        return Icons.verified_user_rounded;
      case 'Menunggu Verifikasi':
        return Icons.hourglass_empty_rounded;
      case 'Ditangguhkan':
        return Icons.block_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = user[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    try {
      if (timestamp is Timestamp) {
        return DateFormat('dd MMM yyyy').format(timestamp.toDate());
      } else if (timestamp is DateTime) {
        return DateFormat('dd MMM yyyy').format(timestamp);
      } else if (timestamp is String) {
        final date = DateTime.tryParse(timestamp);
        if (date != null) {
          return DateFormat('dd MMM yyyy').format(date);
        }
      }
    } catch (e) {
      return 'N/A';
    }
    return 'N/A';
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'Belum pernah login';

    try {
      if (timestamp is Timestamp) {
        return DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate());
      } else if (timestamp is DateTime) {
        return DateFormat('dd MMM yyyy, HH:mm').format(timestamp);
      } else if (timestamp is String) {
        final date = DateTime.tryParse(timestamp);
        if (date != null) {
          return DateFormat('dd MMM yyyy, HH:mm').format(date);
        }
      }
    } catch (e) {
      return 'N/A';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_safeGetString('status'));
    final statusIcon = _getStatusIcon(_safeGetString('status'));
    final userId = _safeGetString('id');
    final displayId = userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // Optional tap handler
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
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _safeGetString('nama_lengkap', 'U')[0].toUpperCase(),
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
                            _safeGetString('nama_lengkap'),
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
                                Icons.tag_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: $displayId',
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
                            statusColor.withValues(alpha: 0.1),
                            statusColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            _safeGetString('status'),
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

                // Contact Information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.email_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _safeGetString('email'),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (_safeGetString('phone_number') != 'N/A') ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.phone_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _safeGetString('phone_number'),
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Location and Income
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.orange.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _safeGetString('lokasi'),
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: Colors.purple.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _safeGetString('penghasilan'),
                                style: TextStyle(
                                  color: Colors.purple.shade800,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Additional Info
                if (_safeGetString('job_type') != 'N/A') ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.work_rounded,
                          color: Colors.teal.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pekerjaan: ${_safeGetString('job_type')}',
                            style: TextStyle(
                              color: Colors.teal.shade800,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Date Information
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Terdaftar: ${_formatDate(user['created_at'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Login terakhir: ${_formatDateTime(user['last_login'])}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        color: Colors.blue.shade700,
                        onPressed: onEdit,
                        tooltip: 'Edit Pengguna',
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade50, Colors.red.shade100],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_rounded, size: 20),
                        color: Colors.red.shade700,
                        onPressed: onDelete,
                        tooltip: 'Hapus Pengguna',
                        padding: const EdgeInsets.all(8),
                      ),
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
}