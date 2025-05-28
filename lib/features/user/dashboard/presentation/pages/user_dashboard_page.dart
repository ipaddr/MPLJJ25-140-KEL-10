import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

/// Halaman dashboard untuk pengguna aplikasi SocioCare
/// Menampilkan ringkasan informasi dan akses ke fitur utama
class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  // User data
  User? _currentUser;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardStats;

  // UI state
  bool _isLoading = true;
  String? _error;

  // UI constants
  static const _cardRadius = 16.0;
  static const _cardPadding = EdgeInsets.all(20.0);
  static const _sectionSpacing = 24.0;
  static const _itemSpacing = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  /// Inisialisasi data dashboard
  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        // Load user data dan statistik secara parallel
        await Future.wait([_loadUserData(), _loadDashboardStats()]);
      } else {
        throw Exception('User tidak terautentikasi');
      }
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
      setState(() {
        _error =
            'Gagal memuat data dashboard: ${e.toString().replaceAll("Exception: ", "")}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Memuat data pengguna dari Firestore
  Future<void> _loadUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _userData = userDoc.data();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  /// Memuat statistik dashboard dari Firestore
  Future<void> _loadDashboardStats() async {
    try {
      // Fetch data secara parallel
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection('applications')
            .where('userId', isEqualTo: _currentUser!.uid)
            .get(),
        FirebaseFirestore.instance
            .collection('programs')
            .where('status', isEqualTo: 'active')
            .get(),
        FirebaseFirestore.instance
            .collection('education_content')
            .where('status', isEqualTo: 'published')
            .limit(5)
            .get(),
      ]);

      final applicationsSnapshot = results[0];
      final programsSnapshot = results[1];
      final articlesSnapshot = results[2];

      // Process stats menggunakan helper maps untuk status
      final applicationStatusCounts = _countApplicationStatuses(
        applicationsSnapshot.docs,
      );

      if (mounted) {
        setState(() {
          _dashboardStats = {
            'totalApplications': applicationsSnapshot.docs.length,
            'pendingApplications': applicationStatusCounts['pending'] ?? 0,
            'approvedApplications': applicationStatusCounts['approved'] ?? 0,
            'rejectedApplications': applicationStatusCounts['rejected'] ?? 0,
            'availablePrograms': programsSnapshot.docs.length,
            'educationArticles': articlesSnapshot.docs.length,
          };
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');

      // Provide fallback values to prevent UI crashes
      if (mounted) {
        setState(() {
          _dashboardStats = {
            'totalApplications': 0,
            'pendingApplications': 0,
            'approvedApplications': 0,
            'rejectedApplications': 0,
            'availablePrograms': 0,
            'educationArticles': 0,
          };
        });
      }
      rethrow;
    }
  }

  /// Menghitung jumlah aplikasi berdasarkan status
  Map<String, int> _countApplicationStatuses(
    List<QueryDocumentSnapshot> applications,
  ) {
    // Map untuk pengelompokan status
    final Map<String, List<String>> statusGroups = {
      'pending': ['baru', 'pending', 'diproses', 'reviewed', 'processing'],
      'approved': ['disetujui', 'approved'],
      'rejected': ['ditolak', 'rejected'],
    };

    // Map untuk menyimpan hasil hitungan
    final Map<String, int> counts = {
      'pending': 0,
      'approved': 0,
      'rejected': 0,
    };

    // Klasifikasi setiap dokumen aplikasi
    for (var doc in applications) {
      final status =
          (doc.data() as Map<String, dynamic>)['status']
              ?.toString()
              .toLowerCase() ??
          '';

      for (var group in statusGroups.entries) {
        if (group.value.contains(status)) {
          counts[group.key] = (counts[group.key] ?? 0) + 1;
          break;
        }
      }
    }

    return counts;
  }

  /// Refresh data dashboard
  Future<void> _refreshDashboard() async {
    await _initializeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: const UserBottomNavigationBar(selectedIndex: 0),
    );
  }

  /// Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Dashboard',
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
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshDashboard,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  /// Membangun body utama sesuai dengan state
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
      ),
      child:
          _isLoading
              ? _buildLoadingView()
              : _error != null
              ? _buildErrorView()
              : _buildDashboardContent(),
    );
  }

  /// Tampilan loading
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat dashboard...'),
        ],
      ),
    );
  }

  /// Tampilan error
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Konten utama dashboard
  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: _sectionSpacing),
            _buildQuickStatsSection(),
            const SizedBox(height: _sectionSpacing),
            _buildFeatureCardsSection(),
            const SizedBox(height: _sectionSpacing),
          ],
        ),
      ),
    );
  }

  /// Bagian welcome dengan info pengguna
  Widget _buildWelcomeSection() {
    final userName =
        _userData?['fullName'] ??
        _userData?['name'] ??
        _currentUser?.displayName ??
        'Pengguna';

    final userEmail = _userData?['email'] ?? _currentUser?.email ?? '';

    return Container(
      padding: _cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat datang kembali,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian statistik cepat pengguna
  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Aktivitas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: _itemSpacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Pengajuan',
                '${_dashboardStats?['totalApplications'] ?? 0}',
                Icons.assignment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: _itemSpacing),
            Expanded(
              child: _buildStatCard(
                'Menunggu',
                '${_dashboardStats?['pendingApplications'] ?? 0}',
                Icons.hourglass_empty,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: _itemSpacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Disetujui',
                '${_dashboardStats?['approvedApplications'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: _itemSpacing),
            Expanded(
              child: _buildStatCard(
                'Program Aktif',
                '${_dashboardStats?['availablePrograms'] ?? 0}',
                Icons.campaign,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kartu statistik individual
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Bagian kartu fitur utama
  Widget _buildFeatureCardsSection() {
    // Data untuk feature cards
    final featureCards = [
      {
        'title': 'Jelajahi Program',
        'subtitle': 'Temukan program bantuan yang sesuai',
        'icon': Icons.campaign,
        'route': RouteNames.programExplorer,
      },
      {
        'title': 'Chatbot AI',
        'subtitle': 'Dapatkan bantuan dengan asisten AI',
        'icon': Icons.smart_toy,
        'route': RouteNames.userChatbot,
      },
      {
        'title': 'Rekomendasi Program',
        'subtitle': 'Program yang direkomendasikan untuk Anda',
        'icon': Icons.recommend,
        'route': RouteNames.programRecommendations,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Layanan Utama',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: _itemSpacing),
        ...featureCards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: _itemSpacing),
                child: _buildFeatureCard(
                  title: card['title'] as String,
                  subtitle: card['subtitle'] as String,
                  icon: card['icon'] as IconData,
                  onTap: () => context.go(card['route'] as String),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  /// Kartu fitur individual
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
