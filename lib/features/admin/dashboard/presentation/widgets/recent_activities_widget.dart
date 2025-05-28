import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/dashboard_statistics.dart';

/// Widget untuk menampilkan aktivitas terbaru pada dashboard admin
class RecentActivitiesWidget extends StatelessWidget {
  final List<RecentActivity> activities;

  // UI Constants
  static const double _borderRadius = 20;
  static const double _contentPadding = 16;
  static const double _itemPadding = 10;
  static const double _itemSpacing = 10;
  static const double _verticalSpacing = 6;
  static const double _microSpacing = 3;
  static const double _separatorSpacing = 6;
  static const double _iconSize = 18;
  static const double _statusIconSize = 16;
  static const double _microIconSize = 10;
  static const double _headerFontSize = 16;
  static const double _itemTitleFontSize = 12;
  static const double _itemSubtitleFontSize = 11;
  static const double _badgeFontSize = 11;
  static const double _statusFontSize = 10;
  static const double _timeFontSize = 10;
  static const double _emptyIconSize = 48;

  const RecentActivitiesWidget({
    super.key, 
    required this.activities
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content - Empty or List
          Expanded(
            child: activities.isEmpty
                ? _buildEmptyState()
                : _buildActivitiesList(),
          ),
        ],
      ),
    );
  }

  /// Mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Colors.blue;
      case 'diproses':
      case 'processing':
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

  /// Mendapatkan ikon status
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'baru':
      case 'pending':
        return Icons.fiber_new_rounded;
      case 'diproses':
      case 'processing':
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

  /// Membangun dekorasi container
  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.95),
          Colors.white.withOpacity(0.8),
        ],
      ),
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.8)),
    );
  }

  /// Membangun header widget
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(_contentPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade50.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_verticalSpacing),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_verticalSpacing + 2),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: Colors.blue.shade700,
              size: _iconSize,
            ),
          ),
          const SizedBox(width: _itemSpacing),
          Text(
            'Aktivitas Terbaru',
            style: TextStyle(
              fontSize: _headerFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const Spacer(),
          _buildCountBadge(),
        ],
      ),
    );
  }

  /// Membangun badge jumlah item
  Widget _buildCountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _verticalSpacing,
        vertical: _microSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_itemSpacing),
      ),
      child: Text(
        '${activities.length} item',
        style: TextStyle(
          fontSize: _badgeFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  /// Membangun tampilan kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.history_rounded,
              size: _emptyIconSize,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: _itemSpacing),
          Text(
            'Belum ada aktivitas terbaru',
            style: TextStyle(
              fontSize: _itemTitleFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: _verticalSpacing),
          Text(
            'Aktivitas akan muncul di sini',
            style: TextStyle(
              fontSize: _itemSubtitleFontSize,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun daftar aktivitas
  Widget _buildActivitiesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(_contentPadding),
      itemCount: activities.length,
      separatorBuilder: (context, index) => _buildSeparator(),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(activity);
      },
    );
  }

  /// Membangun separator antar item
  Widget _buildSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: _separatorSpacing),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade200,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  /// Membangun item aktivitas
  Widget _buildActivityItem(RecentActivity activity) {
    final statusColor = _getStatusColor(activity.status);
    final formattedDate = activity.submissionDate != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(activity.submissionDate!)
        : 'Tanggal tidak tersedia';

    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(_itemPadding),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          _buildStatusIconContainer(activity.status, statusColor),
          const SizedBox(width: _itemSpacing),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.userName,
                  style: const TextStyle(
                    fontSize: _itemTitleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  'mengajukan ${activity.programName}',
                  style: TextStyle(
                    fontSize: _itemSubtitleFontSize,
                    color: Colors.grey.shade600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatusBadge(activity.status, statusColor),
                    const SizedBox(width: _verticalSpacing),
                    Icon(
                      Icons.schedule_rounded,
                      size: _microIconSize,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: _microSpacing),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: _timeFontSize,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun container ikon status
  Widget _buildStatusIconContainer(String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(_verticalSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_verticalSpacing),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        _getStatusIcon(status),
        color: color,
        size: _statusIconSize,
      ),
    );
  }

  /// Membangun badge status
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _verticalSpacing,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_verticalSpacing + 2),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: _statusFontSize,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}