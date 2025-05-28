import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_content_card_widget.dart';
import '../../data/admin_content_service.dart';
import '../../data/models/content_model.dart';

/// Halaman untuk mengelola daftar konten edukasi dalam panel admin
class AdminContentListPage extends StatefulWidget {
  const AdminContentListPage({super.key});

  @override
  State<AdminContentListPage> createState() => _AdminContentListPageState();
}

class _AdminContentListPageState extends State<AdminContentListPage>
    with TickerProviderStateMixin {
  // Services & Controllers
  final AdminContentService _contentService = AdminContentService();
  final TextEditingController _searchController = TextEditingController();
  
  // State variables
  List<ContentModel> _allContent = [];
  List<ContentModel> _filteredContent = [];
  String _searchText = '';
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // List data
  final List<String> _statuses = [
    'Semua Status',
    'Dipublikasikan',
    'Draf',
    'Diarsip',
  ];
  
  // UI Constants
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;
  static const double _spacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _iconSize = 24.0;
  static const double _headingSize = 22.0;
  static const double _subheadingSize = 14.0;
  static const Duration _animationDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _selectedStatusFilter = _statuses.first;
    _setupAnimation();
    _loadContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Setup animasi fade in
  void _setupAnimation() {
    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  /// Memuat daftar konten dari service
  Future<void> _loadContent() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await _contentService.getAllContent();
      
      if (!mounted) return;
      
      setState(() {
        _allContent = content;
        _filteredContent = content;
        _isLoading = false;
      });
      
      _fadeController.reset();
      _fadeController.forward();
    } catch (e) {
      debugPrint('Error loading content: $e');
      
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Gagal memuat konten: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Filter konten berdasarkan pencarian dan status
  void _filterContent() {
    if (!mounted) return;
    
    final searchTextLower = _searchText.toLowerCase();
    
    List<ContentModel> filtered = _allContent.where((item) {
      final titleLower = item.title.toLowerCase();
      final contentLower = item.content.toLowerCase();

      // Search filter
      final searchMatch = searchTextLower.isEmpty || 
                         titleLower.contains(searchTextLower) || 
                         contentLower.contains(searchTextLower);

      // Status filter
      final statusMatch = _selectedStatusFilter == _statuses.first ||
          AdminContentService.getStatusDisplayName(item.status) == _selectedStatusFilter;

      return searchMatch && statusMatch;
    }).toList();

    setState(() {
      _filteredContent = filtered;
    });
  }

  /// Navigasi ke halaman edit konten
  void _editContent(String contentId) {
    context.go('${RouteNames.adminContentEditor}/$contentId');
  }

  /// Menghapus konten dengan konfirmasi
  Future<void> _deleteContent(String contentId, String title) async {
    final confirmed = await _showDeleteConfirmationDialog(title);
    
    if (confirmed != true || !mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _contentService.deleteContent(contentId);
      
      if (!mounted) return;
      
      if (success) {
        _showSuccessSnackbar('Konten berhasil dihapus');
        await _loadContent();
      } else {
        _showErrorSnackbar('Gagal menghapus konten');
      }
    } catch (e) {
      debugPrint('Error deleting content: $e');
      
      if (!mounted) return;
      
      _showErrorSnackbar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menampilkan dialog konfirmasi penghapusan
  Future<bool?> _showDeleteConfirmationDialog(String title) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_smallBorderRadius)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_tinySpacing),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade700,
                size: _iconSize,
              ),
            ),
            const SizedBox(width: _smallSpacing - 4),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: _buildDeleteConfirmContent(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_tinySpacing),
              ),
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun konten dialog konfirmasi hapus
  Widget _buildDeleteConfirmContent(String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apakah Anda yakin ingin menghapus konten ini?',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: _microSpacing),
        Container(
          padding: const EdgeInsets.all(_microSpacing),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(_tinySpacing),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '"$title"',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: _microSpacing),
        Text(
          'Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Navigasi ke halaman tambah konten
  void _addContent() {
    context.go(RouteNames.adminAddContent);
  }

  /// Menampilkan snackbar sukses
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: _tinySpacing),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tinySpacing),
        ),
      ),
    );
  }

  /// Menampilkan snackbar error
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: _tinySpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tinySpacing),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      drawer: const AdminNavigationDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Membangun body utama
  Widget _buildBody() {
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
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildContentList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun custom app bar
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: _smallSpacing),
          Expanded(child: _buildTitleSection()),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  /// Membangun tombol menu
  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: Colors.white,
            size: _iconSize,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  /// Membangun bagian judul
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manajemen Konten',
          style: TextStyle(
            color: Colors.white,
            fontSize: _headingSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Kelola artikel dan konten edukasi',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: _subheadingSize,
          ),
        ),
      ],
    );
  }

  /// Membangun tombol refresh
  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
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
        onPressed: _isLoading ? null : _loadContent,
      ),
    );
  }

  /// Membangun widget pencarian dan filter
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(_spacing, 0, _spacing, _spacing),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: _smallSpacing),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  /// Membangun search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari judul atau konten artikel...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.blue.shade700,
          ),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                    });
                    _filterContent();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: _spacing,
            vertical: _smallSpacing,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
          _filterContent();
        },
      ),
    );
  }

  /// Membangun filter status
  Widget _buildStatusFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Filter Status',
          labelStyle: TextStyle(color: Colors.blue.shade700),
          prefixIcon: Icon(
            Icons.filter_list_rounded,
            color: Colors.blue.shade700,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: _spacing,
            vertical: _smallSpacing,
          ),
        ),
        value: _selectedStatusFilter,
        items: _statuses.map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue == null) return;
          
          setState(() {
            _selectedStatusFilter = newValue;
          });
          _filterContent();
        },
      ),
    );
  }

  /// Membangun widget loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_spacing),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_smallBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: _smallSpacing),
            const Text(
              'Memuat konten...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun widget error
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_spacing + 4),
        child: Container(
          padding: const EdgeInsets.all(_spacing + 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildErrorIcon(),
              const SizedBox(height: _smallSpacing),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _tinySpacing),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _spacing + 4),
              _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun icon error
  Widget _buildErrorIcon() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  /// Membangun tombol retry
  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: _loadContent,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Coba Lagi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(
          horizontal: _spacing + 4,
          vertical: _microSpacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
      ),
    );
  }

  /// Membangun daftar konten
  Widget _buildContentList() {
    if (_filteredContent.isEmpty) {
      return _buildEmptyContentList();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadContent,
        color: Colors.blue.shade700,
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: _filteredContent.length,
          itemBuilder: (context, index) {
            final content = _filteredContent[index];
            return AdminContentCardWidget(
              content: {
                'id': content.id,
                'title': content.title,
                'status': AdminContentService.getStatusDisplayName(content.status),
                'publish_date': content.publishedAt ?? content.updatedAt,
                'author': content.authorName,
                'view_count': content.viewCount,
                'image_url': content.imageUrl,
              },
              onEdit: () => _editContent(content.id),
              onDelete: () => _deleteContent(content.id, content.title),
            );
          },
        ),
      ),
    );
  }

  /// Membangun widget ketika konten kosong
  Widget _buildEmptyContentList() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_spacing + 4),
        margin: const EdgeInsets.all(_spacing + 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(_smallSpacing),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: _smallSpacing),
            const Text(
              'Tidak ada konten ditemukan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _tinySpacing),
            Text(
              _searchText.isNotEmpty || _selectedStatusFilter != _statuses.first
                  ? 'Coba ubah filter pencarian'
                  : 'Belum ada konten yang dibuat',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun floating action button
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _addContent,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
        ),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Tambah Artikel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}