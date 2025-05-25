import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_program_card_widget.dart';
import '../../data/admin_program_service.dart';

class AdminProgramListPage extends StatefulWidget {
  const AdminProgramListPage({super.key});

  @override
  State<AdminProgramListPage> createState() => _AdminProgramListPageState();
}

class _AdminProgramListPageState extends State<AdminProgramListPage>
    with TickerProviderStateMixin {
  final AdminProgramService _programService = AdminProgramService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _filteredPrograms = [];
  String _searchText = '';
  String? _selectedCategoryFilter;
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filter options
  final List<String> _categories = [
    'Semua Kategori',
    'Kesehatan',
    'Pendidikan',
    'Ekonomi', // ✅ FIXED: Changed from 'Modal Usaha'
    'Bantuan Sosial', // ✅ FIXED: Changed from 'Makanan Pokok'
  ];

  final List<String> _statuses = [
    'Semua Status',
    'active',
    'inactive',
    'closed',
    'upcoming',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryFilter = _categories.first;
    _selectedStatusFilter = _statuses.first;

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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _loadPrograms();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadPrograms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final programs = await _programService.getAllPrograms();
      setState(() {
        _allPrograms = programs;
        _filteredPrograms = programs;
        _isLoading = false;
      });
      _filterPrograms();
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data program: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterPrograms() {
    List<Map<String, dynamic>> programs =
        _allPrograms.where((program) {
          final nameLower =
              (program['programName'] as String? ?? '').toLowerCase();
          final searchTextLower = _searchText.toLowerCase();

          // Search filter
          final searchMatch = nameLower.contains(searchTextLower);

          // Category filter
          final categoryMatch =
              _selectedCategoryFilter == _categories.first ||
              program['category'] == _selectedCategoryFilter;

          // Status filter
          final statusMatch =
              _selectedStatusFilter == _statuses.first ||
              program['status'] == _selectedStatusFilter;

          return searchMatch && categoryMatch && statusMatch;
        }).toList();

    setState(() {
      _filteredPrograms = programs;
    });
  }

  void _viewProgramDetail(String programId) {
    context.go('${RouteNames.adminProgramDetail}/$programId');
  }

  void _editProgram(String programId) {
    // ✅ FIXED: Navigate to edit page instead of detail page
    context.go('/admin/programs/edit/$programId');
  }

  Future<void> _deleteProgram(String programId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            icon: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_forever_rounded,
                color: Colors.red.shade600,
                size: 48,
              ),
            ),
            title: const Text(
              'Konfirmasi Hapus Program',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'Apakah Anda yakin ingin menghapus program ini? Tindakan ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _programService.deleteProgram(programId);
        if (success) {
          _showSuccessSnackBar('Program berhasil dihapus');
          await _loadPrograms();
        } else {
          _showErrorSnackBar('Gagal menghapus program');
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addProgram() {
    context.go(RouteNames.adminAddProgram);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
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

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'closed':
        return 'Ditutup';
      case 'upcoming':
        return 'Akan Datang';
      default:
        return status;
    }
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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar(),

              // Main Content
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingWidget()
                        : _errorMessage != null
                        ? _buildErrorWidget()
                        : _buildProgramListContent(),
              ),
            ],
          ),
        ),
      ),
      drawer: const AdminNavigationDrawer(),
      // Tambahkan FloatingActionButton di sini
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  'Manajemen Program',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola program bantuan sosial',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
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
              onPressed: _isLoading ? null : _loadPrograms,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'Memuat data program...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPrograms,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramListContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Search and Filters Section
              _buildSearchAndFilters(),

              // Programs List
              Expanded(
                child:
                    _filteredPrograms.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                          onRefresh: _loadPrograms,
                          color: Colors.blue.shade700,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 100),
                            itemCount: _filteredPrograms.length,
                            itemBuilder: (context, index) {
                              final program = _filteredPrograms[index];
                              return AdminProgramCardWidget(
                                program: {
                                  'id': program['id'],
                                  'nama_program': program['programName'],
                                  'kategori': program['category'],
                                  'status': _getStatusDisplayName(
                                    program['status'],
                                  ),
                                  'jumlah_pengajuan':
                                      program['totalApplications'],
                                  'imageUrl': program['imageUrl'],
                                },
                                onViewDetail:
                                    () => _viewProgramDetail(program['id']),
                                onEdit: () => _editProgram(program['id']),
                                onDelete: () => _deleteProgram(program['id']),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama program...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
                _filterPrograms();
              },
            ),
          ),
          const SizedBox(height: 16),

          // Filters Row
          Row(
            children: [
              // Category Filter
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedCategoryFilter,
                    items:
                        _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategoryFilter = newValue;
                      });
                      _filterPrograms();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status Filter
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedStatusFilter,
                    items:
                        _statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status == 'Semua Status'
                                  ? status
                                  : _getStatusDisplayName(status),
                            ),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatusFilter = newValue;
                      });
                      _filterPrograms();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada program ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter pencarian Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Tambahkan button untuk add program di empty state juga
          ElevatedButton.icon(
            onPressed: _addProgram,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Program Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget FloatingActionButton yang sebelumnya hilang
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _addProgram,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Tambah Program',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
