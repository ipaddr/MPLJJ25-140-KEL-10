import 'package:flutter/material.dart';

/// Widget untuk menampilkan item dalam daftar program
class ProgramListItemWidget extends StatelessWidget {
  final String programId;
  final Map<String, dynamic> programData;
  final VoidCallback onTap;

  // UI Constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _borderRadius = 12.0;
  static const double _badgePadding = 4.0;
  static const double _badgeRadius = 6.0;
  static const double _iconSize = 14.0;
  static const double _imageHeight = 180.0;

  const ProgramListItemWidget({
    super.key,
    required this.programId,
    required this.programData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: _spacing),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  /// Membangun bagian gambar
  Widget _buildImageSection() {
    final imageUrl = programData['imageUrl'];
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
      ),
      child: Image.network(
        imageUrl,
        height: _imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoadingPlaceholder();
        },
      ),
    );
  }

  /// Membangun placeholder untuk error gambar
  Widget _buildImageErrorPlaceholder() {
    return Container(
      height: _imageHeight,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported,
        size: 50,
        color: Colors.grey.shade400,
      ),
    );
  }

  /// Membangun placeholder untuk loading gambar
  Widget _buildImageLoadingPlaceholder() {
    return Container(
      height: _imageHeight,
      color: Colors.grey.shade100,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Membangun bagian konten
  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgesRow(),
          const SizedBox(height: _tinySpacing),
          _buildProgramName(),
          const SizedBox(height: _tinySpacing),
          _buildDescription(),
          const SizedBox(height: _smallSpacing),
          _buildFooter(),
        ],
      ),
    );
  }

  /// Membangun baris badge kategori dan status
  Widget _buildBadgesRow() {
    return Row(
      children: [
        _buildCategoryBadge(),
        const SizedBox(width: _tinySpacing),
        _buildStatusBadge(),
      ],
    );
  }

  /// Membangun badge kategori
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _tinySpacing,
        vertical: _badgePadding,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(_badgeRadius),
      ),
      child: Text(
        programData['category'] ?? 'Bantuan Sosial',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  /// Membangun badge status
  Widget _buildStatusBadge() {
    final isActive = programData['status'] == 'active';
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _tinySpacing,
        vertical: _badgePadding,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_badgeRadius),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
      ),
    );
  }

  /// Membangun nama program
  Widget _buildProgramName() {
    return Text(
      programData['programName'] ?? 'Nama Program',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Poppins',
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Membangun deskripsi program
  Widget _buildDescription() {
    return Text(
      programData['description'] ?? 'Tidak ada deskripsi',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Membangun footer dengan penyelenggara dan jumlah aplikasi
  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.business,
          size: _iconSize,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            programData['organizer'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: _smallSpacing),
        Icon(Icons.people, size: _iconSize, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          '${programData['totalApplications'] ?? 0}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(width: _tinySpacing),
        Icon(
          Icons.arrow_forward_ios,
          size: _iconSize,
          color: Colors.blue.shade400,
        ),
      ],
    );
  }
}