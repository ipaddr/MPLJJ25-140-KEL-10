import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_submission_card_widget.dart';
import '../../data/admin_submission_service.dart';
import 'package:intl/intl.dart';

/// Halaman untuk menampilkan dan mengelola daftar pengajuan bantuan
///
/// Menyediakan fitur untuk melihat semua pengajuan, memfilter berdasarkan
/// program dan status, serta melakukan approval atau rejection terhadap pengajuan.
class AdminSubmissionListPage extends StatefulWidget {
  const AdminSubmissionListPage({super.key});

  @override
  State<AdminSubmissionListPage> createState() => _AdminSubmissionListPageState();
}

class _AdminSubmissionListPageState extends State<AdminSubmissionListPage> with TickerProviderStateMixin {
  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Services
  final AdminSubmissionService _submissionService = AdminSubmissionService();

  // UI Constants
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _miniSpacing = 4.0;
  
  static const double _borderRadius = 24.0;
  static const double _cardBorderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;
  
  static const double _largeIconSize = 64.0;
  static const double _mediumIconSize = 48.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;
  
  static const double _titleTextSize = 24.0;
  static const double _subtitleTextSize = 18.0;
  static const double _normalTextSize = 16.0;
  static const double _smallTextSize = 14.0;
  static const double _microTextSize = 12.0;
  
  // State variables
  List<Map<String, dynamic>> _allSubmissions = [];
  List<Map<String, dynamic>> _filteredSubmissions = [];
  List<String> _programNames = ['Semua Program'];
  Map<String, int> _statusCounts = {};

  String? _selectedProgramFilter;
  String? _selectedStatusFilter;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _isLoading = true;
  bool _isFiltering = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Status options data
  final List<StatusOption> _statusOptions = [
    StatusOption('Semua Status', Icons.all_inclusive_rounded, Colors.grey),
    StatusOption('Baru', Icons.fiber_new_rounded, Colors.blue),
    StatusOption('Diproses', Icons.hourglass_empty_rounded, Colors.orange),
    StatusOption('Disetujui', Icons.check_circle_rounded, Colors.green),
    StatusOption('Ditolak', Icons.cancel_rounded, Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeFilters();
    _loadSubmissions();
  }

  /// Initialize animation controllers and animations
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

  /// Initialize default filter values
  void _initializeFilters() {
    _selectedProgramFilter = _programNames.first;
    _selectedStatusFilter = _statusOptions.first.value;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Load submissions data with current filters
  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all required data in parallel for better performance
      final results = await Future.wait([
        _submissionService.getProgramNames(),
        _submissionService.getAllSubmissions(
          programFilter: _selectedProgramFilter != 'Semua Program' ? _selectedProgramFilter : null,
          statusFilter: _selectedStatusFilter != 'Semua Status' ? _selectedStatusFilter : null,
          startDate: _startDateFilter,
          endDate: _endDateFilter,
        ),
        _submissionService.getSubmissionsCountByStatus(),
      ]);

      if (mounted) {
        setState(() {
          _programNames = results[0] as List<String>;
          // Ensure selected program is in the list
          if (!_programNames.contains(_selectedProgramFilter)) {
            _selectedProgramFilter = _programNames.first;
          }
          _allSubmissions = results[1] as List<Map<String, dynamic>>;
          _filteredSubmissions = _allSubmissions;
          _statusCounts = results[2] as Map<String, int>;
          _isLoading = false;
        });

        // Start animations
        _fadeController.forward();
        _slideController.forward();
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

  /// Apply filters to reload submissions
  Future<void> _filterSubmissions() async {
    if (!mounted) return;
    
    setState(() {
      _isFiltering = true;
    });

    try {
      final submissions = await _submissionService.getAllSubmissions(
        programFilter: _selectedProgramFilter != 'Semua Program' ? _selectedProgramFilter : null,
        statusFilter: _selectedStatusFilter != 'Semua Status' ? _selectedStatusFilter : null,
        startDate: _startDateFilter,
        endDate: _endDateFilter,
      );

      if (mounted) {
        setState(() {
          _filteredSubmissions = submissions;
          _isFiltering = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memfilter data: ${e.toString()}';
          _isFiltering = false;
        });
        _showErrorSnackBar('Gagal memfilter data: ${e.toString()}');
      }
    }
  }

  /// Open date range picker dialog
  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDateFilter != null && _endDateFilter != null
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

  /// Clear date range filter
  void _clearDateFilter() {
    setState(() {
      _startDateFilter = null;
      _endDateFilter = null;
    });
    _filterSubmissions();
  }

  /// Navigate to submission detail page
  void _viewSubmissionDetail(String submissionId) {
    context.go('${RouteNames.adminSubmissionDetail}/$submissionId');
  }

  /// Navigate to submission edit page
  void _editSubmission(String submissionId) {
    context.go('${RouteNames.adminEditSubmission}/$submissionId');
  }

  /// Show confirmation dialog and approve submission if confirmed
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

  /// Show rejection dialog with notes field and reject if confirmed
  Future<void> _rejectSubmission(String submissionId) async {
    String? rejectionNotes;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildRejectionDialog(
        onNotesChanged: (value) => rejectionNotes = value,
      ),
    );

    if (confirmed == true) {
      await _performStatusUpdate(submissionId, 'reject', rejectionNotes);
    }
  }

  /// Show generic confirmation dialog for actions
  Future<bool?> _showActionDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required IconData icon,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(_microSpacing - 4),
              decoration: BoxDecoration(
                color: confirmColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_microSpacing),
              ),
              child: Icon(icon, color: confirmColor),
            ),
            const SizedBox(width: _microSpacing),
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
            icon: Icon(icon, size: _microIconSize + 2),
            label: Text(confirmText),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_microSpacing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Update submission status with service
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
      final defaultNote = action == 'approve' 
          ? 'Disetujui oleh admin' 
          : 'Ditolak oleh admin';
      
