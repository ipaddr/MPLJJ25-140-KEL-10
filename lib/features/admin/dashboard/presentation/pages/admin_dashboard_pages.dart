import 'package:flutter/material.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/admin_stats_card_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/recent_activities_widget.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/statistics_chart_widget.dart';
import '../../data/admin_dashboard_service.dart';
import '../../data/models/dashboard_statistics.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminDashboardService _dashboardService = AdminDashboardService();

  DashboardStatistics? _statistics;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all statistics concurrently
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
    } catch (e) {
      _errorMessage = 'Gagal memuat data dashboard: ${e.toString()}';
      print('Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshData,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      drawer: const AdminNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildDashboardContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade700,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gambaran Umum Sistem',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  AdminStatisticCardWidget(
                    title: 'Total Pengguna',
                    value: _statistics!.totalUsers.toString(),
                    icon: Icons.people_alt,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  AdminStatisticCardWidget(
                    title: 'Program Aktif',
                    value: _statistics!.activePrograms.toString(),
                    icon: Icons.playlist_add_check,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 16),
                  AdminStatisticCardWidget(
                    title: 'Pengajuan Masuk',
                    value: _statistics!.totalApplications.toString(),
                    icon: Icons.assignment,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 16),
                  AdminStatisticCardWidget(
                    title: 'Pengajuan Disetujui',
                    value: _statistics!.approvedApplications.toString(),
                    icon: Icons.check_circle,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 16),
                  AdminStatisticCardWidget(
                    title: 'Pengajuan Ditolak',
                    value: _statistics!.rejectedApplications.toString(),
                    icon: Icons.cancel,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  AdminStatisticCardWidget(
                    title: 'Pengajuan Pending',
                    value: _statistics!.pendingApplications.toString(),
                    icon: Icons.schedule,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ringkasan Aktivitas Terkini',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: RecentActivitiesWidget(
                activities: _statistics!.recentActivities,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Statistik Detail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: StatisticsChartWidget(
                applicationsByStatus: _statistics!.applicationsByStatus,
                usersByStatus: _statistics!.usersByStatus,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
