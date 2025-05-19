import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart'; // Adjust if needed
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_content_card_widget.dart';
// For date formatting

class AdminContentListPage extends StatefulWidget {
  const AdminContentListPage({super.key});

  @override
  State<AdminContentListPage> createState() => _AdminContentListPageState();
}

class _AdminContentListPageState extends State<AdminContentListPage> {
  // Placeholder data - replace with actual data fetching logic
  final List<Map<String, dynamic>> _allContent = [
    {
      'id': 'content_001',
      'title': 'Panduan Mengajukan Beasiswa',
      'publish_date': DateTime(2023, 10, 20),
      'status': 'Dipublikasikan',
    },
    {
      'id': 'content_002',
      'title': 'Tips Menjaga Kesehatan di Musim Hujan',
      'publish_date': DateTime(2023, 10, 15),
      'status': 'Dipublikasikan',
    },
    {
      'id': 'content_003',
      'title': 'Draft Artikel Baru: Pentingnya Literasi Digital',
      'publish_date': DateTime(2023, 10, 26),
      'status': 'Draf',
    },
    {
      'id': 'content_004',
      'title': 'Artikel Lama: Info Bantuan Covid-19',
      'publish_date': DateTime(2022, 5, 10),
      'status': 'Diarsip',
    },
    // Add more placeholder content
  ];

  List<Map<String, dynamic>> _filteredContent = [];
  String _searchText = '';
  String? _selectedStatusFilter;

  // Placeholder filter options
  final List<String> _statuses = [
    'Semua Status',
    'Dipublikasikan',
    'Draf',
    'Diarsip',
  ];

  @override
  void initState() {
    super.initState();
    _filteredContent = _allContent;
    _selectedStatusFilter = _statuses.first;
  }

  void _filterContent() {
    List<Map<String, dynamic>> content =
        _allContent.where((item) {
          final titleLower = item['title'].toLowerCase();
          final searchTextLower = _searchText.toLowerCase();

          // Search filter
          final searchMatch = titleLower.contains(searchTextLower);

          // Status filter
          final statusMatch =
              _selectedStatusFilter == _statuses.first ||
              item['status'] == _selectedStatusFilter;

          return searchMatch && statusMatch;
        }).toList();

    setState(() {
      _filteredContent = content;
    });
  }

  void _editContent(String contentId) {
    // TODO: Navigate to Content Editor Page for editing
    context.go(
      '${RouteNames.adminContentEditor}/$contentId',
    ); // Example with go_router parameter
  }

  void _deleteContent(String contentId) {
    // TODO: Implement delete content logic (show confirmation dialog, call API)
    print('Attempting to delete content with ID: $contentId');
    // Example: Remove from local list (for demonstration)
    setState(() {
      _allContent.removeWhere((content) => content['id'] == contentId);
      _filterContent(); // Re-filter after deletion
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Content $contentId deleted (placeholder)')),
    );
  }

  void _addContent() {
    // TODO: Navigate to Add Content Page (which redirects to Editor in 'new' mode)
    context.go(
      RouteNames.adminAddContent,
    ); // Navigate to the add page (which uses the editor)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Konten Edukasi'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),

      drawer:
          const AdminNavigationDrawer(), // Your Admin Navigation Drawer widget

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade200,
            ], // Consistent gradient
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
                    items:
                        _statuses.map((String status) {
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
              child: ListView.builder(
                itemCount: _filteredContent.length,
                itemBuilder: (context, index) {
                  final content = _filteredContent[index];
                  return AdminContentCardWidget(
                    content: content,
                    onEdit: () => _editContent(content['id']),
                    onDelete: () => _deleteContent(content['id']),
                  );
                },
              ),
            ),
            // "Tambah Artikel Baru" Button
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
                child: const Center(child: Text('Tambah Artikel Baru')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
