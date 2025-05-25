import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/programs/presentation/widgets/program_list_item_widget.dart';

class ProgramExplorerPage extends StatefulWidget {
  const ProgramExplorerPage({super.key});

  @override
  State<ProgramExplorerPage> createState() => _ProgramExplorerPageState();
}

class _ProgramExplorerPageState extends State<ProgramExplorerPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedTargetAudience = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Bantuan Sosial',
    'Pendidikan',
    'Kesehatan',
    'Ekonomi',
    'Perumahan',
    'Pertanian',
    'UMKM',
    'Pelatihan',
    'Lainnya',
  ];

  final List<String> _targetAudiences = [
    'Semua',
    'Keluarga Miskin',
    'Lansia',
    'Anak-anak',
    'Ibu Hamil',
    'Penyandang Disabilitas',
    'Pengusaha Mikro',
    'Petani',
    'Nelayan',
    'Pekerja Informal',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getProgramsStream() {
    try {
      return FirebaseFirestore.instance
          .collection('programs')
          .where('status', isEqualTo: 'active')
          .snapshots();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating programs stream: $e');
      }
      return const Stream.empty();
    }
  }

  List<DocumentSnapshot> _filterPrograms(List<DocumentSnapshot> programs) {
    List<DocumentSnapshot> filtered = programs;

    // Apply category filter
    if (_selectedCategory != 'Semua') {
      filtered =
          filtered.where((program) {
            final data = program.data() as Map<String, dynamic>?;
            return data?['category']?.toString() == _selectedCategory;
          }).toList();
    }

    // Apply target audience filter
    if (_selectedTargetAudience != 'Semua') {
      filtered =
          filtered.where((program) {
            final data = program.data() as Map<String, dynamic>?;
            final targetAudience =
                data?['targetAudience']?.toString().toLowerCase() ?? '';
            return targetAudience.contains(
              _selectedTargetAudience.toLowerCase(),
            );
          }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((program) {
            final data = program.data() as Map<String, dynamic>?;
            if (data == null) return false;

            final programName =
                data['programName']?.toString().toLowerCase() ?? '';
            final description =
                data['description']?.toString().toLowerCase() ?? '';
            final category = data['category']?.toString().toLowerCase() ?? '';
            final organizer = data['organizer']?.toString().toLowerCase() ?? '';
            final searchLower = _searchQuery.toLowerCase();

            return programName.contains(searchLower) ||
                description.contains(searchLower) ||
                category.contains(searchLower) ||
                organizer.contains(searchLower);
          }).toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;

      final aDate = aData?['createdAt'] as Timestamp?;
      final bDate = bData?['createdAt'] as Timestamp?;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bData == null) return -1;

      return bDate!.compareTo(aDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Logic back ke dashboard seperti my_recommendations_page
            context.go(RouteNames.userDashboard);
          },
        ),
        title: const Text(
          'Program Bantuan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari program bantuan...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Category and Target Audience Filters
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Kategori',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedTargetAudience,
                          decoration: InputDecoration(
                            labelText: 'Target',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items:
                              _targetAudiences.map((audience) {
                                return DropdownMenuItem(
                                  value: audience,
                                  child: Text(
                                    audience,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTargetAudience = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Programs List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getProgramsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    if (kDebugMode) {
                      debugPrint('StreamBuilder error: ${snapshot.error}');
                    }
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Terjadi kesalahan saat memuat program',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            if (kDebugMode)
                              Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {}); // Trigger rebuild
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat program bantuan...'),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storage,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Database tidak mengembalikan data',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allPrograms = snapshot.data!.docs;
                  final filteredPrograms = _filterPrograms(allPrograms);

                  if (filteredPrograms.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty ||
                                      _selectedCategory != 'Semua' ||
                                      _selectedTargetAudience != 'Semua'
                                  ? Icons.search_off
                                  : Icons.inbox,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedCategory != 'Semua' ||
                                      _selectedTargetAudience != 'Semua'
                                  ? 'Tidak ada program yang sesuai filter'
                                  : 'Belum ada program yang tersedia',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedCategory != 'Semua' ||
                                      _selectedTargetAudience != 'Semua'
                                  ? 'Coba ubah filter atau kata kunci pencarian'
                                  : 'Program akan muncul setelah admin menambahkannya',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (_searchQuery.isNotEmpty ||
                                _selectedCategory != 'Semua' ||
                                _selectedTargetAudience != 'Semua') ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                    _selectedCategory = 'Semua';
                                    _selectedTargetAudience = 'Semua';
                                    _searchController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reset Filter'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {}); // Trigger rebuild
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: filteredPrograms.length,
                      itemBuilder: (context, index) {
                        final program = filteredPrograms[index];
                        final data = program.data() as Map<String, dynamic>?;

                        if (data == null) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Data program tidak valid'),
                          );
                        }

                        return ProgramListItemWidget(
                          programId: program.id,
                          programData: data,
                          onTap: () {
                            context.push('/user/programs/detail/${program.id}');
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
