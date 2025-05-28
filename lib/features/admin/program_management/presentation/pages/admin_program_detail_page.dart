import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kelas untuk menyimpan informasi status
class StatusInfo {
  final Color color;
  final IconData icon;
  
  StatusInfo(this.color, this.icon);
}

/// Halaman detail program untuk admin
///
/// Menampilkan informasi lengkap program dan daftar pengajuan
class AdminProgramDetailPage extends StatefulWidget {
  final String programId;

  const AdminProgramDetailPage({super.key, required this.programId});

  @override
  State<AdminProgramDetailPage> createState() => _AdminProgramDetailPageState();
}

class _AdminProgramDetailPageState extends State<AdminProgramDetailPage> 
    with TickerProviderStateMixin {
  // Service
  final AdminProgramService _programService = AdminProgramService();
  
  // State variables
  Map<String, dynamic>? _programData;
  List<Map<String, dynamic>> _applications = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // UI Constants
  static const double _spacing = 16.0;
  static const double _largeSpacing = 24.0;
  static const double _mediumSpacing = 20.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _miniSpacing = 4.0;
  
  static const double _borderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;
  
  static const double _largeIconSize = 64.0;
  static const double _mediumIconSize = 48.0;
  // Removed unused constants
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;
  static const double _tinyIconSize = 14.0;
  
  static const double _headerImageHeight = 250.0;
  
  static const double _headingTextSize = 24.0;
  static const double _subheadingTextSize = 20.0;
  // Removed unused constant
  static const double _bodyTextSize = 16.0;
  static const double _captionTextSize = 14.0;
  static const double _smallTextSize = 12.0;
  static const double _tinyTextSize = 10.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProgramData();
  }

  /// Menyiapkan animasi untuk halaman
  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Memuat data program dari service
  Future<void> _loadProgramData() async {
    try {
      final programData = await _programService.getProgramById(widget.programId);
      final applications = await _programService.getApplicationsByProgramId(widget.programId);

      if (!mounted) return;
      
      if (programData != null) {
        setState(() {
          _programData = programData;
          _applications = applications;
          _isLoading = false;
        });
        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() {
          _errorMessage = 'Program tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Gagal memuat data program: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Menuju halaman edit program
  void _editProgram() {
    context.go('${RouteNames.adminEditProgram}/${widget.programId}');
  }

  /// Menghapus program dengan konfirmasi
  Future<void> _deleteProgram() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(),
    );

    if (confirmed == true) {
      try {
        final success = await _programService.deleteProgram(widget.programId);
        
        if (!mounted) return;
        
        if (success) {
          _showSnackBar(
            'Program "${_programData?['programName']}" berhasil dihapus',
            Colors.green.shade600,
          );
          context.go(RouteNames.adminProgramList);
        }
      } catch (e) {
        if (!mounted) return;
        
        _showSnackBar(
          'Gagal menghapus program: $e',
          Colors.red.shade600,
        );
      }
    }
  }
  
  /// Menampilkan dialog konfirmasi hapus program
  Widget _buildDeleteConfirmationDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadius)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_microSpacing),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_rounded, color: Colors.red.shade600),
          ),
          const SizedBox(width: _smallSpacing),
          const Text('Konfirmasi Hapus'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apakah Anda yakin ingin menghapus program ini?'),
          const SizedBox(height: _spacing),
          Container(
            padding: const EdgeInsets.all(_smallSpacing),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(_microBorderRadius),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _programData?['programName'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ),
          const SizedBox(height: _smallSpacing),
          Text(
            'Tindakan ini tidak dapat dibatalkan!',
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Hapus'),
        ),
      ],
    );
  }
  
  /// Menampilkan snackbar
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Mendapatkan warna sesuai status program
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'inactive': return Colors.orange;
      case 'upcoming': return Colors.blue;
      default: return Colors.grey;
    }
  }

  /// Mendapatkan ikon sesuai status program
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Icons.check_circle_rounded;
      case 'inactive': return Icons.pause_circle_rounded;
      case 'upcoming': return Icons.schedule_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  /// Mendapatkan ikon sesuai kategori program
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kesehatan': return Icons.medical_services_rounded;
      case 'pendidikan': return Icons.school_rounded;
      case 'ekonomi': return Icons.business_center_rounded;
      case 'bantuan sosial': return Icons.favorite_rounded;
      default: return Icons.category_rounded;
    }
  }

  /// Format timestamp menjadi string tanggal
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Tidak diketahui';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Mendapatkan informasi status pengajuan
  StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'approved':
        return StatusInfo(Colors.green, Icons.check_circle_rounded);
      case 'rejected':
        return StatusInfo(Colors.red, Icons.cancel_rounded);
      default:
        return StatusInfo(Colors.orange, Icons.pending_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade700, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Membangun layar loading
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: _spacing),
              Text(
                'Memuat detail program...',
                style: TextStyle(color: Colors.white, fontSize: _bodyTextSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Membangun layar error
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.red.shade600],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: _largeIconSize, color: Colors.white),
              const SizedBox(height: _spacing),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: _bodyTextSize),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _largeSpacing),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.adminProgramList),
                child: const Text('Kembali ke Daftar Program'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_mediumSpacing),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: _spacing),
          _buildAppBarTitle(),
          _buildEditButton(),
          const SizedBox(width: _microSpacing),
          _buildDeleteButton(),
        ],
      ),
    );
  }
  
  /// Membangun tombol kembali di app bar
  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),  // 0.2 * 255 = 51
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.go(RouteNames.adminProgramList),
      ),
    );
  }
  
  /// Membangun judul app bar
  Widget _buildAppBarTitle() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: _headingTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _programData?['programName'] ?? '',
            style: TextStyle(
              color: Colors.white.withAlpha(204),  // 0.8 * 255 = 204
              fontSize: _captionTextSize,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  /// Membangun tombol edit di app bar
  Widget _buildEditButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),  // 0.2 * 255 = 51
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        onPressed: _editProgram,
        tooltip: 'Edit Program',
      ),
    );
  }
  
  /// Membangun tombol hapus di app bar
  Widget _buildDeleteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(204),  // 0.8 * 255 = 204
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(Icons.delete_rounded, color: Colors.white),
        onPressed: _deleteProgram,
        tooltip: 'Hapus Program',
      ),
    );
  }

  /// Membangun konten utama halaman
  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_largeSpacing),
          topRight: Radius.circular(_largeSpacing),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(),
            _buildDetailsSection(),
            _buildApplicationsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Membangun bagian header dengan gambar dan info dasar
  Widget _buildHeaderSection() {
    if (_programData == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        // Image Section
        if (_hasValidImageUrl())
          SizedBox(
            height: _headerImageHeight,
            width: double.infinity,
            child: Stack(
              children: [
                _buildHeaderImage(),
                _buildStatusOverlay(),
              ],
            ),
          ),

        // Basic Info Card
        _buildBasicInfoCard(),
      ],
    );
  }
  
  /// Mengecek apakah program memiliki URL gambar yang valid
  bool _hasValidImageUrl() {
    return _programData?['imageUrl'] != null && _programData!['imageUrl'].isNotEmpty;
  }
  
  /// Membangun gambar header program
  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_largeSpacing),
        topRight: Radius.circular(_largeSpacing),
      ),
      child: Image.network(
        _programData!['imageUrl'],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: Icon(
              Icons.image_not_supported_rounded,
              size: _largeIconSize,
              color: Colors.grey.shade400,
            ),
          );
        },
      ),
    );
  }
  
  /// Membangun overlay status di atas gambar
  Widget _buildStatusOverlay() {
    return Positioned(
      top: _spacing,
      right: _spacing,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _smallSpacing,
          vertical: _microSpacing,
        ),
        decoration: BoxDecoration(
          color: _getStatusColor(_programData!['status']).withAlpha(230),  // 0.9 * 255 = 230
          borderRadius: BorderRadius.circular(_mediumSpacing),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),  // 0.3 * 255 = 77
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(_programData!['status']),
              size: _tinyIconSize,
              color: Colors.white,
            ),
            const SizedBox(width: _tinySpacing),
            Text(
              _programData!['status'].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: _smallTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun kartu info dasar program
  Widget _buildBasicInfoCard() {
    return Container(
      margin: const EdgeInsets.all(_mediumSpacing),
      padding: const EdgeInsets.all(_largeSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),  // 0.08 * 255 = 20
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Name
          Text(
            _programData!['programName'],
            style: const TextStyle(
              fontSize: _headingTextSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _spacing),

          // Category & Stats Row
          Row(
            children: [
              _buildCategoryBadge(),
              const SizedBox(width: _smallSpacing),
              _buildApplicationsCountBadge(),
            ],
          ),
          const SizedBox(height: _spacing),

          // Meta Info
          _buildInfoRow(
            Icons.business_rounded, 
            'Penyelenggara', 
            _programData!['organizer'],
          ),
          const SizedBox(height: _microSpacing),
          _buildInfoRow(
            Icons.group_rounded, 
            'Target Penerima', 
            _programData!['targetAudience'],
          ),
          const SizedBox(height: _microSpacing),
          _buildInfoRow(
            Icons.calendar_today_rounded, 
            'Dibuat', 
            _formatDate(_programData!['createdAt']),
          ),
        ],
      ),
    );
  }
  
  /// Membangun badge kategori program
  Widget _buildCategoryBadge() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(_smallSpacing),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(
              _getCategoryIcon(_programData!['category']),
              color: Colors.blue.shade600,
              size: _smallIconSize,
            ),
            const SizedBox(width: _microSpacing),
            Expanded(
              child: Text(
                _programData!['category'],
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Membangun badge jumlah pengajuan
  Widget _buildApplicationsCountBadge() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_rounded,
            color: Colors.purple.shade600,
            size: _smallIconSize,
          ),
          const SizedBox(width: _microSpacing),
          Text(
            '${_programData!['totalApplications']} Pengajuan',
            style: TextStyle(
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian detail program
  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildDetailCard(
            'Deskripsi Program',
            Icons.description_rounded,
            _programData!['description'],
            Colors.blue,
          ),
          const SizedBox(height: _spacing),

          // Terms and Conditions
          _buildDetailCard(
            'Syarat & Ketentuan',
            Icons.checklist_rounded,
            _programData!['termsAndConditions'],
            Colors.orange,
          ),
          const SizedBox(height: _spacing),

          // Registration Guide
          _buildDetailCard(
            'Panduan Pendaftaran',
            Icons.list_alt_rounded,
            _programData!['registrationGuide'],
            Colors.green,
          ),
        ],
      ),
    );
  }

  /// Membangun bagian daftar pengajuan
  Widget _buildApplicationsSection() {
    return Container(
      margin: const EdgeInsets.all(_mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(_microSpacing),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(_microBorderRadius),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: Colors.purple.shade600,
                  size: _smallIconSize,
                ),
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                'Daftar Pengajuan (${_applications.length})',
                style: const TextStyle(
                  fontSize: _subheadingTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: _spacing),

          // Applications List
          _applications.isEmpty
              ? _buildEmptyApplications()
              : _buildApplicationsList(),
        ],
      ),
    );
  }
  
  /// Membangun tampilan ketika tidak ada pengajuan
  Widget _buildEmptyApplications() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: _mediumIconSize,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: _smallSpacing),
          Text(
            'Belum ada pengajuan',
            style: TextStyle(
              fontSize: _bodyTextSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Membangun daftar pengajuan
  Widget _buildApplicationsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final application = _applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  /// Membangun kartu detail (deskripsi, syarat, panduan)
  Widget _buildDetailCard(String title, IconData icon, String content, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(_mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),  // 0.05 * 255 = 13
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(_microSpacing),
                decoration: BoxDecoration(
                  color: color.shade100,
                  borderRadius: BorderRadius.circular(_microBorderRadius),
                ),
                child: Icon(icon, color: color.shade600, size: _smallIconSize),
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                title,
                style: const TextStyle(
                  fontSize: _bodyTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: _spacing),
          Text(
            content,
            style: const TextStyle(
              fontSize: _captionTextSize,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kartu pengajuan
  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status']?.toLowerCase() ?? '';
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: _smallSpacing),
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: statusInfo.color.withAlpha(77)),  // 0.3 * 255 = 77
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),  // 0.05 * 255 = 13
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application['userName'] ?? 'Nama tidak tersedia',
                  style: const TextStyle(
                    fontSize: _bodyTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildApplicationStatusBadge(status, statusInfo),
            ],
          ),
          const SizedBox(height: _microSpacing),
          Text(
            application['userEmail'] ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: _captionTextSize,
            ),
          ),
          const SizedBox(height: _microSpacing),
          Text(
            'Diajukan: ${_formatDate(application['submittedAt'])}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: _smallTextSize,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Membangun badge status pengajuan
  Widget _buildApplicationStatusBadge(String status, StatusInfo statusInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _microSpacing,
        vertical: _miniSpacing,
      ),
      decoration: BoxDecoration(
        color: statusInfo.color,
        borderRadius: BorderRadius.circular(_smallSpacing),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: _tinyIconSize, color: Colors.white),
          const SizedBox(width: _miniSpacing),
          Text(
            status.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: _tinyTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun baris info (label dan nilai)
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: _microIconSize, color: Colors.grey.shade600),
        const SizedBox(width: _microSpacing),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: _captionTextSize,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: _captionTextSize,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}