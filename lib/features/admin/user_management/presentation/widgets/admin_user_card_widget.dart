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
      print('Error formatting date: $e');
    }

    return 'N/A';
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

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
      print('Error formatting datetime: $e');
    }

    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_safeGetString('status'));
    final userId = _safeGetString('id');
    final displayId =
        userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

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
              // Header Row with Name and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _safeGetString('nama_lengkap'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: $displayId',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
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
                      _safeGetString('status'),
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Contact Information
              Row(
                children: [
                  Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _safeGetString('email'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),

              if (_safeGetString('phone_number') != 'N/A') ...[
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      _safeGetString('phone_number'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
              ],

              // Location and Income
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _safeGetString('lokasi'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      Text(
                        _safeGetString('penghasilan'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Additional Info (if available)
              if (_safeGetString('job_type') != 'N/A') ...[
                Row(
                  children: [
                    Icon(Icons.work, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pekerjaan: ${_safeGetString('job_type')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
              ],

              // Registration Date (if available)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terdaftar: ${_formatDate(user['created_at'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),

              // Last Login (if available)
              Row(
                children: [
                  Icon(Icons.login, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Login terakhir: ${_formatDateTime(user['last_login'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 20.0),
                      color: Colors.blue,
                      onPressed: onEdit,
                      tooltip: 'Edit Pengguna',
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
                      icon: const Icon(Icons.delete, size: 20.0),
                      color: Colors.red,
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
    );
  }
}
