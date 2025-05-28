import 'package:flutter/material.dart';

/// Widget untuk menampilkan kartu program dalam daftar program admin
class AdminProgramCardWidget extends StatelessWidget {
  final Map<String, dynamic> program;
  final VoidCallback onViewDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // Constants for styling
  static const double _borderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 10.0;
  
  static const double _spacing = 16.0;
  static const double _midSpacing = 12.0;
  static const double _smallSpacing = 8.0;
  static const double _microSpacing = 6.0;
  static const double _tinySpacing = 4.0;
  
  static const double _iconSize = 20.0;
  static const double _smallIconSize = 16.0;
  static const double _microIconSize = 14.0;
  
  static const double _opacity = 0.15;
  static const double _mediumOpacity = 0.3;
  static const double _highOpacity = 0.4;
  static const double _veryHighOpacity = 0.9;
  
  static const double _largeTextSize = 18.0;
  static const double _mediumTextSize = 13.0;
  static const double _smallTextSize = 11.0;
  
  static const double _headerImageHeight = 140.0;

  const AdminProgramCardWidget({
    super.key,
    required this.program,
    required this.onViewDetail,
    required this.onEdit,
    required this.onDelete,
  });

  /// Menentukan warna berdasarkan status program
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'active':
        return Colors.green;
      case 'tidak aktif':
      case 'inactive':
        return Colors.orange;
      case 'ditutup':
      case 'closed':
        return Colors.red;
      case 'akan datang':
      case 'upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Menentukan ikon berdasarkan status program
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'active':
        return Icons.check_circle_rounded;
      case 'tidak aktif':
      case 'inactive':
        return Icons.pause_circle_rounded;
      case 'ditutup':
      case 'closed':
        return Icons.cancel_rounded;
      case 'akan datang':
      case 'upcoming':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
  
  /// Menentukan ikon berdasarkan kategori program
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kesehatan':
        return Icons.local_hospital_rounded;
      case 'pendidikan':
        return Icons.school_rounded;
      case 'ekonomi':
        return Icons.business_center_rounded;
      case 'bantuan sosial':
        return Icons.favorite_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  /// Mendapatkan string dari Map dengan nilai default
  String _safeGetString(String key, [String defaultValue = 'N/A']) {
    final value = program[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Mendapatkan integer dari Map dengan nilai default
  int _safeGetInt(String key, [int defaultValue = 0]) {
    final value = program[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_safeGetString('status'));
    final statusIcon = _getStatusIcon(_safeGetString('status'));
    final categoryIcon = _getCategoryIcon(_safeGetString('kategori'));
    final programName = _safeGetString('nama_program');
    final category = _safeGetString('kategori');
    final status = _safeGetString('status');
    final totalApplications = _safeGetInt('jumlah_pengajuan');
    final imageUrl = _safeGetString('imageUrl');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _spacing, vertical: _smallSpacing),
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              if (imageUrl != 'N/A' && imageUrl.isNotEmpty) 
                _buildHeaderImage(imageUrl, status, statusColor, statusIcon),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(_spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program title & status (for cards without image)
                    if (imageUrl == 'N/A' || imageUrl.isEmpty)
                      _buildTitleWithStatusBadge(programName, status, statusColor, statusIcon)
                    else
                      _buildTitle(programName),

                    const SizedBox(height: _midSpacing),

                    // Category and Applications Row
                    _buildMetadataRow(category, totalApplications, categoryIcon),

                    const SizedBox(height: _spacing),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun bagian gambar header
  Widget _buildHeaderImage(String imageUrl, String status, Color statusColor, IconData statusIcon) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
      ),
      child: Container(
        height: _headerImageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),
        child: Stack(
          children: [
            // Program image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageErrorWidget();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImageLoadingWidget();
              },
            ),
            
            // Status badge overlay
            _buildStatusOverlay(status, statusColor, statusIcon),
          ],
        ),
      ),
    );
  }
  
  /// Membangun widget untuk menampilkan error gambar
  Widget _buildImageErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
  
  /// Membangun widget untuk loading gambar
  Widget _buildImageLoadingWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  /// Membangun overlay status
  Widget _buildStatusOverlay(String status, Color statusColor, IconData statusIcon) {
    return Positioned(
      top: _midSpacing,
      right: _midSpacing,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(_veryHighOpacity),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: _microIconSize,
              color: Colors.white,
            ),
            const SizedBox(width: _tinySpacing),
            Text(
              status,
              style: const TextStyle(
                fontSize: _smallTextSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun judul program dengan status badge
  Widget _buildTitleWithStatusBadge(String programName, String status, Color statusColor, IconData statusIcon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            programName,
            style: const TextStyle(
              fontSize: _largeTextSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: _smallSpacing),
        _buildStatusBadge(status, statusColor, statusIcon),
      ],
    );
  }
  
  /// Membangun judul program
  Widget _buildTitle(String programName) {
    return Text(
      programName,
      style: const TextStyle(
        fontSize: _largeTextSize,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
  
  /// Membangun badge status
  Widget _buildStatusBadge(String status, Color statusColor, IconData statusIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(_opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(_highOpacity),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: _microIconSize,
            color: statusColor,
          ),
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

  /// Membangun baris metadata (kategori dan jumlah pengajuan)
  Widget _buildMetadataRow(String category, int totalApplications, IconData categoryIcon) {
    return Row(
      children: [
        // Category
        Expanded(
          child: _buildCategoryBadge(category, categoryIcon),
        ),
        const SizedBox(width: _midSpacing),

        // Applications Count
        _buildApplicationCountBadge(totalApplications),
      ],
    );
  }
  
  /// Membangun badge kategori
  Widget _buildCategoryBadge(String category, IconData categoryIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _midSpacing,
        vertical: _smallSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(_opacity),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(
          color: Colors.blue.withOpacity(_mediumOpacity),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            categoryIcon,
            size: _smallIconSize,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: _microSpacing),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontSize: _mediumTextSize,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Membangun badge jumlah pengajuan
  Widget _buildApplicationCountBadge(int totalApplications) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _midSpacing,
        vertical: _smallSpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(_opacity),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(
          color: Colors.purple.withOpacity(_mediumOpacity),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_rounded,
            size: _smallIconSize,
            color: Colors.purple.shade700,
          ),
          const SizedBox(width: _microSpacing),
          Text(
            '$totalApplications',
            style: TextStyle(
              fontSize: _mediumTextSize,
              color: Colors.purple.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol aksi
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // View Detail Button
        _buildActionButton(
          onViewDetail,
          Icons.visibility_rounded,
          [Colors.blue.shade400, Colors.blue.shade600],
          Colors.blue,
        ),
        const SizedBox(width: _smallSpacing),

        // Edit Button
        _buildActionButton(
          onEdit,
          Icons.edit_rounded,
          [Colors.orange.shade400, Colors.orange.shade600],
          Colors.orange,
        ),
        const SizedBox(width: _smallSpacing),

        // Delete Button
        _buildActionButton(
          onDelete,
          Icons.delete_rounded,
          [Colors.red.shade400, Colors.red.shade600],
          Colors.red,
        ),
      ],
    );
  }
  
  /// Membangun tombol aksi dengan warna dan ikon tertentu
  Widget _buildActionButton(
    VoidCallback onTap,
    IconData icon,
    List<Color> gradientColors,
    MaterialColor shadowColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(_microBorderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(_mediumOpacity),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: _iconSize,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}