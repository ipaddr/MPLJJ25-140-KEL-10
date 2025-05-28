import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget to display user information in a card format for admin interface
class AdminUserCardWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // UI Constants
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;
  static const double _miniBorderRadius = 8.0;

  static const double _spacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _miniSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _microTinySpacing = 4.0;

  static const double _avatarSize = 50.0;
  static const double _largeIconSize = 20.0;
  static const double _iconSize = 16.0;
  static const double _smallIconSize = 14.0;

  static const double _titleFontSize = 18.0;
  static const double _bodyFontSize = 14.0;
  static const double _smallFontSize = 13.0;
  static const double _captionFontSize = 12.0;

  const AdminUserCardWidget({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  /// Get color based on user status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terverifikasi':
      case 'active':
        return Colors.green;
      case 'menunggu verifikasi':
      case 'pending':
      case 'inactive':
        return Colors.orange;
      case 'ditangguhkan':
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on user status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'terverifikasi':
      case 'active':
        return Icons.verified_user_rounded;
      case 'menunggu verifikasi':
      case 'pending':
      case 'inactive':
        return Icons.hourglass_empty_rounded;
      case 'ditangguhkan':
      case 'suspended':
        return Icons.block_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Safely retrieve string values from user map
  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = user[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Format date for display
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
      // Handle silently
    }
    return 'N/A';
  }

  /// Format date and time for display
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
      // Handle silently
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_safeGetString('status'));
    final statusIcon = _getStatusIcon(_safeGetString('status'));
    final userId = _safeGetString('id');
    final displayId =
        userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;

    return Container(
      margin: const EdgeInsets.only(bottom: _smallSpacing),
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
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () {}, // Optional tap handler
          child: Padding(
            padding: const EdgeInsets.all(_spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(statusColor, statusIcon, displayId),
                const SizedBox(height: _smallSpacing),
                _buildContactInformation(),
                const SizedBox(height: _smallSpacing),
                _buildLocationAndIncome(),
                const SizedBox(height: _smallSpacing),
                _buildJobInfo(),
                _buildDateInformation(),
                const SizedBox(height: _smallSpacing),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the user header section with avatar and status
  Widget _buildUserHeader(
    Color statusColor,
    IconData statusIcon,
    String displayId,
  ) {
    return Row(
      children: [
        // Avatar
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(_smallBorderRadius),
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
              _safeGetString('nama_lengkap', 'U')[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: _titleFontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: _smallSpacing),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _safeGetString('nama_lengkap'),
                style: const TextStyle(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: _microTinySpacing),
              Row(
                children: [
                  Icon(
                    Icons.tag_rounded,
                    size: _smallIconSize,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: _microTinySpacing),
                  Text(
                    'ID: $displayId',
                    style: TextStyle(
                      fontSize: _captionFontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Status Badge
        _buildStatusBadge(statusColor, statusIcon),
      ],
    );
  }

  /// Build the status badge for user
  Widget _buildStatusBadge(Color statusColor, IconData statusIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _microSpacing,
        vertical: _tinySpacing,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: _iconSize, color: statusColor),
          const SizedBox(width: _tinySpacing),
          Text(
            _safeGetString('status'),
            style: TextStyle(
              fontSize: _captionFontSize,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build contact information section
  Widget _buildContactInformation() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_rounded,
            iconColor: Colors.blue.shade600,
            containerColor: Colors.blue.shade600,
            text: _safeGetString('email'),
            textColor: Colors.blue.shade800,
          ),
          if (_safeGetString('phone_number') != 'N/A') ...[
            const SizedBox(height: _miniSpacing),
            _buildInfoRow(
              icon: Icons.phone_rounded,
              iconColor: Colors.green.shade600,
              containerColor: Colors.green.shade600,
              text: _safeGetString('phone_number'),
              textColor: Colors.green.shade800,
            ),
          ],
        ],
      ),
    );
  }

  /// Build location and income row
  Widget _buildLocationAndIncome() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            backgroundColor: Colors.orange.shade50,
            borderColor: Colors.orange.shade200,
            icon: Icons.location_on_rounded,
            iconColor: Colors.orange.shade600,
            text: _safeGetString('lokasi'),
            textColor: Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: _microSpacing),
        Expanded(
          child: _buildInfoCard(
            backgroundColor: Colors.purple.shade50,
            borderColor: Colors.purple.shade200,
            icon: Icons.attach_money_rounded,
            iconColor: Colors.purple.shade600,
            text: _safeGetString('penghasilan'),
            textColor: Colors.purple.shade800,
            fontSize: _smallFontSize,
          ),
        ),
      ],
    );
  }

  /// Build job information if available
  Widget _buildJobInfo() {
    if (_safeGetString('job_type') == 'N/A') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildInfoCard(
          backgroundColor: Colors.teal.shade50,
          borderColor: Colors.teal.shade200,
          icon: Icons.work_rounded,
          iconColor: Colors.teal.shade600,
          text: 'Pekerjaan: ${_safeGetString('job_type')}',
          textColor: Colors.teal.shade800,
        ),
        const SizedBox(height: _smallSpacing),
      ],
    );
  }

  /// Build date information section
  Widget _buildDateInformation() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: _iconSize,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: _tinySpacing),
                  Expanded(
                    child: Text(
                      'Terdaftar: ${_formatDate(user['created_at'])}',
                      style: TextStyle(
                        fontSize: _captionFontSize,
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
        const SizedBox(height: _tinySpacing),
        Row(
          children: [
            Icon(
              Icons.login_rounded,
              size: _iconSize,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: _tinySpacing),
            Expanded(
              child: Text(
                'Login terakhir: ${_formatDateTime(user['last_login'])}',
                style: TextStyle(
                  fontSize: _captionFontSize,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build action buttons for editing and deleting
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildActionButton(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          icon: Icons.edit_rounded,
          iconColor: Colors.blue.shade700,
          onPressed: onEdit,
          tooltip: 'Edit Pengguna',
        ),
        const SizedBox(width: _miniSpacing),
        _buildActionButton(
          colors: [Colors.red.shade50, Colors.red.shade100],
          icon: Icons.delete_rounded,
          iconColor: Colors.red.shade700,
          onPressed: onDelete,
          tooltip: 'Hapus Pengguna',
        ),
      ],
    );
  }

  /// Build a reusable info row with icon
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color containerColor,
    required String text,
    required Color textColor,
    double fontSize = _bodyFontSize,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(_miniSpacing),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(_miniBorderRadius),
          ),
          child: Icon(icon, color: Colors.white, size: _iconSize),
        ),
        const SizedBox(width: _microSpacing),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build a reusable info card
  Widget _buildInfoCard({
    required Color backgroundColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
    double fontSize = _bodyFontSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: _largeIconSize),
          const SizedBox(width: _miniSpacing),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build a reusable action button
  Widget _buildActionButton({
    required List<Color> colors,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(_miniBorderRadius + 2),
      ),
      child: IconButton(
        icon: Icon(icon, size: _largeIconSize),
        color: iconColor,
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(_miniSpacing),
      ),
    );
  }
}
