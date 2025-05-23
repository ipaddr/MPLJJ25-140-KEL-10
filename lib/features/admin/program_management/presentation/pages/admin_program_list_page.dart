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

class _AdminProgramListPageState extends State<AdminProgramListPage> {
  final AdminProgramService _programService = AdminProgramService();
  
  List<Map<String, dynamic>> _allPrograms = [];
  List<Map<String, dynamic>> _filteredPrograms = [];
  String _searchText = '';
  String? _selectedCategoryFilter;
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

  // Filter options
  final List<String> _categories = [
    'Semua Kategori',
    'Kesehatan',
    'Pendidikan',
    'Modal Usaha',
    'Makanan Pokok',
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
    _loadPrograms();
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
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data program: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

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

    setState(() {
      _filteredPrograms = programs;
    });
  }

  void _viewProgramDetail(String programId) {
    context.go('${RouteNames.adminProgramDetail}/$programId');
  }

  void _editProgram(String programId) {
    context.go('${RouteNames.adminProgramDetail}/$programId');
  }

  Future<void> _deleteProgram(String programId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus program ini?'),
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
        final success = await _programService.deleteProgram(programId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program berhasil dihapus')),
          );
          await _loadPrograms(); // Reload programs
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus program')),
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

  void _addProgram() {
    context.go(RouteNames.adminAddProgram);
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
      appBar: AppBar(
        title: const Text('Manajemen Program Bantuan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPrograms,
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
                  // Filters
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
                          items: _statuses.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status == 'Semua Status' 
                                  ? status 
                                  : _getStatusDisplayName(status)),
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
            // Content
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
                                onPressed: _loadPrograms,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _filteredPrograms.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada program yang ditemukan',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadPrograms,
                              child: ListView.builder(
                                itemCount: _filteredPrograms.length,
                                itemBuilder: (context, index) {
                                  final program = _filteredPrograms[index];
                                  return AdminProgramCardWidget(
                                    program: {
                                      'id': program['id'],
                                      'nama_program': program['programName'],
                                      'kategori': program['category'],
                                      'status': _getStatusDisplayName(program['status']),
                                      'jumlah_pengajuan': program['totalApplications'],
                                    },
                                    onViewDetail: () => _viewProgramDetail(program['id']),
                                    onEdit: () => _editProgram(program['id']),
                                    onDelete: () => _deleteProgram(program['id']),
                                  );
                                },
                              ),
                            ),
            ),
            // Add Program Button
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