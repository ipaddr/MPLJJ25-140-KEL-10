// filepath: lib/features/admin/submission_management/presentation/pages/admin_edit_submission_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_submission_service.dart';

class AdminEditSubmissionPage extends StatefulWidget {
  final String submissionId;

  const AdminEditSubmissionPage({
    super.key,
    required this.submissionId,
  });

  @override
  State<AdminEditSubmissionPage> createState() => _AdminEditSubmissionPageState();
}

class _AdminEditSubmissionPageState extends State<AdminEditSubmissionPage>
    with TickerProviderStateMixin {
  final AdminSubmissionService _submissionService = AdminSubmissionService();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _submissionData;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Form controllers
  final TextEditingController _reviewNotesController = TextEditingController();
  String? _selectedStatus;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Status options
  final List<Map<String, dynamic>> _statusOptions = [
    {'value': 'Baru', 'label': 'Baru', 'color': Colors.blue, 'icon': Icons.fiber_new_rounded},
    {'value': 'Diproses', 'label': 'Diproses', 'color': Colors.orange, 'icon': Icons.hourglass_empty_rounded},
    {'value': 'Disetujui', 'label': 'Disetujui', 'color': Colors.green, 'icon': Icons.check_circle_rounded},
    {'value': 'Ditolak', 'label': 'Ditolak', 'color': Colors.red, 'icon': Icons.cancel_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSubmissionData();
  }

  void _setupAnimations() {
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _reviewNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissionData() async {
    try {
      final submissionData = await _submissionService.getSubmissionById(widget.submissionId);

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
        notes: _reviewNotesController.text.trim().isEmpty 
            ? null 
            : _reviewNotesController.text.trim(),
        status: _selectedStatus!,
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else {
        _showErrorMessage('Gagal memperbarui pengajuan');
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            const Text(
              'Pengajuan Berhasil Diperbarui!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Status pengajuan telah berhasil diperbarui.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
                SizedBox(height: 16),
                Text(
                  'Memuat data pengajuan...',
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
            colors: [Colors.orange.shade900, Colors.orange.shade700, Colors.orange.shade500],
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

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Perbarui status dan catatan pengajuan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Save Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
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

  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // Submission Info Section
                _buildSubmissionInfoSection(),
                const SizedBox(height: 24),

                // Status Update Section
                _buildStatusUpdateSection(),
                const SizedBox(height: 24),

                // Review Notes Section
                _buildReviewNotesSection(),
                const SizedBox(height: 32),

                // Update Button
                _buildUpdateButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Edit Pengajuan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perbarui status dan catatan review pengajuan.',
                  style: TextStyle(color: Colors.orange.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Informasi Pengajuan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Pemohon', _submissionData!['userName'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Program', _submissionData!['programName'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Email', _submissionData!['userEmail'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow('Tanggal Pengajuan', _formatDate(_submissionData!['submissionDate'])),
        ],
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_rounded, color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          'Pilih Status Baru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _statusOptions.length,
          itemBuilder: (context, index) {
            final status = _statusOptions[index];
            final isSelected = _selectedStatus == status['value'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = status['value'];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? status['color'].withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? status['color'] : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      status['icon'],
                      color: isSelected ? status['color'] : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status['label'],
                        style: TextStyle(
                          color: isSelected
                              ? status['color']
                              : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.note_rounded, color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Catatan Review',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _reviewNotesController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Catatan Admin',
            hintText: 'Berikan catatan atau alasan untuk status yang dipilih...',
            prefixIcon: Icon(Icons.note_add_rounded, color: Colors.orange.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            labelStyle: TextStyle(color: Colors.grey.shade700),
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: _isSaving ? null : _updateSubmission,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
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
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
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
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
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
}