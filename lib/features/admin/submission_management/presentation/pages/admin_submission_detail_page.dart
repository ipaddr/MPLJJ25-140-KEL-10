import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_submission_service.dart';

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
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  
  Map<String, dynamic>? _submissionData;
  bool _isLoading = true;
  String? _errorMessage;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSubmissionDetails();
  }

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

  void _editSubmission() {
    context.go('${RouteNames.adminEditSubmission}/${widget.submissionId}');
  }

  Future<void> _deleteSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_rounded, color: Colors.red.shade600),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus pengajuan ini?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 12),
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
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _submissionService.deleteSubmission(widget.submissionId);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pengajuan berhasil dihapus'),
              backgroundColor: Colors.green.shade600,
            ),
          );
          context.go(RouteNames.adminSubmissionManagement);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus pengajuan: $e'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                SizedBox(height: 16),
                Text(
                  'Memuat detail pengajuan...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
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
                Icon(Icons.error_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go(RouteNames.adminSubmissionManagement),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _submissionData?['userName'] ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Buttons
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: _editSubmission,
              tooltip: 'Edit Pengajuan',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.white),
              onPressed: _deleteSubmission,
              tooltip: 'Hapus Pengajuan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeaderSection(),
            
            // Details Tabs
            _buildDetailsSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final status = _submissionData!['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStatusIcon(status), size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusDisplayName(status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${widget.submissionId.substring(0, 8)}...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Info
          Text(
            _submissionData!['userName'] ?? 'N/A',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _submissionData!['userEmail'] ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          // Program Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment_rounded, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Program Bantuan',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _submissionData!['programName'] ?? 'N/A',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
                const SizedBox(width: 16),
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

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildApplicantTab() {
    final userDetails = _submissionData!['userDetails'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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

  Widget _buildSubmissionTab() {
    final programDetails = _submissionData!['programDetails'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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

  Widget _buildDocumentsTab() {
    final documents = _submissionData!['supportingDocuments'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada dokumen',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Pemohon belum mengunggah dokumen pendukung',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index] as Map<String, dynamic>;
                return _buildDocumentCard(doc);
              },
            ),
    );
  }

  Widget _buildDetailCard(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getDocumentIcon(doc['fileType'] ?? ''),
              color: Colors.blue.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['fileName'] ?? 'Dokumen',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  doc['fileType'] ?? 'Unknown',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui': case 'approved': return Colors.green;
      case 'ditolak': case 'rejected': return Colors.red;
      case 'diproses': case 'reviewed': return Colors.blue;
      case 'baru': case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui': case 'approved': return Icons.check_circle_rounded;
      case 'ditolak': case 'rejected': return Icons.cancel_rounded;
      case 'diproses': case 'reviewed': return Icons.visibility_rounded;
      case 'baru': case 'pending': return Icons.schedule_rounded;
      default: return Icons.help_rounded;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      case 'reviewed': return 'Diproses';
      case 'pending': return 'Baru';
      case 'disetujui': return 'Disetujui';
      case 'ditolak': return 'Ditolak';
      case 'diproses': return 'Diproses';
      case 'baru': return 'Baru';
      default: return status;
    }
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'image': case 'jpg': case 'png': return Icons.image_rounded;
      case 'doc': case 'docx': return Icons.description_rounded;
      default: return Icons.attach_file_rounded;
    }
  }

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