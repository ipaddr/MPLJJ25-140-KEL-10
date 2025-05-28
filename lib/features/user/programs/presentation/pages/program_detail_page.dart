import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Halaman detail program yang menampilkan informasi lengkap program dan
/// memungkinkan pengguna untuk mengajukan program
class ProgramDetailPage extends StatefulWidget {
  final String programId;
  final bool isRecommended;

  const ProgramDetailPage({
    super.key,
    required this.programId,
    this.isRecommended = false,
  });

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  // State variables
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isCheckingApplication = true;
  bool _hasApplied = false;
  Map<String, dynamic>? _programData;
  Map<String, dynamic>? _userApplication;
  User? _currentUser;

  // Collection paths
  static const String _programsCollection = 'programs';
  static const String _applicationsCollection = 'applications';
  static const String _oldApplicationsCollection = 'program_applications';
  static const String _usersCollection = 'users';

  // UI Constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 8.0;
  static const double _borderRadius = 12.0;
  static const double _badgeBorderRadius = 20.0;
  static const double _iconSize = 16.0;
  static const double _imageHeight = 250.0;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadProgram();
  }

  /// Memuat detail program dari Firestore
  Future<void> _loadProgram() async {
    try {
      // Load program data
      final doc =
          await FirebaseFirestore.instance
              .collection(_programsCollection)
              .doc(widget.programId)
              .get();

      if (doc.exists && mounted) {
        setState(() {
          _programData = doc.data();
          _isLoading = false;
        });

        // Increment view count
        await FirebaseFirestore.instance
            .collection(_programsCollection)
            .doc(widget.programId)
            .update({'viewCount': FieldValue.increment(1)});

        // Check if user has already applied
        await _checkUserApplication();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading program: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Memeriksa apakah pengguna telah mengajukan program ini
  Future<void> _checkUserApplication() async {
    if (_currentUser == null) {
      setState(() {
        _isCheckingApplication = false;
      });
      return;
    }

    try {
      // Check in unified applications collection (admin-compatible)
      final applicationQuery =
          await FirebaseFirestore.instance
              .collection(_applicationsCollection)
              .where('userId', isEqualTo: _currentUser!.uid)
              .where('programId', isEqualTo: widget.programId)
              .limit(1)
              .get();

      if (applicationQuery.docs.isNotEmpty && mounted) {
        _setApplicationData(applicationQuery.docs.first);
      } else {
        // Fallback: check old collection for backward compatibility
        final oldApplicationQuery =
            await FirebaseFirestore.instance
                .collection(_oldApplicationsCollection)
                .where('userId', isEqualTo: _currentUser!.uid)
                .where('programId', isEqualTo: widget.programId)
                .limit(1)
                .get();

        if (oldApplicationQuery.docs.isNotEmpty && mounted) {
          _setApplicationData(oldApplicationQuery.docs.first);
        } else if (mounted) {
          setState(() {
            _hasApplied = false;
            _isCheckingApplication = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking user application: $e');
      if (mounted) {
        setState(() {
          _isCheckingApplication = false;
        });
      }
    }
  }

  /// Set application data from document snapshot
  void _setApplicationData(DocumentSnapshot document) {
    if (!mounted) return;

    setState(() {
      _hasApplied = true;
      _userApplication = document.data() as Map<String, dynamic>?;
      if (_userApplication != null) {
        _userApplication!['id'] = document.id;
      }
      _isCheckingApplication = false;
    });
  }

  /// Menampilkan form aplikasi untuk mengajukan program
  Future<void> _showApplicationForm() async {
    if (_currentUser == null) {
      _showLoginDialog();
      return;
    }

    // Load user data for the application
    DocumentSnapshot? userDoc;
    try {
      userDoc =
          await FirebaseFirestore.instance
              .collection(_usersCollection)
              .doc(_currentUser!.uid)
              .get();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    if (!mounted) return;

    // Show application form dialog
    showDialog(
      context: context,
      builder:
          (context) => _ApplicationFormDialog(
            programId: widget.programId,
            programData: _programData!,
            userData: userDoc?.data() as Map<String, dynamic>?,
            onApplicationSubmitted: () {
              // Refresh application status
              _checkUserApplication();
            },
          ),
    );
  }

  /// Menampilkan dialog login jika pengguna belum login
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Login Diperlukan'),
            content: const Text(
              'Silakan login terlebih dahulu untuk mengajukan program ini.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/login');
                },
                child: const Text('Login'),
              ),
            ],
          ),
    );
  }

  /// Menambah/menghapus program dari bookmark
  Future<void> _toggleBookmark() async {
    if (!mounted) return;

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Program disimpan' : 'Program dihapus dari simpanan',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Berbagi informasi program
  Future<void> _shareProgram() async {
    if (_programData != null) {
      await Share.share(
        'Program: ${_programData!['programName']}\n\n${_programData!['description']}',
        subject: _programData!['programName'],
      );
    }
  }

  /// Mengambil teks status aplikasi untuk ditampilkan
  String _getApplicationStatusText() {
    if (_userApplication == null) return '';

    final status = _userApplication!['status'] ?? 'pending';
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Review';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status.toUpperCase();
    }
  }

  /// Mengambil warna sesuai status aplikasi
  Color _getApplicationStatusColor() {
    if (_userApplication == null) return Colors.grey;

    final status = _userApplication!['status'] ?? 'pending';
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_programData == null) {
      return _buildErrorState();
    }

    return _buildMainContent();
  }

  /// Widget untuk menampilkan state loading
  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  /// Widget untuk menampilkan state error (program tidak ditemukan)
  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Tidak Ditemukan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: _spacing),
            Text('Program tidak ditemukan', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  /// Widget utama untuk menampilkan konten halaman
  Widget _buildMainContent() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image
              _buildHeaderImage(),

              // Program Info Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Status Badges
                    _buildBadgesRow(),
                    const SizedBox(height: _spacing),

                    // Program Title
                    _buildProgramTitle(),
                    const SizedBox(height: _spacing),

                    // Application Status Banner (if user has applied)
                    if (_hasApplied && _userApplication != null)
                      _buildApplicationStatusBanner(),

                    // Program Meta Info
                    _buildMetaInfoCard(),
                    const SizedBox(height: 24),

                    // Description Section
                    _buildDescriptionSection(),
                    const SizedBox(height: _spacing),

                    // Terms and Conditions Section
                    _buildTermsAndConditionsSection(),

                    // Registration Guide Section
                    _buildRegistrationGuideSection(),

                    // Application Button - Dynamic based on application status
                    _buildApplicationButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun AppBar dengan judul dan tombol aksi
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _programData!['programName'] ?? 'Detail Program',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          onPressed: _toggleBookmark,
        ),
        IconButton(icon: const Icon(Icons.share), onPressed: _shareProgram),
      ],
    );
  }

  /// Membangun bagian gambar header
  Widget _buildHeaderImage() {
    if (_programData!['imageUrl'] == null ||
        _programData!['imageUrl'].isEmpty) {
      return const SizedBox.shrink(); // No image available
    }

    return Container(
      height: _imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(_programData!['imageUrl']),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  /// Membangun row badge kategori dan status
  Widget _buildBadgesRow() {
    return Row(
      children: [
        _buildCategoryBadge(),
        const SizedBox(width: _smallSpacing),
        _buildStatusBadge(),
      ],
    );
  }

  /// Membangun badge kategori
  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Text(
        _programData!['category'] ?? 'Bantuan Sosial',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  /// Membangun badge status (aktif/tidak aktif)
  Widget _buildStatusBadge() {
    final isActive = _programData!['status'] == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade100 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_badgeBorderRadius),
        border: Border.all(
          color: isActive ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
      ),
    );
  }

  /// Membangun judul program
  Widget _buildProgramTitle() {
    return Text(
      _programData!['programName'] ?? 'Nama Program',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
    );
  }

  /// Membangun banner status aplikasi pengguna
  Widget _buildApplicationStatusBanner() {
    final statusColor = _getApplicationStatusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_spacing),
      margin: const EdgeInsets.only(bottom: _spacing),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in, color: statusColor, size: 20),
              const SizedBox(width: _smallSpacing),
              Text(
                'Status Pengajuan Anda',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          Text(
            _getApplicationStatusText(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (_userApplication!['submissionDate'] != null)
            Text(
              'Diajukan: ${_formatDate(_userApplication!['submissionDate'])}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor.withOpacity(0.7),
              ),
            ),
          if (_hasNotes(_userApplication!)) ...[
            const SizedBox(height: _smallSpacing),
            Text(
              'Catatan: ${_userApplication!['notes']}',
              style: TextStyle(
                fontSize: 12,
                color: statusColor.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Membangun kartu informasi meta program
  Widget _buildMetaInfoCard() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.business,
            'Penyelenggara',
            _programData!['organizer'] ?? 'Tidak diketahui',
          ),
          const SizedBox(height: _smallSpacing),
          _buildInfoRow(
            Icons.group,
            'Target Penerima',
            _programData!['targetAudience'] ?? 'Semua',
          ),
          const SizedBox(height: _smallSpacing),
          _buildInfoRow(
            Icons.calendar_today,
            'Dibuat',
            _formatDate(_programData!['createdAt']),
          ),
          const SizedBox(height: _smallSpacing),
          _buildInfoRow(
            Icons.people,
            'Total Pengajuan',
            '${_programData!['totalApplications'] ?? 0}',
          ),
        ],
      ),
    );
  }

  /// Membangun bagian deskripsi program
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Deskripsi Program'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(_spacing),
          decoration: _buildSectionDecoration(),
          child: Text(
            _programData!['description'] ?? 'Tidak ada deskripsi',
            style: const TextStyle(fontSize: 14, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  /// Membangun bagian syarat dan ketentuan program
  Widget _buildTermsAndConditionsSection() {
    final termsText = _programData!['termsAndConditions'] ?? '';
    if (termsText.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Syarat & Ketentuan'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(_spacing),
          decoration: _buildSectionDecoration(),
          child: Text(
            termsText,
            style: const TextStyle(fontSize: 14, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: _spacing),
      ],
    );
  }

  /// Membangun bagian panduan registrasi
  Widget _buildRegistrationGuideSection() {
    final guideText = _programData!['registrationGuide'] ?? '';
    if (guideText.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Cara Pendaftaran'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(_spacing),
          decoration: _buildSectionDecoration(),
          child: Text(
            guideText,
            style: const TextStyle(fontSize: 14, height: 1.6),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Membangun tombol aplikasi (sesuai status)
  Widget _buildApplicationButton() {
    if (_isCheckingApplication) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasApplied) {
      return _buildAlreadyAppliedButton();
    }

    return _buildApplyButton();
  }

  /// Tombol untuk program yang sudah diajukan
  Widget _buildAlreadyAppliedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: null, // Disabled
        icon: const Icon(Icons.check_circle),
        label: Text('Sudah Mengajukan - ${_getApplicationStatusText()}'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.grey.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
    );
  }

  /// Tombol untuk mengajukan program
  Widget _buildApplyButton() {
    final isActive = _programData!['status'] == 'active';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isActive ? _showApplicationForm : null,
        icon: const Icon(Icons.how_to_reg),
        label: Text(isActive ? 'Ajukan Program Ini' : 'Program Tidak Aktif'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
    );
  }

  /// Membangun judul seksi
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Poppins',
      ),
    );
  }

  /// Membangun baris informasi dengan ikon
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: _iconSize, color: Colors.grey.shade600),
        const SizedBox(width: _smallSpacing),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  /// Dekorasi untuk section
  BoxDecoration _buildSectionDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(_borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Format tanggal dari berbagai tipe data
  String _formatDate(dynamic date) {
    if (date == null) return 'Tidak diketahui';
    if (date is Timestamp) {
      final dateTime = date.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    if (date is String) return date;
    return 'Tidak diketahui';
  }

  /// Memeriksa apakah aplikasi memiliki catatan
  bool _hasNotes(Map<String, dynamic> application) {
    final notes = application['notes'] ?? '';
    return notes.toString().isNotEmpty;
  }
}

/// Dialog untuk form pengajuan program
class _ApplicationFormDialog extends StatefulWidget {
  final String programId;
  final Map<String, dynamic> programData;
  final Map<String, dynamic>? userData;
  final VoidCallback onApplicationSubmitted;

  const _ApplicationFormDialog({
    required this.programId,
    required this.programData,
    required this.userData,
    required this.onApplicationSubmitted,
  });

  @override
  State<_ApplicationFormDialog> createState() => _ApplicationFormDialogState();
}

class _ApplicationFormDialogState extends State<_ApplicationFormDialog> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Mengirim pengajuan program
  Future<void> _submitApplication() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan alasan pengajuan')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Unified application data structure (admin-compatible)
      final applicationData = _prepareApplicationData(currentUser);

      // Submit to unified collection
      final docRef = await FirebaseFirestore.instance
          .collection('applications')
          .add(applicationData);

      // Update document with its own ID
      await docRef.update({'id': docRef.id});

      // Update program application count
      await FirebaseFirestore.instance
          .collection('programs')
          .doc(widget.programId)
          .update({'totalApplications': FieldValue.increment(1)});

      if (mounted) {
        Navigator.of(context).pop();
        widget.onApplicationSubmitted();
        _showSuccessMessage();
      }
    } catch (e) {
      debugPrint('Error submitting application: $e');
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Menyiapkan data aplikasi untuk dikirim
  Map<String, dynamic> _prepareApplicationData(User currentUser) {
    return {
      'userId': currentUser.uid,
      'programId': widget.programId,

      // Program information (admin-compatible)
      'programName': widget.programData['programName'] ?? '',
      'programCategory': widget.programData['category'] ?? '',
      'category': widget.programData['category'] ?? '',

      // User information (unified structure)
      'userName': widget.userData?['fullName'] ?? '',
      'userFullName': widget.userData?['fullName'] ?? '',
      'userEmail': widget.userData?['email'] ?? currentUser.email ?? '',
      'userPhone': widget.userData?['phoneNumber'] ?? '',
      'userNIK': widget.userData?['nik'] ?? '',
      'userAddress':
          widget.userData?['address'] ?? widget.userData?['location'] ?? '',
      'userOccupation':
          widget.userData?['occupation'] ?? widget.userData?['jobType'] ?? '',
      'userMonthlyIncome': widget.userData?['monthlyIncome'] ?? 0,

      // Application details
      'reason': _reasonController.text.trim(),
      'applicationReason': _reasonController.text.trim(),
      'notes': '',
      'adminNotes': '',

      // Status management (unified)
      'status': 'pending',
      'applicationStatus': 'pending',
      'priority': 'normal',

      // Timestamps (unified)
      'submissionDate': FieldValue.serverTimestamp(),
      'submittedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      // Application metadata
      'applicationSource': 'user_mobile_app',
      'applicationVersion': '1.0',
      'deviceInfo': 'mobile',
    };
  }

  /// Menampilkan pesan sukses
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengajuan berhasil dikirim!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Menampilkan pesan error
  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal mengirim pengajuan: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajukan Program'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Program: ${widget.programData['programName']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Alasan pengajuan:'),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Jelaskan mengapa Anda membutuhkan program ini...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitApplication,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Kirim Pengajuan'),
        ),
      ],
    );
  }
}
