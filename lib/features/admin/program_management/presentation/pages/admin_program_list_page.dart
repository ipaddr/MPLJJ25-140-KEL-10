import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart'; // Adjust if needed
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_program_card_widget.dart';

class AdminProgramListPage extends StatefulWidget {
  const AdminProgramListPage({super.key});

  @override
  State<AdminProgramListPage> createState() => _AdminProgramListPageState();
}

class _AdminProgramListPageState extends State<AdminProgramListPage> {
  // Placeholder data - replace with actual data fetching logic
  final List<Map<String, dynamic>> _allPrograms = [
    {
      'id': 'prog_001',
      'nama_program': 'Beasiswa Pendidikan Anak',
      'kategori': 'Pendidikan',
      'status': 'Aktif',
      'jumlah_pengajuan': 150,
    },
    {
      'id': 'prog_002',
      'nama_program': 'Bantuan Kesehatan Lansia',
      'kategori': 'Kesehatan',
      'status': 'Aktif',
      'jumlah_pengajuan': 80,
    },
    {
      'id': 'prog_003',
      'nama_program': 'Pelatihan Keterampilan Digital',
      'kategori': 'Pemberdayaan',
      'status': 'Selesai',
      'jumlah_pengajuan': 200,
    },
    {
      'id': 'prog_004',
      'nama_program': 'Bantuan Pangan Keluarga Pra-Sejahtera',
      'kategori': 'Sosial',
      'status': 'Ditutup',
      'jumlah_pengajuan': 300,
    },
    // Add more placeholder programs
  ];

  List<Map<String, dynamic>> _filteredPrograms = [];
  String _searchText = '';
  String? _selectedCategoryFilter;
  String? _selectedStatusFilter;

  // Placeholder filter options
  final List<String> _categories = [
    'Semua Kategori',
    'Pendidikan',
    'Kesehatan',
    'Pemberdayaan',
    'Sosial',
  ];
  final List<String> _statuses = [
    'Semua Status',
    'Aktif',
    'Selesai',
    'Ditutup',
  ];

  @override
  void initState() {
    super.initState();
    _filteredPrograms = _allPrograms;
    _selectedCategoryFilter = _categories.first;
    _selectedStatusFilter = _statuses.first;
  }

  void _filterPrograms() {
    List<Map<String, dynamic>> programs =
        _allPrograms.where((program) {
          final nameLower = program['nama_program'].toLowerCase();
          final searchTextLower = _searchText.toLowerCase();

          // Search filter
          final searchMatch = nameLower.contains(searchTextLower);

          // Category filter
          final categoryMatch =
              _selectedCategoryFilter == _categories.first ||
              program['kategori'] == _selectedCategoryFilter;

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
    // TODO: Navigate to Program Detail Page, passing the program ID
    context.go(
      '${RouteNames.adminProgramDetail}/$programId',
    ); // Example with go_router parameter
  }

  void _editProgram(String programId) {
    // TODO: Navigate to Edit Program Page (same as detail page for editing)
    context.go(
      '${RouteNames.adminProgramDetail}/$programId',
    ); // Example with go_router parameter
  }

  void _deleteProgram(String programId) {
    // TODO: Implement delete program logic (show confirmation dialog, call API)
    print('Attempting to delete program with ID: $programId');
    // Example: Remove from local list (for demonstration)
    setState(() {
      _allPrograms.removeWhere((program) => program['id'] == programId);
      _filterPrograms(); // Re-filter after deletion
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Program $programId deleted (placeholder)')),
    );
  }

  void _addProgram() {
    // TODO: Navigate to Add Program Page
    context.go(RouteNames.adminAddProgram);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Program Bantuan'),
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
                      hintText: 'Cari Nama Program',
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
                      _filterPrograms();
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Filters (Category and Status)
                  Row(
                    children: [
                      // Category Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Kategori',
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
                      const SizedBox(width: 16.0),
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Status Program',
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
                            _filterPrograms();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Program List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredPrograms.length,
                itemBuilder: (context, index) {
                  final program = _filteredPrograms[index];
                  return AdminProgramCardWidget(
                    program: program,
                    onViewDetail: () => _viewProgramDetail(program['id']),
                    onEdit: () => _editProgram(program['id']),
                    onDelete: () => _deleteProgram(program['id']),
                  );
                },
              ),
            ),
            // "Tambah Program Baru" Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _addProgram,
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
                child: const Center(child: Text('Tambah Program Baru')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
