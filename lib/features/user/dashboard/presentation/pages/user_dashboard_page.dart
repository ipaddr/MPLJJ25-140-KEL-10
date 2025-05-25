import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        await Future.wait([_loadUserData(), _loadDashboardStats()]);
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error initializing dashboard: $e');
      setState(() {
        _error = 'Gagal memuat data dashboard: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final applicationsSnapshot =
          await FirebaseFirestore.instance
              .collection('applications')
              .where('userId', isEqualTo: _currentUser!.uid)
              .get();

      final programsSnapshot =
          await FirebaseFirestore.instance
              .collection('programs')
              .where('status', isEqualTo: 'active')
              .get();

      final articlesSnapshot =
          await FirebaseFirestore.instance
              .collection('education_content')
              .where('status', isEqualTo: 'published')
              .limit(5)
              .get();

      // Process stats
      int totalApplications = applicationsSnapshot.docs.length;
      int pendingApplications = 0;
      int approvedApplications = 0;
      int rejectedApplications = 0;
      int processingApplications = 0;

      for (var doc in applicationsSnapshot.docs) {
        final status = (doc.data()['status'] ?? '').toString().toLowerCase();
        switch (status) {
          case 'baru':
          case 'pending':
            pendingApplications++;
            break;
          case 'disetujui':
          case 'approved':
            approvedApplications++;
            break;
          case 'ditolak':
          case 'rejected':
            rejectedApplications++;
            break;
          case 'diproses':
          case 'reviewed':
          case 'processing':
            processingApplications++;
            break;
        }
      }

      setState(() {
        _dashboardStats = {
          'totalApplications': totalApplications,
          'pendingApplications': pendingApplications + processingApplications,
          'approvedApplications': approvedApplications,
          'rejectedApplications': rejectedApplications,
          'availablePrograms': programsSnapshot.docs.length,
          'educationArticles': articlesSnapshot.docs.length,
        };
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
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
  }

  Future<void> _refreshDashboard() async {
    await _initializeDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
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
          ),
        ],
      ),
      body: Container(
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
                ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat dashboard...'),
                    ],
                  ),
                )
                : _error != null
                ? Center(
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
                        _error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
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
                )
                : RefreshIndicator(
                  onRefresh: _refreshDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeSection(),
                        const SizedBox(height: 24),
                        _buildQuickStatsSection(),
                        const SizedBox(height: 24),
                        _buildFeatureCardsSection(),
                        // ❌ REMOVED: _buildRecentActivitySection() dihapus
                        const SizedBox(height: 24), // Extra spacing
                      ],
                    ),
                  ),
                ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(selectedIndex: 0),
    );
  }

  Widget _buildWelcomeSection() {
    final userName =
        _userData?['fullName'] ??
        _userData?['name'] ??
        _currentUser?.displayName ??
        'Pengguna';
    final userEmail = _userData?['email'] ?? _currentUser?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(16.0),
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
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
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
        const SizedBox(height: 12),
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
            const SizedBox(width: 12),
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

  Widget _buildFeatureCardsSection() {
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
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Jelajahi Program',
          subtitle: 'Temukan program bantuan yang sesuai',
          imagePath: 'assets/images/programs.png',
          onTap: () => context.go(RouteNames.programExplorer),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Chatbot AI',
          subtitle: 'Dapatkan bantuan dengan asisten AI',
          imagePath: 'assets/images/chatbot.png',
          onTap: () => context.go(RouteNames.userChatbot),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          title: 'Rekomendasi Program',
          subtitle: 'Program yang direkomendasikan untuk Anda',
          imagePath: 'assets/images/recommendations.png',
          onTap: () => context.go(RouteNames.programRecommendations),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imagePath,
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
                child: Icon(
                  title.contains('Program')
                      ? Icons.campaign
                      : title.contains('Chatbot')
                      ? Icons.smart_toy
                      : Icons.recommend,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
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
