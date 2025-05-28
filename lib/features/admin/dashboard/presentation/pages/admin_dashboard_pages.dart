import 'package:flutter/material.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/admin_stats_card_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/recent_activities_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/statistics_chart_widget.dart';
import '../../data/admin_dashboard_service.dart';
import '../../data/models/dashboard_statistics.dart';

/// Halaman dashboard untuk administrator
///
/// Menampilkan statistik sistem, aktivitas terbaru, dan analisis data
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  // Keys & Services
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminDashboardService _dashboardService = AdminDashboardService();

  // State variables
  DashboardStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // UI Constants
  static const double _sectionSpacing = 24.0;
  static const double _itemSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 4.0;
  static const double _contentHeight = 320.0;
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboardData();
  }

  /// Inisialisasi animasi untuk dashboard
  void _initializeAnimations() {
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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Memuat data dashboard dari service
  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _statistics = await _dashboardService.getDashboardStatistics();

      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data dashboard: ${e.toString()}';
        });
        debugPrint('Error loading dashboard data: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menyegarkan data dashboard
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
      body: _buildBody(isLargeScreen, isMediumScreen),
      drawer: const AdminNavigationDrawer(),
    );
  }

  /// Membangun body halaman utama
  Widget _buildBody(bool isLargeScreen, bool isMediumScreen) {
    return Container(
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
                child: _buildMainContent(isLargeScreen, isMediumScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun konten utama berdasarkan state
  Widget _buildMainContent(bool isLargeScreen, bool isMediumScreen) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return _buildDashboardContent(isLargeScreen, isMediumScreen);
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: _itemSpacing),
          Expanded(child: _buildAppBarTitle()),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  /// Membangun tombol menu
  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 24),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  /// Membangun judul app bar
  Widget _buildAppBarTitle() {
    return Column(
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
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }

  /// Membangun tombol refresh
  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
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
    );
  }

  /// Membangun widget loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_smallBorderRadius),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: _itemSpacing),
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
    );
  }

  /// Membangun widget error
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildErrorIcon(),
              const SizedBox(height: _itemSpacing),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _microSpacing),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _sectionSpacing),
              _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun ikon error
  Widget _buildErrorIcon() {
    return Container(
      padding: const EdgeInsets.all(_itemSpacing),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Icon(
        Icons.error_outline_rounded,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  /// Membangun tombol coba lagi
  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: _refreshData,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Coba Lagi'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
      ),
    );
  }

  /// Membangun konten dashboard
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
                const SizedBox(height: _sectionSpacing),
                _buildContentSections(isLargeScreen, isMediumScreen),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun bagian konten utama dashboard
  Widget _buildContentSections(bool isLargeScreen, bool isMediumScreen) {
    if (isMediumScreen) {
      // Layout untuk layar medium dan besar
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildRecentActivitiesSection()),
          const SizedBox(width: 20),
          Expanded(flex: 2, child: _buildAnalyticsSection()),
        ],
      );
    } else {
      // Layout untuk layar kecil (mobile)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecentActivitiesSection(),
          const SizedBox(height: _sectionSpacing),
          _buildAnalyticsSection(),
        ],
      );
    }
  }

  /// Membangun seksi aktivitas terbaru
  Widget _buildRecentActivitiesSection() {
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
        const SizedBox(height: _smallSpacing),
        SizedBox(
          height: _contentHeight,
          child: RecentActivitiesWidget(
            activities: _statistics!.recentActivities,
          ),
        ),
      ],
    );
  }

  /// Membangun seksi analitik data
  Widget _buildAnalyticsSection() {
    return Column(
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
        const SizedBox(height: _smallSpacing),
        SizedBox(
          height: _contentHeight,
          child: StatisticsChartWidget(
            applicationsByStatus: _statistics!.applicationsByStatus,
            usersByStatus: _statistics!.usersByStatus,
          ),
        ),
      ],
    );
  }

  /// Membangun bagian selamat datang
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [Expanded(child: _buildWelcomeMessage()), _buildAdminIcon()],
      ),
    );
  }

  /// Membangun pesan selamat datang
  Widget _buildWelcomeMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreetingByTime(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: _tinySpacing),
        const Text(
          'Administrator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: _tinySpacing + 2),
        Text(
          'Kelola sistem bantuan sosial dengan mudah',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }

  /// Membangun ikon admin
  Widget _buildAdminIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        size: 36,
        color: Colors.white,
      ),
    );
  }

  /// Mendapatkan salam berdasarkan waktu
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return '🌅 Selamat Pagi';
    } else if (hour < 17) {
      return '☀️ Selamat Siang';
    } else {
      return '🌙 Selamat Malam';
    }
  }

  /// Membangun bagian statistik
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
        const SizedBox(height: _itemSpacing),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _buildStatCards(),
          ),
        ),
      ],
    );
  }

  /// Membangun kartu-kartu statistik
  List<Widget> _buildStatCards() {
    return [
      AdminStatisticCardWidget(
        title: 'Total Pengguna',
        value: _statistics!.totalUsers.toString(),
        icon: Icons.people_rounded,
        color: Colors.orange.shade600,
        trend: '+12%',
        trendUp: true,
      ),
      const SizedBox(width: _itemSpacing),
      AdminStatisticCardWidget(
        title: 'Program Aktif',
        value: _statistics!.activePrograms.toString(),
        icon: Icons.campaign_rounded,
        color: Colors.green.shade600,
        trend: '+5%',
        trendUp: true,
      ),
      const SizedBox(width: _itemSpacing),
      AdminStatisticCardWidget(
        title: 'Total Pengajuan',
        value: _statistics!.totalApplications.toString(),
        icon: Icons.assignment_rounded,
        color: Colors.purple.shade600,
        trend: '+18%',
        trendUp: true,
      ),
      const SizedBox(width: _itemSpacing),
      AdminStatisticCardWidget(
        title: 'Disetujui',
        value: _statistics!.approvedApplications.toString(),
        icon: Icons.check_circle_rounded,
        color: Colors.teal.shade600,
        trend: '+8%',
        trendUp: true,
      ),
      const SizedBox(width: _itemSpacing),
      AdminStatisticCardWidget(
        title: 'Ditolak',
        value: _statistics!.rejectedApplications.toString(),
        icon: Icons.cancel_rounded,
        color: Colors.red.shade600,
        trend: '-3%',
        trendUp: false,
      ),
      const SizedBox(width: _itemSpacing),
      AdminStatisticCardWidget(
        title: 'Pending',
        value: _statistics!.pendingApplications.toString(),
        icon: Icons.schedule_rounded,
        color: Colors.amber.shade600,
        trend: '+15%',
        trendUp: true,
      ),
    ];
  }
}
