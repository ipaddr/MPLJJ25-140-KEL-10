import 'package:flutter/material.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/admin_stats_card_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/recent_activities_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/statistics_chart_widget.dart';
import '../../data/admin_dashboard_service.dart';
import '../../data/models/dashboard_statistics.dart';
import 'dart:developer' as developer;

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminDashboardService _dashboardService = AdminDashboardService();

  DashboardStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _loadDashboardData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _dashboardService.getTotalUsersCount(),
        _dashboardService.getActiveProgramsCount(),
        _dashboardService.getTotalApplicationsCount(),
        _dashboardService.getApprovedApplicationsCount(),
        _dashboardService.getRejectedApplicationsCount(),
        _dashboardService.getPendingApplicationsCount(),
        _dashboardService.getUsersByVerificationStatus(),
        _dashboardService.getApplicationsByStatus(),
        _dashboardService.getRecentActivities(),
      ]);

      final recentActivitiesData = results[8] as List<Map<String, dynamic>>;
      final recentActivities =
          recentActivitiesData
              .map((data) => RecentActivity.fromMap(data))
              .toList();

      _statistics = DashboardStatistics(
        totalUsers: results[0] as int,
        activePrograms: results[1] as int,
        totalApplications: results[2] as int,
        approvedApplications: results[3] as int,
        rejectedApplications: results[4] as int,
        pendingApplications: results[5] as int,
        usersByStatus: results[6] as Map<String, int>,
        applicationsByStatus: results[7] as Map<String, int>,
        recentActivities: recentActivities,
      );

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard: ${e.toString()}';
      developer.log('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    _fadeController.reset();
    _slideController.reset();
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1200;
    final isMediumScreen = screenSize.width > 800;

    return Scaffold(
      key: _scaffoldKey,
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
              _buildCustomAppBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Colors.white,
                  backgroundColor: Colors.blue.shade700,
                  child:
                      _isLoading
                          ? _buildLoadingWidget()
                          : _errorMessage != null
                          ? _buildErrorWidget()
                          : _buildDashboardContent(
                            isLargeScreen,
                            isMediumScreen,
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const AdminNavigationDrawer(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dashboard Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SocioCare Management System',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
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
              onPressed: _isLoading ? null : _refreshData,
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data dashboard...',
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
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
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
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshData,
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

  Widget _buildDashboardContent(bool isLargeScreen, bool isMediumScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 20),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildContentSections(isLargeScreen, isMediumScreen),
                // ✅ REDUCED: Hanya 20px padding bottom yang diperlukan
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSections(bool isLargeScreen, bool isMediumScreen) {
    // ✅ OPTIMIZED: Ukuran content yang proporsional
    const double contentHeight = 320.0;

    if (isMediumScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: contentHeight,
                  child: RecentActivitiesWidget(
                    activities: _statistics!.recentActivities,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Analisis Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: contentHeight,
                  child: StatisticsChartWidget(
                    applicationsByStatus: _statistics!.applicationsByStatus,
                    usersByStatus: _statistics!.usersByStatus,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktivitas Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: contentHeight,
            child: RecentActivitiesWidget(
              activities: _statistics!.recentActivities,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analisis Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: contentHeight,
            child: StatisticsChartWidget(
              applicationsByStatus: _statistics!.applicationsByStatus,
              usersByStatus: _statistics!.usersByStatus,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = '🌅 Selamat Pagi';
    } else if (hour < 17) {
      greeting = '☀️ Selamat Siang';
    } else {
      greeting = '🌙 Selamat Malam';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola sistem bantuan sosial dengan mudah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Sistem',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              AdminStatisticCardWidget(
                title: 'Total Pengguna',
                value: _statistics!.totalUsers.toString(),
                icon: Icons.people_rounded,
                color: Colors.orange.shade600,
                trend: '+12%',
                trendUp: true,
              ),
              const SizedBox(width: 16),
              AdminStatisticCardWidget(
                title: 'Program Aktif',
                value: _statistics!.activePrograms.toString(),
                icon: Icons.campaign_rounded,
                color: Colors.green.shade600,
                trend: '+5%',
                trendUp: true,
              ),
              const SizedBox(width: 16),
              AdminStatisticCardWidget(
                title: 'Total Pengajuan',
                value: _statistics!.totalApplications.toString(),
                icon: Icons.assignment_rounded,
                color: Colors.purple.shade600,
                trend: '+18%',
                trendUp: true,
              ),
              const SizedBox(width: 16),
              AdminStatisticCardWidget(
                title: 'Disetujui',
                value: _statistics!.approvedApplications.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.teal.shade600,
                trend: '+8%',
                trendUp: true,
              ),
              const SizedBox(width: 16),
              AdminStatisticCardWidget(
                title: 'Ditolak',
                value: _statistics!.rejectedApplications.toString(),
                icon: Icons.cancel_rounded,
                color: Colors.red.shade600,
                trend: '-3%',
                trendUp: false,
              ),
              const SizedBox(width: 16),
              AdminStatisticCardWidget(
                title: 'Pending',
                value: _statistics!.pendingApplications.toString(),
                icon: Icons.schedule_rounded,
                color: Colors.amber.shade600,
                trend: '+15%',
                trendUp: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
