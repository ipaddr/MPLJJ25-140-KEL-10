import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_content_card_widget.dart';
import '../../data/admin_content_service.dart';
import '../../data/models/content_model.dart';

class AdminContentListPage extends StatefulWidget {
  const AdminContentListPage({super.key});

  @override
  State<AdminContentListPage> createState() => _AdminContentListPageState();
}

class _AdminContentListPageState extends State<AdminContentListPage>
    with TickerProviderStateMixin {
  final AdminContentService _contentService = AdminContentService();
  final TextEditingController _searchController = TextEditingController();
  
  List<ContentModel> _allContent = [];
  List<ContentModel> _filteredContent = [];
  String _searchText = '';
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _statuses = [
    'Semua Status',
    'Dipublikasikan',
    'Draf',
    'Diarsip',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatusFilter = _statuses.first;
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _loadContent();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await _contentService.getAllContent();
      setState(() {
        _allContent = content;
        _filteredContent = content;
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat konten: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterContent() {
    List<ContentModel> content = _allContent.where((item) {
      final titleLower = item.title.toLowerCase();
      final contentLower = item.content.toLowerCase();
      final searchTextLower = _searchText.toLowerCase();

      // Search filter
      final searchMatch = titleLower.contains(searchTextLower) || 
                         contentLower.contains(searchTextLower);

      // Status filter
      final statusMatch = _selectedStatusFilter == _statuses.first ||
          AdminContentService.getStatusDisplayName(item.status) == _selectedStatusFilter;

      return searchMatch && statusMatch;
    }).toList();

    setState(() {
      _filteredContent = content;
    });
  }

  void _editContent(String contentId) {
    context.go('${RouteNames.adminContentEditor}/$contentId');
  }

  Future<void> _deleteContent(String contentId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin menghapus konten ini?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 12),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
                borderRadius: BorderRadius.circular(8),
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

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _contentService.deleteContent(contentId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Konten berhasil dihapus'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          await _loadContent();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Gagal menghapus konten'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addContent() {
    context.go(RouteNames.adminAddContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Custom App Bar
              _buildCustomAppBar(),
              
              // Search and Filter Section
              _buildSearchAndFilter(),
              
              // Content List
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
      ),
      drawer: const AdminNavigationDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Menu Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Konten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola artikel dan konten edukasi',
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
              onPressed: _isLoading ? null : _loadContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
                _filterContent();
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Status Filter
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
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
                setState(() {
                  _selectedStatusFilter = newValue;
                });
                _filterContent();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
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
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadContent,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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

  Widget _buildContentList() {
    if (_filteredContent.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              const Text(
                'Tidak ada konten ditemukan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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