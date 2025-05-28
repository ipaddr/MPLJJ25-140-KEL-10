import 'package:flutter/material.dart';

/// Widget untuk menampilkan kartu rekomendasi program
class RecommendationCardWidget extends StatelessWidget {
  final String programId;
  final Map<String, dynamic> programData;
  final VoidCallback onTap;

  // UI Constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _microSpacing = 6.0;
  static const double _borderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _badgeRadius = 20.0;
  static const double _smallIconSize = 14.0;
  static const double _imageHeight = 160.0;

  const RecommendationCardWidget({
    super.key,
    required this.programId,
    required this.programData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: _spacing),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade50, Colors.blue.shade100],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildImageSection(),
              _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun bagian header dengan badge dan kategori
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Row(
        children: [
          _buildPopularBadge(),
          const Spacer(),
          _buildCategoryBadge(),
        ],
      ),
    );
  }

  /// Membangun badge "Populer"
  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _smallSpacing,
        vertical: _microSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(_badgeRadius),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: _smallIconSize,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Populer',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun badge kategori
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(_smallSpacing),
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

  /// Membangun bagian gambar
  Widget _buildImageSection() {
    final imageUrl = programData['imageUrl'];
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _spacing),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        child: Image.network(
          imageUrl,
          height: _imageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: _imageHeight,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Membangun bagian konten program
  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Name
          Text(
            programData['programName'] ?? 'Nama Program',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _tinySpacing),

          // Description
          Text(
            programData['description'] ?? 'Tidak ada deskripsi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: _spacing),

          // Target Audience
          if (_hasTargetAudience()) _buildTargetAudienceSection(),
          const SizedBox(height: _spacing),

          // Footer with action button
          _buildFooter(),
        ],
      ),
    );
  }

  /// Membangun bagian target audiens
  Widget _buildTargetAudienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Penerima:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _microSpacing),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _tinySpacing,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(_smallSpacing),
          ),
          child: Text(
            programData['targetAudience'].toString(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  /// Membangun bagian footer
  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.business,
          size: _smallIconSize,
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
        _buildSeeDetailButton(),
      ],
    );
  }

  /// Membangun tombol lihat detail
  Widget _buildSeeDetailButton() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _smallSpacing,
        vertical: _microSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(_badgeRadius),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lihat Detail',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: 12,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  /// Memeriksa apakah program memiliki target audiens
  bool _hasTargetAudience() {
    return programData['targetAudience'] != null && 
           programData['targetAudience'].toString().isNotEmpty;
  }
}