      if (action == 'approve') {
        success = await _submissionService.approveSubmission(
          submissionId: submissionId,
          notes: notes ?? defaultNote,
        );
      } else {
        success = await _submissionService.rejectSubmission(
          submissionId: submissionId,
          notes: notes?.isNotEmpty == true ? notes! : defaultNote,
        );
      }

      if (success && mounted) {
        _showSuccessSnackBar(
          action == 'approve'
              ? 'Pengajuan berhasil disetujui'
              : 'Pengajuan berhasil ditolak',
        );
        await _loadSubmissions(); // Reload all data including counts
      } else if (mounted) {
        _showErrorSnackBar(
          action == 'approve'
              ? 'Gagal menyetujui pengajuan'
              : 'Gagal menolak pengajuan',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show success message in a snackbar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: _tinySpacing),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_microSpacing)),
      ),
    );
  }

  /// Show error message in a snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: _tinySpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_microSpacing)),
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
                child: _isLoading && _filteredSubmissions.isEmpty
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

  /// Build the custom app bar at the top of the page
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      child: Row(
        children: [
          // Menu Button
          _buildAppBarButton(
            icon: Icons.menu_rounded,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: _smallSpacing),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Pengajuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _titleTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola pengajuan bantuan sosial',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _smallTextSize,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          _buildAppBarButton(
            icon: Icons.refresh_rounded,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _loadSubmissions,
          ),
        ],
      ),
    );
  }

  /// Build app bar button with consistent styling
  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: _iconSize - 4,
                height: _iconSize - 4,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                icon,
                color: Colors.white,
                size: _iconSize,
              ),
        onPressed: onPressed,
      ),
    );
  }

  /// Build loading indicator widget with container
  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(_spacing),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(_mediumBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blue.shade600,
                strokeWidth: 3,
              ),
              const SizedBox(height: _smallSpacing),
              Text(
                'Memuat data pengajuan...',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: _normalTextSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build error message widget with retry button
  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(_midSpacing),
          padding: const EdgeInsets.all(_spacing),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(_mediumBorderRadius),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(_smallSpacing),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: _mediumIconSize,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: _smallSpacing),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: _subtitleTextSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _tinySpacing),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: _smallTextSize),
              ),
              const SizedBox(height: _midSpacing),
              ElevatedButton.icon(
                onPressed: _loadSubmissions,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_smallBorderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main content area with stats, filters, and list
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
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

          // Extra space at bottom for better scrolling experience
          const SizedBox(height: _midSpacing),
        ],
      ),
    );
  }

  /// Build statistics section with status cards
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue.shade700),
              const SizedBox(width: _tinySpacing),
              const Text(
                'Statistik Pengajuan',
                style: TextStyle(fontSize: _subtitleTextSize, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          _buildStatsCards(),
        ],
      ),
    );
  }
  
  /// Build the horizontal scrollable stats cards
  Widget _buildStatsCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _statusOptions
            .where((status) => status.value != 'Semua Status')
            .map((status) => _buildStatCard(status))
            .toList(),
      ),
    );
  }
  
  /// Build individual stat card
  Widget _buildStatCard(StatusOption status) {
    final count = _statusCounts[status.value] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(right: _microSpacing),
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status.color.withOpacity(0.1),
            status.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(_tinySpacing),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(_microSpacing),
            ),
            child: Icon(
              status.icon,
              color: Colors.white,
              size: _smallIconSize,
            ),
          ),
          const SizedBox(height: _tinySpacing),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: _midSpacing,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
          Text(
            status.value,
            style: TextStyle(
              fontSize: _microTextSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build filters section with dropdowns and date range
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _midSpacing, vertical: _smallSpacing),
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
              const SizedBox(width: _tinySpacing),
              Text(
                'Filter Pengajuan',
                style: TextStyle(
                  fontSize: _normalTextSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),

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
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  items: _statusOptions.map((s) => s.value).toList(),
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
          const SizedBox(height: _smallSpacing),

          // Date Range Filter
          _buildDateRangeFilter(),
        ],
      ),
    );
  }

  /// Build dropdown filter with consistent styling
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
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _smallSpacing,
          vertical: _microSpacing,
        ),
      ),
      value: value,
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: _smallTextSize),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Build date range filter control
  Widget _buildDateRangeFilter() {
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(_smallBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(_smallSpacing),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Colors.blue.shade600),
            const SizedBox(width: _microSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rentang Tanggal',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: _microTextSize),
                  ),
                  const SizedBox(height: _miniSpacing - 2),
                  Text(
                    _startDateFilter == null || _endDateFilter == null
                        ? 'Pilih rentang tanggal'
                        : '${DateFormat('dd MMM yyyy').format(_startDateFilter!)} - ${DateFormat('dd MMM yyyy').format(_endDateFilter!)}',
                    style: const TextStyle(
                      fontSize: _smallTextSize,
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

  /// Build submissions list with refresh indicator
  Widget _buildSubmissionsList() {
    if (_isFiltering) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredSubmissions.isEmpty) {
      return _buildEmptySubmissionsMessage();
    }

    return RefreshIndicator(
      onRefresh: _loadSubmissions,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          _smallSpacing,
          _smallSpacing,
          _smallSpacing,
          _spacing,
        ),
        itemCount: _filteredSubmissions.length,
        itemBuilder: (context, index) {
          final submission = _filteredSubmissions[index];
          return _buildSubmissionCard(submission);
        },
      ),
    );
  }

  /// Build empty state message for when no submissions match filters
  Widget _buildEmptySubmissionsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_spacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_midSpacing),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: _largeIconSize,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: _midSpacing),
            Text(
              'Tidak ada pengajuan',
              style: TextStyle(
                fontSize: _subtitleTextSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: _tinySpacing),
            Text(
              'Belum ada pengajuan yang sesuai dengan filter yang dipilih',
              style: TextStyle(color: Colors.grey.shade500, fontSize: _smallTextSize),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual submission card
  Widget _buildSubmissionCard(Map<String, dynamic> submission) {
    final submissionDate = submission['submissionDate'] as Timestamp?;

    return Padding(
      padding: const EdgeInsets.only(bottom: _microSpacing),
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
  }

  /// Build rejection dialog with notes field
  Widget _buildRejectionDialog({
    required Function(String) onNotesChanged,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_tinySpacing),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(_microSpacing),
            ),
            child: Icon(Icons.cancel_rounded, color: Colors.red.shade600),
          ),
          const SizedBox(width: _microSpacing),
          const Text('Konfirmasi Penolakan'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apakah Anda yakin ingin menolak pengajuan ini?'),
          const SizedBox(height: _smallSpacing),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Alasan penolakan (opsional)',
              hintText: 'Masukkan alasan mengapa pengajuan ditolak...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_smallBorderRadius),
              ),
              prefixIcon: Icon(
                Icons.note_add_rounded,
                color: Colors.grey.shade600,
              ),
            ),
            maxLines: 3,
            onChanged: onNotesChanged,
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
          icon: const Icon(Icons.cancel_rounded, size: _microIconSize + 2),
          label: const Text('Tolak'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_microSpacing),
            ),
          ),
        ),
      ],
    );
  }
}

/// Status option data class for improved type safety
class StatusOption {
  final String value;
  final IconData icon;
  final Color color;

  const StatusOption(this.value, this.icon, this.color);
}