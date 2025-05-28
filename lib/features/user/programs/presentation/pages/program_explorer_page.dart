import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/programs/presentation/widgets/program_list_item_widget.dart';

/// Halaman untuk eksplorasi program bantuan
class ProgramExplorerPage extends StatefulWidget {
  const ProgramExplorerPage({super.key});

  @override
  State<ProgramExplorerPage> createState() => _ProgramExplorerPageState();
}

class _ProgramExplorerPageState extends State<ProgramExplorerPage> {
  // Controllers
  final TextEditingController _searchController = TextEditingController();

  // State variables
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedTargetAudience = 'Semua';

  // Filter options
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

  // UI constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _borderRadius = 12.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Mendapatkan stream data program dari Firestore
  Stream<QuerySnapshot> _getProgramsStream() {
    try {
      return FirebaseFirestore.instance
          .collection('programs')
          .where('status', isEqualTo: 'active')
          .snapshots();
    } catch (e) {
      debugPrint('Error creating programs stream: $e');
      return const Stream.empty();
    }
  }

  /// Memfilter program berdasarkan kategori, target, dan pencarian
  List<DocumentSnapshot> _filterPrograms(List<DocumentSnapshot> programs) {
    List<DocumentSnapshot> filtered = programs;

    // Apply category filter
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where((program) {
        final data = program.data() as Map<String, dynamic>?;
        return data?['category']?.toString() == _selectedCategory;
      }).toList();
    }

    // Apply target audience filter
    if (_selectedTargetAudience != 'Semua') {
      filtered = filtered.where((program) {
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
      filtered = filtered.where((program) {
        final data = program.data() as Map<String, dynamic>?;
        if (data == null) return false;

        final searchLower = _searchQuery.toLowerCase();
        final programName = data['programName']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';
        final category = data['category']?.toString().toLowerCase() ?? '';
        final organizer = data['organizer']?.toString().toLowerCase() ?? '';

        return programName.contains(searchLower) ||
            description.contains(searchLower) ||
            category.contains(searchLower) ||
            organizer.contains(searchLower);
      }).toList();
    }

    // Sort by creation date (newest first)
    _sortProgramsByDate(filtered);

    return filtered;
  }
  
  /// Mengurutkan program berdasarkan tanggal pembuatan
  void _sortProgramsByDate(List<DocumentSnapshot> programs) {
    programs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;

      final aDate = aData?['createdAt'] as Timestamp?;
      final bDate = bData?['createdAt'] as Timestamp?;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
            _buildSearchAndFilters(),
            Expanded(child: _buildProgramsList()),
          ],
        ),
      ),
    );
  }
  
  /// Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(RouteNames.userDashboard),
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
    );
  }
  
  /// Membangun bagian pencarian dan filter
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: _smallSpacing),

          // Category and Target Audience Filters
          Row(
            children: [
              Expanded(child: _buildCategoryDropdown()),
              const SizedBox(width: _smallSpacing),
              Expanded(child: _buildTargetAudienceDropdown()),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Membangun kotak pencarian
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari program bantuan...',
        prefixIcon: Icon(
          Icons.search,
          color: Colors.grey.shade600,
        ),
        suffixIcon: _searchQuery.isNotEmpty
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
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }
  
  /// Membangun dropdown kategori
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
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
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }
  
  /// Membangun dropdown target audiens
  Widget _buildTargetAudienceDropdown() {
    return DropdownButtonFormField<String>(
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
      items: _targetAudiences.map((audience) {
        return DropdownMenuItem(
          value: audience,
          child: Text(
            audience,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedTargetAudience = value;
          });
        }
      },
    );
  }
  
  /// Membangun daftar program
  Widget _buildProgramsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getProgramsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingView();
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildNoDataView();
        }

        final allPrograms = snapshot.data!.docs;
        final filteredPrograms = _filterPrograms(allPrograms);

        if (filteredPrograms.isEmpty) {
          return _buildEmptyFilterView();
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Trigger rebuild
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(_spacing),
            itemCount: filteredPrograms.length,
            itemBuilder: (context, index) {
              final program = filteredPrograms[index];
              final data = program.data() as Map<String, dynamic>?;

              if (data == null) {
                return _buildInvalidDataView();
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
    );
  }
  
  /// Membangun tampilan error
  Widget _buildErrorView(String errorMessage) {
    final truncatedError = errorMessage.length > 100
        ? '${errorMessage.substring(0, 100)}...'
        : errorMessage;
        
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
            const SizedBox(height: _spacing),
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
                'Error: $truncatedError',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: _spacing),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Membangun tampilan loading
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: _spacing),
          Text('Memuat program bantuan...'),
        ],
      ),
    );
  }
  
  /// Membangun tampilan tidak ada data
  Widget _buildNoDataView() {
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
            const SizedBox(height: _spacing),
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
  
  /// Membangun tampilan filter kosong
  Widget _buildEmptyFilterView() {
    final isFiltered = _searchQuery.isNotEmpty || 
                       _selectedCategory != 'Semua' || 
                       _selectedTargetAudience != 'Semua';
                       
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off : Icons.inbox,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: _spacing),
            Text(
              isFiltered
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
              isFiltered
                  ? 'Coba ubah filter atau kata kunci pencarian'
                  : 'Program akan muncul setelah admin menambahkannya',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: _spacing),
              ElevatedButton(
                onPressed: _resetFilters,
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
  
  /// Reset semua filter
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'Semua';
      _selectedTargetAudience = 'Semua';
      _searchController.clear();
    });
  }
  
  /// Membangun tampilan data tidak valid
  Widget _buildInvalidDataView() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Data program tidak valid'),
    );
  }
}