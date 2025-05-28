import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan kartu konten edukasi dalam panel admin
class AdminContentCardWidget extends StatelessWidget {
  final Map<String, dynamic> content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // UI Constants
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;
  static const double _contentPadding = 20.0;
  static const double _badgePadding = 6.0;
  static const double _badgeRadius = 20.0;
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _iconSize = 16.0;
  static const double _smallIconSize = 14.0;
  static const double _imageHeight = 140.0;
  static const double _titleFontSize = 18.0;
  static const double _badgeFontSize = 12.0;
  static const double _infoFontSize = 12.0;
  static const double _microFontSize = 11.0;
  static const double _buttonHeight = 44.0;

  const AdminContentCardWidget({
    super.key,
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  /// Mendapatkan warna berdasarkan status konten
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

  /// Mendapatkan ikon berdasarkan status konten
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Dipublikasikan':
        return Icons.public_rounded;
      case 'Draf':
        return Icons.edit_document;
      case 'Diarsip':
        return Icons.archive_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  /// Mengambil nilai String dengan aman dari content map
  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = content[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Mengambil nilai int dengan aman dari content map
  int _safeGetInt(String key, [int defaultValue = 0]) {
    final value = content[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Format tanggal ke format yang lebih mudah dibaca
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    try {
      if (date is DateTime) {
        return DateFormat('dd MMM yyyy').format(date);
      } else if (date is String) {
        final parsedDate = DateTime.tryParse(date);
        if (parsedDate != null) {
          return DateFormat('dd MMM yyyy').format(parsedDate);
        }
      }
    } catch (e) {
      debugPrint('Error formatting date: $e');
    }
    
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    final status = _safeGetString('status');
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final formattedDate = _formatDate(content['publish_date']);
    final viewCount = _safeGetInt('view_count');
    final imageUrl = content['image_url'] as String?;
    final title = _safeGetString('title');
    final author = _safeGetString('author');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: onEdit,
          child: Container(
            decoration: _buildCardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(_contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(status, statusColor, statusIcon, viewCount),
                  const SizedBox(height: _spacing),
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    _buildImageSection(imageUrl),
                    const SizedBox(height: _spacing),
                  ],
                  _buildTitleSection(title),
                  const SizedBox(height: _smallSpacing),
                  _buildInfoRow(author, formattedDate),
                  const SizedBox(height: _spacing),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun dekorasi kartu utama
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.blue.shade50.withOpacity(0.3),
        ],
      ),
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(
        color: Colors.blue.withOpacity(0.1),
        width: 1.5,
      ),
    );
  }

  /// Membangun baris header dengan status dan view count
  Widget _buildHeaderRow(String status, Color statusColor, IconData statusIcon, int viewCount) {
    return Row(
      children: [
        _buildStatusBadge(status, statusColor, statusIcon),
        const Spacer(),
        _buildViewCountBadge(viewCount),
      ],
    );
  }

  /// Membangun badge status konten
  Widget _buildStatusBadge(String status, Color statusColor, IconData statusIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: _badgePadding,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.2),
            statusColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_badgeRadius),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: _iconSize,
          ),
          const SizedBox(width: _tinySpacing),
          Text(
            status,
            style: TextStyle(
              fontSize: _badgeFontSize,
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun badge jumlah view
  Widget _buildViewCountBadge(int viewCount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_rounded,
            size: _smallIconSize,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '$viewCount',
            style: TextStyle(
              fontSize: _microFontSize,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun section gambar konten
  Widget _buildImageSection(String imageUrl) {
    return Container(
      height: _imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(
          color: Colors.blue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: _buildImageErrorWidget,
          loadingBuilder: _buildImageLoadingWidget,
        ),
      ),
    );
  }

  /// Widget untuk menampilkan error saat memuat gambar
  Widget _buildImageErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              color: Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: _microSpacing),
            Text(
              'Gambar tidak dapat dimuat',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: _microFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan loading saat memuat gambar
  Widget _buildImageLoadingWidget(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.blue.shade700,
          strokeWidth: 2,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  /// Membangun section judul konten
  Widget _buildTitleSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: _titleFontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Membangun baris informasi konten (author dan tanggal)
  Widget _buildInfoRow(String author, String formattedDate) {
    return Row(
      children: [
        if (author != 'N/A') ...[
          Expanded(child: _buildAuthorBadge(author)),
          const SizedBox(width: _smallSpacing),
        ],
        if (formattedDate != 'N/A')
          _buildDateBadge(formattedDate),
      ],
    );
  }

  /// Membangun badge informasi penulis
  Widget _buildAuthorBadge(String author) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person_rounded,
            size: _iconSize,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: _tinySpacing),
          Expanded(
            child: Text(
              author,
              style: TextStyle(
                fontSize: _infoFontSize,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun badge informasi tanggal
  Widget _buildDateBadge(String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: _smallIconSize,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: _tinySpacing),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: _infoFontSize,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol aksi (Edit dan Delete)
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildEditButton()),
        const SizedBox(width: _smallSpacing),
        _buildDeleteButton(),
      ],
    );
  }

  /// Membangun tombol edit
  Widget _buildEditButton() {
    return SizedBox(
      height: _buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text(
          'Edit',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.blue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_microBorderRadius),
          ),
        ),
      ),
    );
  }

  /// Membangun tombol hapus
  Widget _buildDeleteButton() {
    return Container(
      height: _buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(
          color: Colors.red.shade300,
          width: 1.5,
        ),
      ),
      child: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.delete_rounded, size: 20),
        color: Colors.red.shade700,
        tooltip: 'Hapus Konten',
      ),
    );
  }
}