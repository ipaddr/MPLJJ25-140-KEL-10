import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_submission_card_widget.dart';
import '../../data/admin_submission_service.dart';
import 'package:intl/intl.dart';

class AdminSubmissionListPage extends StatefulWidget {
  const AdminSubmissionListPage({super.key});

  @override
  State<AdminSubmissionListPage> createState() =>
      _AdminSubmissionListPageState();
}

class _AdminSubmissionListPageState extends State<AdminSubmissionListPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminSubmissionService _submissionService = AdminSubmissionService();

  List<Map<String, dynamic>> _allSubmissions = [];
  List<Map<String, dynamic>> _filteredSubmissions = [];
  List<String> _programNames = ['Semua Program'];
  Map<String, int> _statusCounts = {};

  String? _selectedProgramFilter;
  String? _selectedStatusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _statuses = [
    {
      'value': 'Semua Status',
      'icon': Icons.all_inclusive_rounded,
      'color': Colors.grey,
    },
    {'value': 'Baru', 'icon': Icons.fiber_new_rounded, 'color': Colors.blue},
    {
      'value': 'Diproses',
      'icon': Icons.hourglass_empty_rounded,
      'color': Colors.orange,
    },
    {
      'value': 'Disetujui',
      'icon': Icons.check_circle_rounded,
      'color': Colors.green,
    },
    {'value': 'Ditolak', 'icon': Icons.cancel_rounded, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _selectedProgramFilter = _programNames.first;
    _selectedStatusFilter = _statuses.first['value'];
    _loadSubmissions();
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

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _submissionService.getProgramNames(),
        _submissionService.getAllSubmissions(
          programFilter:
              _selectedProgramFilter != 'Semua Program'
                  ? _selectedProgramFilter
                  : null,
          statusFilter:
              _selectedStatusFilter != 'Semua Status'
                  ? _selectedStatusFilter
                  : null,
          startDate: _startDateFilter,
          endDate: _endDateFilter,
        ),
        _submissionService.getSubmissionsCountByStatus(),
      ]);

      final programNames = results[0] as List<String>;
      final submissions = results[1] as List<Map<String, dynamic>>;
      final statusCounts = results[2] as Map<String, int>;

      setState(() {
        _programNames = programNames;
        if (!_programNames.contains(_selectedProgramFilter)) {
          _selectedProgramFilter = _programNames.first;
        }
        _allSubmissions = submissions;
        _filteredSubmissions = submissions;
        _statusCounts = statusCounts;
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengajuan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _filterSubmissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final submissions = await _submissionService.getAllSubmissions(
        programFilter:
            _selectedProgramFilter != 'Semua Program'
                ? _selectedProgramFilter
                : null,
        statusFilter:
            _selectedStatusFilter != 'Semua Status'
                ? _selectedStatusFilter
                : null,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      setState(() {
        _filteredSubmissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memfilter data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _startDateFilter != null && _endDateFilter != null
              ? DateTimeRange(start: _startDateFilter!, end: _endDateFilter!)
              : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDateFilter = picked.start;
        _endDateFilter = picked.end;
      });
      await _filterSubmissions();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDateFilter = null;
      _endDateFilter = null;
    });
    _filterSubmissions();
  }

  void _viewSubmissionDetail(String submissionId) {
    context.go('${RouteNames.adminSubmissionDetail}/$submissionId');
  }

  // ✅ NEW: Edit submission method
  void _editSubmission(String submissionId) {
    context.go('${RouteNames.adminEditSubmission}/$submissionId');
  }

  Future<void> _approveSubmission(String submissionId) async {
    final confirmed = await _showActionDialog(
      title: 'Konfirmasi Persetujuan',
      content: 'Apakah Anda yakin ingin menyetujui pengajuan ini?',
      confirmText: 'Setujui',
      confirmColor: Colors.green,
      icon: Icons.check_circle_rounded,
    );

    if (confirmed == true) {
      await _performStatusUpdate(submissionId, 'approve');
    }
  }

  Future<void> _rejectSubmission(String submissionId) async {
    String? rejectionNotes;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.cancel_rounded, color: Colors.red.shade600),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Penolakan'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Apakah Anda yakin ingin menolak pengajuan ini?'),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Alasan penolakan (opsional)',
                    hintText: 'Masukkan alasan mengapa pengajuan ditolak...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.note_add_rounded,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (value) => rejectionNotes = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.cancel_rounded, size: 18),
                label: const Text('Tolak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _performStatusUpdate(submissionId, 'reject', rejectionNotes);
    }
  }

  Future<bool?> _showActionDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: confirmColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: confirmColor),
                ),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: Icon(icon, size: 18),
                label: Text(confirmText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _performStatusUpdate(
    String submissionId,
    String action, [
    String? notes,
  ]) async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (action == 'approve') {
        success = await _submissionService.approveSubmission(
          submissionId: submissionId,
          notes: 'Disetujui oleh admin',
        );
      } else {
        success = await _submissionService.rejectSubmission(
          submissionId: submissionId,
          notes: notes?.isNotEmpty == true ? notes! : 'Ditolak oleh admin',
        );
      }

      if (success) {
        _showSuccessSnackBar(
          action == 'approve'
              ? 'Pengajuan berhasil disetujui'
              : 'Pengajuan berhasil ditolak',
        );
        await _loadSubmissions(); // Reload all data including counts
      } else {
        _showErrorSnackBar(
          action == 'approve'
              ? 'Gagal menyetujui pengajuan'
              : 'Gagal menolak pengajuan',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
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
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child:
                    _isLoading && _filteredSubmissions.isEmpty
                        ? _buildLoadingWidget()
                        : _errorMessage != null
                        ? _buildErrorWidget()
                        : FadeTransition(
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
      drawer: const AdminNavigationDrawer(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Menu Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola pengajuan bantuan sosial',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: AnimatedRotation(
                turns: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 1000),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              onPressed: _isLoading ? null : _loadSubmissions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blue.shade600,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Memuat data pengajuan...',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadSubmissions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      child: Column(
        children: [
          // Statistics Cards
          _buildStatsSection(),

          // Filters Section
          _buildFiltersSection(),

          // Submissions List
          Expanded(child: _buildSubmissionsList()),

          // ✅ ADDED: Extra space at bottom for better scrolling experience
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Statistik Pengajuan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _statuses.skip(1).map((status) {
                    final count = _statusCounts[status['value']] ?? 0;
                    final color = status['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.1),
                            color.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              status['icon'] as IconData,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            status['value'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list_rounded, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Filter Pengajuan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Program and Status Filters
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Program',
                  value: _selectedProgramFilter,
                  items: _programNames,
                  onChanged: (value) {
                    setState(() {
                      _selectedProgramFilter = value;
                    });
                    _filterSubmissions();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  items: _statuses.map((s) => s['value'] as String).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value;
                    });
                    _filterSubmissions();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Range Filter
          _buildDateRangeFilter(),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateRangeFilter() {
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rentang Tanggal',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _startDateFilter == null || _endDateFilter == null
                        ? 'Pilih rentang tanggal'
                        : '${DateFormat('dd MMM yyyy').format(_startDateFilter!)} - ${DateFormat('dd MMM yyyy').format(_endDateFilter!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_startDateFilter != null)
              IconButton(
                icon: Icon(Icons.clear_rounded, color: Colors.grey.shade600),
                onPressed: _clearDateFilter,
                tooltip: 'Hapus Filter',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredSubmissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada pengajuan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada pengajuan yang sesuai dengan filter yang dipilih',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ), // ✅ REDUCED: 32px bottom padding (like user management)
        itemCount: _filteredSubmissions.length,
        itemBuilder: (context, index) {
          final submission = _filteredSubmissions[index];
          final submissionDate = submission['submissionDate'] as Timestamp?;

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ), // ✅ CONSISTENT: 12px spacing between cards
            child: AdminSubmissionCardWidget(
              submission: {
                'id': submission['id'],
                'user_name': submission['userName'],
                'program_name': submission['programName'],
                'status': submission['status'],
                'submission_date': submissionDate?.toDate(),
              },
              onViewDetail: () => _viewSubmissionDetail(submission['id']),
              onApprove: () => _approveSubmission(submission['id']),
              onReject: () => _rejectSubmission(submission['id']),
              onEdit: () => _editSubmission(submission['id']),
            ),
          );
        },
      ),
    );
  }
}
