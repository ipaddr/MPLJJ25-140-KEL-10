import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_submission_service.dart';

/// Halaman untuk menampilkan detail pengajuan bantuan oleh admin
///
/// Menampilkan informasi lengkap pengajuan seperti data pemohon,
/// program yang diajukan, dokumen pendukung, dan status pengajuan
class AdminSubmissionDetailPage extends StatefulWidget {
  final String submissionId;

  const AdminSubmissionDetailPage({
    super.key,
    required this.submissionId,
  });

  @override
  State<AdminSubmissionDetailPage> createState() => _AdminSubmissionDetailPageState();
}

class _AdminSubmissionDetailPageState extends State<AdminSubmissionDetailPage>
    with TickerProviderStateMixin {
  // Services
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  
  // State variables
  Map<String, dynamic>? _submissionData;
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
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _miniSpacing = 6.0;
  static const double _tinySpacing = 4.0;
  
  static const double _borderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;
  
  static const double _largeIconSize = 64.0;
  static const double _mediumIconSize = 48.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;
  
  static const double _largeTextSize = 24.0;
  static const double _mediumTextSize = 20.0;
  static const double _normalTextSize = 16.0;
  static const double _smallTextSize = 14.0;
  static const double _microTextSize = 12.0;
  static const double _tinyTextSize = 10.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSubmissionDetails();
  }

  /// Inisialisasi animasi untuk halaman
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  /// Memuat detail pengajuan dari service
  Future<void> _loadSubmissionDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final submissionData = await _submissionService.getSubmissionById(widget.submissionId);

      if (submissionData != null) {
        setState(() {
          _submissionData = submissionData;
          _isLoading = false;
        });
        
        _fadeController.forward();
        _slideController.forward();
      } else {
        setState(() {
          _errorMessage = 'Pengajuan tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat detail pengajuan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Navigasi ke halaman edit pengajuan
  void _editSubmission() {
    context.go('${RouteNames.adminEditSubmission}/${widget.submissionId}');
  }

  /// Menghapus pengajuan dengan konfirmasi
  Future<void> _deleteSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteConfirmationDialog(),
    );

    if (confirmed == true) {
      try {
        final success = await _submissionService.deleteSubmission(widget.submissionId);
        if (success && mounted) {
          _showSnackBar('Pengajuan berhasil dihapus', Colors.green.shade600);
          context.go(RouteNames.adminSubmissionManagement);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Gagal menghapus pengajuan: $e', Colors.red.shade600);
        }
      }
    }
  }
  
  /// Menampilkan snackbar dengan pesan dan warna tertentu
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
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
                'Memuat detail pengajuan...',
                style: TextStyle(color: Colors.white, fontSize: _normalTextSize),
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
                style: const TextStyle(color: Colors.white, fontSize: _normalTextSize),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _largeSpacing),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.adminSubmissionManagement),
                child: const Text('Kembali ke Daftar Pengajuan'),
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
      padding: const EdgeInsets.all(_largeSpacing - 4),
      child: Row(
        children: [
          // Back Button
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: () => context.go(RouteNames.adminSubmissionManagement),
          ),
          const SizedBox(width: _spacing),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _largeTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _submissionData?['userName'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _smallTextSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Buttons
          _buildIconButton(
            icon: Icons.edit_rounded,
            backgroundColor: Colors.white.withOpacity(0.2),
            onPressed: _editSubmission,
            tooltip: 'Edit Pengajuan',
          ),
          const SizedBox(width: _microSpacing),
          _buildIconButton(
            icon: Icons.delete_rounded,
            backgroundColor: Colors.red.withOpacity(0.8),
            onPressed: _deleteSubmission,
            tooltip: 'Hapus Pengajuan',
          ),
        ],
      ),
    );
  }

  /// Membangun tombol ikon dengan latar belakang
  Widget _buildIconButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  /// Membangun dialog konfirmasi hapus
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
          const Text('Apakah Anda yakin ingin menghapus pengajuan ini?'),
          const SizedBox(height: _spacing),
          Container(
            padding: const EdgeInsets.all(_smallSpacing),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(_microBorderRadius),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              '${_submissionData?['userName']} - ${_submissionData?['programName']}',
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Membangun bagian header dengan informasi dasar pengajuan
  Widget _buildHeaderSection() {
    final status = _submissionData!['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.all(_largeSpacing),
      padding: const EdgeInsets.all(_largeSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Row(
            children: [
              _buildStatusBadge(status, statusColor),
              const Spacer(),
              Text(
                'ID: ${widget.submissionId.length > 8 ? widget.submissionId.substring(0, 8) + '...' : widget.submissionId}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: _microTextSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: _largeSpacing),

          // User Info
          Text(
            _submissionData!['userName'] ?? 'N/A',
            style: const TextStyle(
              fontSize: _largeTextSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _microSpacing),
          Text(
            _submissionData!['userEmail'] ?? 'N/A',
            style: TextStyle(
              fontSize: _normalTextSize,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: _spacing),

          // Program Info
          _buildProgramInfoCard(),
          const SizedBox(height: _spacing),

          // Date Info
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Tanggal Pengajuan',
                  _formatDate(_submissionData!['submissionDate']),
                  Icons.calendar_today_rounded,
                ),
              ),
              if (_submissionData!['reviewDate'] != null) ...[
                const SizedBox(width: _spacing),
                Expanded(
                  child: _buildInfoItem(
                    'Tanggal Review',
                    _formatDate(_submissionData!['reviewDate']),
                    Icons.check_circle_rounded,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Membangun badge status pengajuan
  Widget _buildStatusBadge(String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _spacing, 
        vertical: _microSpacing
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: _smallIconSize - 4, color: statusColor),
          const SizedBox(width: _miniSpacing),
          Text(
            _getStatusDisplayName(status),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: _microTextSize,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kartu informasi program
  Widget _buildProgramInfoCard() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_rounded, color: Colors.blue.shade600),
          const SizedBox(width: _smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Program Bantuan',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: _microTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _submissionData!['programName'] ?? 'N/A',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: _normalTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian detail dengan tab
  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _largeSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                ),
                borderRadius: BorderRadius.circular(_smallBorderRadius),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: _microTextSize
              ),
              tabs: const [
                Tab(icon: Icon(Icons.person_rounded, size: 18), text: 'Data Pemohon'),
                Tab(icon: Icon(Icons.assignment_rounded, size: 18), text: 'Info Pengajuan'),
                Tab(icon: Icon(Icons.attach_file_rounded, size: 18), text: 'Dokumen'),
              ],
            ),
            SizedBox(
              height: 400,
              child: TabBarView(
                children: [
                  _buildApplicantTab(),
                  _buildSubmissionTab(),
                  _buildDocumentsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tab data pemohon
  Widget _buildApplicantTab() {
    final userDetails = _submissionData!['userDetails'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        children: [
          _buildDetailCard('Nama Lengkap', userDetails['fullName'] ?? 'N/A', Icons.person_rounded),
          _buildDetailCard('Email', userDetails['email'] ?? 'N/A', Icons.email_rounded),
          _buildDetailCard('Nomor Telepon', userDetails['phoneNumber'] ?? 'N/A', Icons.phone_rounded),
          _buildDetailCard('NIK', userDetails['nik'] ?? 'N/A', Icons.badge_rounded),
          _buildDetailCard('Pekerjaan', userDetails['jobType'] ?? 'N/A', Icons.work_rounded),
          _buildDetailCard('Penghasilan Bulanan', _formatCurrency(userDetails['monthlyIncome']), Icons.attach_money_rounded),
          _buildDetailCard('Lokasi', userDetails['location'] ?? 'N/A', Icons.location_on_rounded),
        ],
      ),
    );
  }

  /// Membangun tab info pengajuan
  Widget _buildSubmissionTab() {
    final programDetails = _submissionData!['programDetails'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        children: [
          _buildDetailCard('Program', programDetails['programName'] ?? 'N/A', Icons.assignment_rounded),
          _buildDetailCard('Penyelenggara', programDetails['organizer'] ?? 'N/A', Icons.business_rounded),
          _buildDetailCard('Kategori', programDetails['category'] ?? 'N/A', Icons.category_rounded),
          _buildDetailCard('Status Program', programDetails['status'] ?? 'N/A', Icons.info_rounded),
          if (_submissionData!['notes'] != null && _submissionData!['notes'].isNotEmpty)
            _buildDetailCard('Catatan Admin', _submissionData!['notes'], Icons.note_rounded),
        ],
      ),
    );
  }

  /// Membangun tab dokumen
  Widget _buildDocumentsTab() {
    final documents = _submissionData!['supportingDocuments'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(_spacing),
      child: documents.isEmpty
          ? _buildEmptyDocumentsMessage()
          : _buildDocumentsList(documents),
    );
  }

  /// Membangun pesan tidak ada dokumen
  Widget _buildEmptyDocumentsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: _mediumIconSize, color: Colors.grey.shade400),
          const SizedBox(height: _spacing),
          Text(
            'Tidak ada dokumen',
            style: TextStyle(color: Colors.grey.shade600, fontSize: _normalTextSize, fontWeight: FontWeight.bold),
          ),
          Text(
            'Pemohon belum mengunggah dokumen pendukung',
            style: TextStyle(color: Colors.grey.shade500, fontSize: _smallTextSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Membangun daftar dokumen
  Widget _buildDocumentsList(List<dynamic> documents) {
    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index] as Map<String, dynamic>;
        return _buildDocumentCard(doc);
      },
    );
  }

  /// Membangun kartu detail
  Widget _buildDetailCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: _smallSpacing),
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildIconContainer(icon),
          const SizedBox(width: _spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: _microTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: _tinySpacing),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: _smallTextSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun kontainer ikon dengan warna biru
  Widget _buildIconContainer(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Icon(icon, color: Colors.blue.shade700, size: _smallIconSize),
    );
  }

  /// Membangun kartu dokumen
  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: _smallSpacing),
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_smallSpacing),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(_microBorderRadius),
            ),
            child: Icon(
              _getDocumentIcon(doc['fileType'] ?? ''),
              color: Colors.blue.shade700,
              size: _iconSize,
            ),
          ),
          const SizedBox(width: _spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['fileName'] ?? 'Dokumen',
                  style: const TextStyle(fontSize: _smallTextSize, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: _tinySpacing),
                Text(
                  doc['fileType'] ?? 'Unknown',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: _microTextSize),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Open document
            },
            icon: Icon(Icons.visibility_rounded, color: Colors.blue.shade600),
            tooltip: 'Lihat Dokumen',
          ),
        ],
      ),
    );
  }

  /// Membangun item informasi
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, size: _smallIconSize - 4, color: Colors.grey.shade600),
          const SizedBox(width: _microSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: _tinyTextSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: _microTextSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mendapatkan warna berdasarkan status pengajuan
  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('setuju') || lowerStatus == 'approved') return Colors.green;
    if (lowerStatus.contains('tolak') || lowerStatus == 'rejected') return Colors.red;
    if (lowerStatus.contains('proses') || lowerStatus == 'reviewed') return Colors.blue;
    if (lowerStatus.contains('baru') || lowerStatus == 'pending') return Colors.orange;
    return Colors.grey;
  }

  /// Mendapatkan ikon berdasarkan status pengajuan
  IconData _getStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('setuju') || lowerStatus == 'approved') return Icons.check_circle_rounded;
    if (lowerStatus.contains('tolak') || lowerStatus == 'rejected') return Icons.cancel_rounded;
    if (lowerStatus.contains('proses') || lowerStatus == 'reviewed') return Icons.visibility_rounded;
    if (lowerStatus.contains('baru') || lowerStatus == 'pending') return Icons.schedule_rounded;
    return Icons.help_rounded;
  }

  /// Mendapatkan nama tampilan untuk status
  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      case 'reviewed': return 'Diproses';
      case 'pending': return 'Baru';
      default: return status;
    }
  }

  /// Mendapatkan ikon berdasarkan tipe dokumen
  IconData _getDocumentIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['image', 'jpg', 'png', 'jpeg', 'gif'].contains(lowerType)) return Icons.image_rounded;
    if (['doc', 'docx', 'txt'].contains(lowerType)) return Icons.description_rounded;
    return Icons.attach_file_rounded;
  }

  /// Format tanggal dari berbagai tipe data
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    
    try {
      DateTime dateTime;
      if (date is DateTime) {
        dateTime = date;
      } else if (date is Timestamp) {
        dateTime = date.toDate();
      } else {
        return 'N/A';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Format angka ke format mata uang
  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'N/A';
    
    try {
      final number = amount is String ? double.parse(amount) : amount.toDouble();
      return 'Rp ${number.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } catch (e) {
      return 'N/A';
    }
  }
}