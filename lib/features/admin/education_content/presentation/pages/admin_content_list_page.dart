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

class _AdminContentListPageState extends State<AdminContentListPage> {
  final AdminContentService _contentService = AdminContentService();
  
  List<ContentModel> _allContent = [];
  List<ContentModel> _filteredContent = [];
  String _searchText = '';
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

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
    _loadContent();
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
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus konten "$title"?\n\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        final success = await _contentService.deleteContent(contentId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konten berhasil dihapus')),
          );
          await _loadContent(); // Reload content
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus konten')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addContent() {
    // Navigate directly to the content editor for new content
    context.go(RouteNames.adminAddContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Konten Edukasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadContent,
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Judul Konten',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                      _filterContent();
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Status Filter
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Status Konten',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
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
                ],
              ),
            ),
            // Content List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 64, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(_errorMessage!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadContent,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _filteredContent.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada konten yang ditemukan',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadContent,
                              child: ListView.builder(
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
            ),
            // Add Content Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Tambah Artikel Baru'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}