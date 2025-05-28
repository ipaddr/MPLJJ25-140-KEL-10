import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/recommendation_card_widget.dart';

/// Halaman yang menampilkan rekomendasi program untuk pengguna
class MyRecommendationsPage extends StatefulWidget {
  const MyRecommendationsPage({super.key});

  @override
  State<MyRecommendationsPage> createState() => _MyRecommendationsPageState();
}

class _MyRecommendationsPageState extends State<MyRecommendationsPage> {
  // State variables
  User? _currentUser;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _recommendedPrograms = [];
  bool _isLoading = true;

  // Collection paths
  static const String _usersCollection = 'users';
  static const String _programsCollection = 'programs';

  // UI Constants
  static const double _spacing = 16.0;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  /// Memuat rekomendasi program untuk pengguna
  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser == null) {
        _setLoadingComplete();
        return;
      }

      await _loadUserData();
      await _generateRecommendations();
      _setLoadingComplete();
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
      _setLoadingComplete();
    }
  }

  /// Memuat data pengguna dari Firestore
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection(_usersCollection)
            .doc(_currentUser!.uid)
            .get();

    if (userDoc.exists) {
      _userData = userDoc.data();
    }
  }

  /// Tandai proses loading selesai
  void _setLoadingComplete() {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  /// Menghasilkan rekomendasi program berdasarkan data pengguna
  Future<void> _generateRecommendations() async {
    try {
      final programsQuery =
          await FirebaseFirestore.instance
              .collection(_programsCollection)
              .where('status', isEqualTo: 'active')
              .limit(10)
              .get();

      if (programsQuery.docs.isEmpty) {
        if (mounted) {
          setState(() {
            _recommendedPrograms = [];
          });
        }
        return;
      }

      // Ubah dokumen menjadi Map
      List<Map<String, dynamic>> programs =
          programsQuery.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

      // Rekomendasi dasar berdasarkan popularitas
      _recommendedPrograms = _getBasicRecommendations(programs);

      // Jika ada data pengguna, tambahkan personalisasi
      if (_userData != null) {
        _addPersonalization();
      }
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
      await _generateFallbackRecommendations();
    }
  }

  /// Membuat rekomendasi dasar berdasarkan popularitas
  List<Map<String, dynamic>> _getBasicRecommendations(
    List<Map<String, dynamic>> programs,
  ) {
    final recommendations =
        programs.map((program) {
          program['reason'] =
              'Program populer dengan ${program['totalApplications'] ?? 0} aplikasi';
          program['recommendationScore'] =
              (program['totalApplications'] ?? 0).toDouble();
          return program;
        }).toList();

    // Urutkan berdasarkan aplikasi terbanyak
    recommendations.sort((a, b) {
      final aApps = a['totalApplications'] as int? ?? 0;
      final bApps = b['totalApplications'] as int? ?? 0;
      return bApps.compareTo(aApps);
    });

    return recommendations;
  }

  /// Menambahkan personalisasi berdasarkan data pengguna
  void _addPersonalization() {
    for (var program in _recommendedPrograms) {
      final targetAudience =
          program['targetAudience']?.toString().toLowerCase() ?? '';
      final userJob = _getUserJob();

      if (_isRelevantToUser(targetAudience, userJob)) {
        program['recommendationScore'] =
            (program['recommendationScore'] ?? 0) + 10;
        program['reason'] =
            'Sesuai dengan profil Anda dan populer di kalangan pengguna';
      }
    }

    // Urutkan berdasarkan skor rekomendasi
    _recommendedPrograms.sort(
      (a, b) => (b['recommendationScore'] as double).compareTo(
        a['recommendationScore'] as double,
      ),
    );
  }

  /// Mengambil pekerjaan pengguna dari data
  String _getUserJob() {
    return _userData?['jobType']?.toString().toLowerCase() ??
        _userData?['occupation']?.toString().toLowerCase() ??
        '';
  }

  /// Memeriksa apakah targetAudience relevan untuk pengguna
  bool _isRelevantToUser(String targetAudience, String userJob) {
    return targetAudience.contains(userJob) ||
        targetAudience.contains('semua') ||
        targetAudience.contains('umum');
  }

  /// Menghasilkan rekomendasi alternatif jika terjadi error
  Future<void> _generateFallbackRecommendations() async {
    try {
      final fallbackQuery =
          await FirebaseFirestore.instance
              .collection(_programsCollection)
              .where('status', isEqualTo: 'active')
              .limit(5)
              .get();

      if (!mounted) return;

      setState(() {
        _recommendedPrograms =
            fallbackQuery.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              data['reason'] = 'Program yang tersedia untuk Anda';
              data['recommendationScore'] = 50.0;
              return data;
            }).toList();
      });
    } catch (e) {
      debugPrint('Fallback query failed: $e');

      if (!mounted) return;

      setState(() {
        _recommendedPrograms = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  /// Membangun AppBar dengan judul dan tombol refresh
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(RouteNames.userDashboard),
      ),
      title: const Text(
        "Rekomendasi Program Saya",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      backgroundColor: Colors.blue.shade700,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadRecommendations,
        ),
      ],
    );
  }

  /// Membangun body halaman sesuai state
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _buildContent(),
    );
  }

  /// Membangun konten berdasarkan state
  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_currentUser == null) {
      return _buildLoginRequired();
    }

    if (_recommendedPrograms.isEmpty) {
      return _buildEmptyState();
    }

    return _buildRecommendationsList();
  }

  /// Membangun state loading
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: _spacing),
          Text('Memuat rekomendasi...'),
        ],
      ),
    );
  }

  /// Membangun state login diperlukan
  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: _spacing),
          const Text('Silakan login terlebih dahulu'),
          const SizedBox(height: _spacing),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.login),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  /// Membangun state daftar kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.recommend, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: _spacing),
          Text(
            'Belum ada rekomendasi program',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba lagi nanti atau lengkapi profil Anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: _spacing),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.userProfile),
            child: const Text('Lengkapi Profil'),
          ),
        ],
      ),
    );
  }

  /// Membangun daftar rekomendasi
  Widget _buildRecommendationsList() {
    return RefreshIndicator(
      onRefresh: _loadRecommendations,
      child: ListView.builder(
        padding: const EdgeInsets.all(_spacing),
        itemCount: _recommendedPrograms.length,
        itemBuilder: (context, index) {
          final program = _recommendedPrograms[index];
          return RecommendationCardWidget(
            programId: program['id'],
            programData: program,
            onTap: () => context.push('/user/programs/detail/${program['id']}'),
          );
        },
      ),
    );
  }
}
