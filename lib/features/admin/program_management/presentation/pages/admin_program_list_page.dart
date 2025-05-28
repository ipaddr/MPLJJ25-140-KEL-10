import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_program_card_widget.dart';
import '../../data/admin_program_service.dart';

/// Halaman untuk manajemen daftar program
/// 
/// Menampilkan daftar program yang dapat difilter, dicari, dan
/// menyediakan aksi untuk lihat detail, edit, dan hapus program
class AdminProgramListPage extends StatefulWidget {
  const AdminProgramListPage({super.key});

  @override
  State<AdminProgramListPage> createState() => _AdminProgramListPageState();
}

class _AdminProgramListPageState extends State<AdminProgramListPage>
    with TickerProviderStateMixin {
  // Services
  final AdminProgramService _programService = AdminProgramService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // State variables
  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _filteredPrograms = [];
  String _searchText = '';
  String? _selectedCategoryFilter;
  String? _selectedStatusFilter;
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
  
  static const double _borderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;
  
  static const double _iconSize = 24.0;
  static const double _largeIconSize = 48.0;
  static const double _microIconSize = 6.0;
  
  static const double _headingTextSize = 24.0;
  static const double _subheadingTextSize = 20.0;
  static const double _bodyTextSize = 16.0;
  static const double _captionTextSize = 14.0;
  static const double _smallTextSize = 12.0;

  // Filter options
  final List<String> _categories = [
    'Semua Kategori',
    'Kesehatan',
    'Pendidikan',
    'Ekonomi',
    'Bantuan Sosial',
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
    _initializeFilters();
    _initializeAnimations();
    _loadPrograms();
  }
  
  /// Inisialisasi filter default
  void _initializeFilters() {
    _selectedCategoryFilter = _categories.first;
    _selectedStatusFilter = _statuses.first;
  }
  
  /// Inisialisasi controller animasi
  void _initializeAnimations() {
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Memuat daftar program dari service
  Future<void> _loadPrograms() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final programs = await _programService.getAllPrograms();
      
      if (!mounted) return;
      
      setState(() {
        _allPrograms = programs;
        _filteredPrograms = programs;
        _isLoading = false;
      });
      
      _filterPrograms();
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Gagal memuat data program: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Filter program berdasarkan pencarian dan kategori yang dipilih
  void _filterPrograms() {
    List<Map<String, dynamic>> programs = _allPrograms.where((program) {
      final nameLower = (program['programName'] as String? ?? '').toLowerCase();
      final searchTextLower = _searchText.toLowerCase();

      // Search filter
      final searchMatch = nameLower.contains(searchTextLower);

      // Category filter
      final categoryMatch = _selectedCategoryFilter == _categories.first ||
                           program['category'] == _selectedCategoryFilter;

      // Status filter
      final statusMatch = _selectedStatusFilter == _statuses.first ||
                         program['status'] == _selectedStatusFilter;

      return searchMatch && categoryMatch && statusMatch;
    }).toList();

    if (!mounted) return;
    
    setState(() {
      _filteredPrograms = programs;
    });
  }

  /// Menuju halaman detail program
  void _viewProgramDetail(String programId) {
    context.go('${RouteNames.adminProgramDetail}/$programId');
  }

  /// Menuju halaman edit program
  void _editProgram(String programId) {
    context.go('/admin/programs/edit/$programId');
  }

  /// Menghapus program dengan konfirmasi dialog
  Future<void> _deleteProgram(String programId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmDeleteDialog(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _programService.deleteProgram(programId);
        
        if (!mounted) return;
        
        if (success) {
          _showSnackBar(
            'Program berhasil dihapus',
            Icons.check_circle,
            Colors.green.shade600,
          );
          await _loadPrograms();
        } else {
          _showSnackBar(
            'Gagal menghapus program',
            Icons.error_outline,
            Colors.red.shade600,
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        _showSnackBar(
          'Error: ${e.toString()}',
          Icons.error_outline,
          Colors.red.shade600,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Menampilkan dialog konfirmasi hapus program
  Widget _buildConfirmDeleteDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
      ),
      icon: Container(
        padding: const EdgeInsets.all(_spacing),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_forever_rounded,
          color: Colors.red.shade600,
          size: _largeIconSize,
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
    );
  }

  /// Menuju halaman tambah program
  void _addProgram() {
    context.go(RouteNames.adminAddProgram);
  }

  /// Menampilkan snackbar dengan pesan, ikon, dan warna tertentu
  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: _microSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius)
        ),
      ),
    );
  }

  /// Mendapatkan nama status yang ditampilkan ke user
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
      body: _buildMainContent(),
      drawer: const AdminNavigationDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  /// Membangun content utama halaman
  Widget _buildMainContent() {
    return Container(
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
            _buildCustomAppBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildProgramListContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: _spacing),
          _buildAppBarTitle(),
          _buildRefreshButton(),
        ],
      ),
    );
  }
  
  /// Membangun tombol menu di app bar
  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.menu_rounded,
          color: Colors.white,
          size: _iconSize,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
            'Manajemen Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: _headingTextSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Kelola program bantuan sosial',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: _captionTextSize,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Membangun tombol refresh di app bar
  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: AnimatedRotation(
          turns: _isLoading ? 1 : 0,
          duration: const Duration(milliseconds: 1000),
          child: const Icon(
            Icons.refresh_rounded,
            color: Colors.white,
            size: _iconSize,
          ),
        ),
        onPressed: _isLoading ? null : _loadPrograms,
      ),
    );
  }

  /// Membangun widget tampilan loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: _spacing),
            Text(
              'Memuat data program...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: _bodyTextSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun widget tampilan error
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(_largeSpacing),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(_spacing),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: _largeIconSize,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: _spacing),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: _subheadingTextSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _microSpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: _captionTextSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _largeSpacing),
            ElevatedButton.icon(
              onPressed: _loadPrograms,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_smallBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun konten daftar program dengan animasi
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
              _buildSearchAndFilters(),
              _buildProgramList(),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Membangun bagian daftar program
  Widget _buildProgramList() {
    return Expanded(
      child: _filteredPrograms.isEmpty
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
                      'jumlah_pengajuan': program['totalApplications'],
                      'imageUrl': program['imageUrl'],
                    },
                    onViewDetail: () => _viewProgramDetail(program['id']),
                    onEdit: () => _editProgram(program['id']),
                    onDelete: () => _deleteProgram(program['id']),
                  );
                },
              ),
            ),
    );
  }

  /// Membangun bagian pencarian dan filter
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: _spacing),
          _buildFilters(),
        ],
      ),
    );
  }
  
  /// Membangun search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
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
            horizontal: _spacing,
            vertical: _spacing,
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
    );
  }
  
  /// Membangun filter kategori dan status
  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(child: _buildCategoryFilter()),
        const SizedBox(width: _smallSpacing),
        Expanded(child: _buildStatusFilter()),
      ],
    );
  }
  
  /// Membangun filter kategori
  Widget _buildCategoryFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Kategori',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _spacing,
            vertical: _smallSpacing,
          ),
        ),
        value: _selectedCategoryFilter,
        items: _categories.map((String category) {
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
    );
  }
  
  /// Membangun filter status
  Widget _buildStatusFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Status',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _spacing,
            vertical: _smallSpacing,
          ),
        ),
        value: _selectedStatusFilter,
        items: _statuses.map((String status) {
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
    );
  }

  /// Membangun tampilan kosong saat tidak ada program yang ditemukan
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
          const SizedBox(height: _spacing),
          const Text(
            'Tidak ada program ditemukan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _microSpacing),
          Text(
            'Coba ubah filter pencarian Anda',
            style: TextStyle(fontSize: _captionTextSize, color: Colors.grey.shade600),
          ),
          const SizedBox(height: _largeSpacing),
          ElevatedButton.icon(
            onPressed: _addProgram,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Program Pertama'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallBorderRadius),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun floating action button
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _addProgram,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: _iconSize),
        label: const Text(
          'Tambah Program',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: _bodyTextSize,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mediumBorderRadius)
        ),
      ),
    );
  }
}