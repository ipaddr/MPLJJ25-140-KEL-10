import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_submission_service.dart';

/// Halaman untuk mengedit status dan catatan pengajuan bantuan oleh admin
///
/// Memungkinkan admin untuk memperbarui status pengajuan (Baru, Diproses,
/// Disetujui, Ditolak) dan menambahkan catatan review.
class AdminEditSubmissionPage extends StatefulWidget {
  final String submissionId;

  const AdminEditSubmissionPage({super.key, required this.submissionId});

  @override
  State<AdminEditSubmissionPage> createState() =>
      _AdminEditSubmissionPageState();
}

class _AdminEditSubmissionPageState extends State<AdminEditSubmissionPage>
    with TickerProviderStateMixin {
  // Services
  final AdminSubmissionService _submissionService = AdminSubmissionService();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // UI Constants
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _miniSpacing = 8.0;
  static const double _tinySpacing = 4.0;

  static const double _borderRadius = 24.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;

  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;

  static const double _titleFontSize = 24.0;
  static const double _subtitleFontSize = 20.0;
  static const double _bodyFontSize = 18.0;
  static const double _smallFontSize = 16.0;
  static const double _captionFontSize = 14.0;
  static const double _microFontSize = 13.0;

  // State variables
  Map<String, dynamic>? _submissionData;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _reviewNotesController = TextEditingController();
  String? _selectedStatus;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Status options
  final List<StatusOption> _statusOptions = [
    StatusOption('Baru', 'Baru', Colors.blue, Icons.fiber_new_rounded),
    StatusOption(
      'Diproses',
      'Diproses',
      Colors.orange,
      Icons.hourglass_empty_rounded,
    ),
    StatusOption(
      'Disetujui',
      'Disetujui',
      Colors.green,
      Icons.check_circle_rounded,
    ),
    StatusOption('Ditolak', 'Ditolak', Colors.red, Icons.cancel_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSubmissionData();
  }

  /// Initializes the animations for this page
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reviewNotesController.dispose();
    super.dispose();
  }

  /// Loads submission data from the service
  Future<void> _loadSubmissionData() async {
    try {
      final submissionData = await _submissionService.getSubmissionById(
        widget.submissionId,
      );

      if (submissionData != null && mounted) {
        setState(() {
          _submissionData = submissionData;
          _selectedStatus = submissionData['status'];
          _reviewNotesController.text = submissionData['notes'] ?? '';
          _isLoading = false;
        });
        _animationController.forward();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Pengajuan tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data pengajuan: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Updates the submission with new status and notes
  Future<void> _updateSubmission() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStatus == null) {
      _showErrorMessage('Pilih status pengajuan');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _submissionService.updateSubmissionStatus(
        submissionId: widget.submissionId,
        newStatus: _selectedStatus!,
        notes:
            _reviewNotesController.text.trim().isEmpty
                ? null
                : _reviewNotesController.text.trim(),
        status: _selectedStatus!,
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorMessage('Gagal memperbarui pengajuan');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Shows a success dialog after successful update
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius - 4),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(_midSpacing),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 60,
                  ),
                ),
                const SizedBox(height: _midSpacing),
                const Text(
                  'Pengajuan Berhasil Diperbarui!',
                  style: TextStyle(
                    fontSize: _subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _microSpacing),
                Text(
                  'Status pengajuan telah berhasil diperbarui.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: _captionFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _spacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.adminSubmissionManagement);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: _microSpacing,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_smallBorderRadius),
                      ),
                    ),
                    child: const Text(
                      'Kembali ke Daftar Pengajuan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Shows an error message using a snackbar
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: _miniSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
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
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade700,
              Colors.orange.shade500,
            ],
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
                    child: _buildContentArea(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade900, Colors.orange.shade600],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: _smallSpacing),
              Text(
                'Memuat data pengajuan...',
                style: TextStyle(color: Colors.white, fontSize: _smallFontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the error screen
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
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: _smallSpacing),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: _smallFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _spacing),
              ElevatedButton(
                onPressed:
                    () => context.go(RouteNames.adminSubmissionManagement),
                child: const Text('Kembali ke Daftar Pengajuan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the custom app bar
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go(RouteNames.adminSubmissionManagement),
            ),
          ),
          const SizedBox(width: _smallSpacing),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Perbarui status dan catatan pengajuan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _captionFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Save Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: IconButton(
              icon:
                  _isSaving
                      ? const SizedBox(
                        width: _smallIconSize,
                        height: _smallIconSize,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save_rounded, color: Colors.white),
              onPressed: _isSaving ? null : _updateSubmission,
              tooltip: 'Simpan Perubahan',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main content area
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_spacing),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: _spacing),
                _buildSubmissionInfoSection(),
                const SizedBox(height: _spacing),
                _buildStatusUpdateSection(),
                const SizedBox(height: _spacing),
                _buildReviewNotesSection(),
                const SizedBox(height: _spacing + _miniSpacing),
                _buildUpdateButton(),
                const SizedBox(height: _spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header card
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_microSpacing),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: _iconSize,
            ),
          ),
          const SizedBox(width: _smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Edit Pengajuan',
                  style: TextStyle(
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: _tinySpacing),
                Text(
                  'Perbarui status dan catatan review pengajuan.',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: _captionFontSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the submission info section
  Widget _buildSubmissionInfoSection() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(_miniSpacing),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(_miniSpacing),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: _smallIconSize,
                ),
              ),
              const SizedBox(width: _microSpacing),
              Text(
                'Informasi Pengajuan',
                style: TextStyle(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),

          _buildInfoRow('Pemohon', _submissionData!['userName'] ?? 'N/A'),
          const SizedBox(height: _miniSpacing),
          _buildInfoRow('Program', _submissionData!['programName'] ?? 'N/A'),
          const SizedBox(height: _miniSpacing),
          _buildInfoRow('Email', _submissionData!['userEmail'] ?? 'N/A'),
          const SizedBox(height: _miniSpacing),
          _buildInfoRow(
            'Tanggal Pengajuan',
            _formatDate(_submissionData!['submissionDate']),
          ),
        ],
      ),
    );
  }

  /// Builds the status update section
  Widget _buildStatusUpdateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Update Status',
          Icons.edit_rounded,
          Colors.orange.shade700,
        ),
        const SizedBox(height: _smallSpacing),

        Text(
          'Pilih Status Baru',
          style: TextStyle(
            fontSize: _smallFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _microSpacing),

        _buildStatusOptionsGrid(),
      ],
    );
  }

  /// Builds the grid of status options
  Widget _buildStatusOptionsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: _microSpacing,
        mainAxisSpacing: _microSpacing,
      ),
      itemCount: _statusOptions.length,
      itemBuilder: (context, index) {
        final status = _statusOptions[index];
        final isSelected = _selectedStatus == status.value;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedStatus = status.value;
            });
          },
          child: _buildStatusOption(status, isSelected),
        );
      },
    );
  }

  /// Builds a single status option
  Widget _buildStatusOption(StatusOption status, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: isSelected ? status.color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(
          color: isSelected ? status.color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status.icon,
            color: isSelected ? status.color : Colors.grey.shade600,
            size: _smallIconSize,
          ),
          const SizedBox(width: _miniSpacing),
          Expanded(
            child: Text(
              status.label,
              style: TextStyle(
                color: isSelected ? status.color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: _microFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the review notes section
  Widget _buildReviewNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Catatan Review',
          Icons.note_rounded,
          Colors.orange.shade700,
        ),
        const SizedBox(height: _smallSpacing),

        TextFormField(
          controller: _reviewNotesController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Catatan Admin',
            hintText:
                'Berikan catatan atau alasan untuk status yang dipilih...',
            prefixIcon: Icon(
              Icons.note_add_rounded,
              color: Colors.orange.shade600,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallBorderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallBorderRadius),
              borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_smallBorderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            labelStyle: TextStyle(color: Colors.grey.shade700),
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: _captionFontSize,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the update button
  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
          onTap: _isSaving ? null : _updateSubmission,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child:
                _isSaving
                    ? const Center(
                      child: SizedBox(
                        width: _iconSize,
                        height: _iconSize,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: _iconSize,
                        ),
                        SizedBox(width: _microSpacing),
                        Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _bodyFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  /// Builds a section header with icon
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(_miniSpacing),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade100, Colors.orange.shade50],
            ),
            borderRadius: BorderRadius.circular(_miniSpacing),
          ),
          child: Icon(icon, color: color, size: _smallIconSize),
        ),
        const SizedBox(width: _microSpacing),
        Text(
          title,
          style: const TextStyle(
            fontSize: _subtitleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Builds an info row with label and value
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade700,
              fontSize: _captionFontSize,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: _captionFontSize,
            ),
          ),
        ),
      ],
    );
  }

  /// Formats a date from various date types
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
}

/// Status option class for improved type safety
class StatusOption {
  final String value;
  final String label;
  final MaterialColor color;
  final IconData icon;

  StatusOption(this.value, this.label, this.color, this.icon);
}
