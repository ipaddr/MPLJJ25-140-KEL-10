import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan kartu pengajuan dalam daftar pengajuan admin
class AdminSubmissionCardWidget extends StatelessWidget {
  final Map<String, dynamic> submission;
  final VoidCallback onViewDetail;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;

  // Constants for styling
  static const double _borderRadius = 20.0;
  static const double _itemBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 10.0;
  static const double _tinyBorderRadius = 8.0;
  
  static const double _spacing = 20.0;
  static const double _midSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _miniSpacing = 4.0;
  
  static const double _avatarSize = 50.0;
  static const double _iconSize = 20.0;
  static const double _smallIconSize = 16.0;
  static const double _microIconSize = 14.0;
  
  static const double _normalTextSize = 18.0;
  static const double _midTextSize = 14.0;
  static const double _smallTextSize = 12.0;

  const AdminSubmissionCardWidget({
    super.key,
    required this.submission,
    required this.onViewDetail,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
  });

  /// Menentukan warna berdasarkan status pengajuan
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

  /// Menentukan ikon berdasarkan status pengajuan
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

  /// Mendapatkan string dari Map dengan nilai default
  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = submission[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Mengecek apakah status pengajuan masih dalam proses
  bool _isInProcess(String status) {
    final lowerStatus = status.toLowerCase();
    return lowerStatus == 'baru' || 
           lowerStatus == 'pending' || 
           lowerStatus == 'diproses' ||
           lowerStatus == 'reviewed';
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
      margin: const EdgeInsets.only(bottom: _midSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
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
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(_spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(status, statusColor, statusIcon, formattedDate),
                const SizedBox(height: _midSpacing),
                _buildProgramInfo(),
                const SizedBox(height: _midSpacing),
                _buildActionRow(displayId, status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun baris header dengan informasi pengguna dan status
  Widget _buildHeaderRow(
    String status, 
    Color statusColor, 
    IconData statusIcon, 
    String formattedDate
  ) {
    return Row(
      children: [
        // Avatar
        _buildUserAvatar(),
        const SizedBox(width: _midSpacing),
        
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _safeGetString('user_name', 'Nama tidak tersedia'),
                style: const TextStyle(
                  fontSize: _normalTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: _miniSpacing),
              _buildDateInfo(formattedDate),
            ],
          ),
        ),
        
        // Status Badge
        _buildStatusBadge(status, statusColor, statusIcon),
      ],
    );
  }
  
  /// Membangun avatar pengguna
  Widget _buildUserAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(_itemBorderRadius),
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
            fontSize: _normalTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  /// Membangun informasi tanggal
  Widget _buildDateInfo(String formattedDate) {
    return Row(
      children: [
        Icon(
          Icons.schedule_rounded,
          size: _microIconSize,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: _miniSpacing),
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: _smallTextSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  /// Membangun badge status
  Widget _buildStatusBadge(String status, Color statusColor, IconData statusIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: 6
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: _smallIconSize, color: statusColor),
          const SizedBox(width: _tinySpacing),
          Text(
            status,
            style: TextStyle(
              fontSize: _smallTextSize,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun informasi program
  Widget _buildProgramInfo() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_tinySpacing),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(_tinyBorderRadius),
            ),
            child: const Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: _iconSize,
            ),
          ),
          const SizedBox(width: _smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Program Bantuan',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: _smallTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _safeGetString('program_name', 'Program tidak tersedia'),
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: _midTextSize,
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
    );
  }

  /// Membangun baris tindakan dengan ID dan tombol aksi
  Widget _buildActionRow(String displayId, String status) {
    return Row(
      children: [
        // Submission ID
        _buildSubmissionIdBadge(displayId),
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
            const SizedBox(width: _tinySpacing),

            // Edit Button (always available)
            _buildActionButton(
              icon: Icons.edit_rounded,
              color: Colors.orange,
              onPressed: onEdit,
              tooltip: 'Edit Status',
            ),

            // Quick Action Buttons (only for pending statuses)
            if (_isInProcess(status)) ...[
              const SizedBox(width: _tinySpacing),
              _buildActionButton(
                icon: Icons.check_circle_rounded,
                color: Colors.green,
                onPressed: onApprove,
                tooltip: 'Setujui',
              ),
              const SizedBox(width: _tinySpacing),
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
    );
  }
  
  /// Membangun badge ID pengajuan
  Widget _buildSubmissionIdBadge(String displayId) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _tinySpacing, 
        vertical: _miniSpacing
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_tinyBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tag_rounded,
            size: _microIconSize,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: _miniSpacing),
          Text(
            'ID: $displayId...',
            style: TextStyle(
              fontSize: _smallTextSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol aksi dengan warna dan ikon tertentu
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
        borderRadius: BorderRadius.circular(_microBorderRadius),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: _iconSize),
        color: color.shade700,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(_tinySpacing),
      ),
    );
  }
}