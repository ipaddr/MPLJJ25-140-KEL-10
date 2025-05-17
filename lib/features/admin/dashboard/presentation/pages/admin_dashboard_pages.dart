import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import 'package:socio_care/features/admin/dashboard/presentation/widgets/admin_stats_card_widget.dart'; // Assuming you'll create this widget

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Hamburger icon
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Open the navigation drawer
          },
        ),
      ),
      extendBodyBehindAppBar: true, // Extend body behind the app bar

      drawer:
          const AdminNavigationDrawer(), // Your Admin Navigation Drawer widget

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade300,
            ], // Gradient colors
          ),
        ),
        child: SafeArea(
          // Use SafeArea to avoid status bar overlap
          child: SingleChildScrollView(
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
                    height: 150, // Height for the horizontal scrollable cards
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        AdminStatisticCardWidget(
                          title: 'Total Pengguna',
                          value: '1,234',
                          icon: Icons.people_alt,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 16),
                        AdminStatisticCardWidget(
                          title: 'Program Aktif',
                          value: '45',
                          icon: Icons.playlist_add_check,
                          color: Colors.green,
                        ),
                        SizedBox(width: 16),
                        AdminStatisticCardWidget(
                          title: 'Pengajuan Masuk',
                          value: '789',
                          icon: Icons.assignment,
                          color: Colors.purple,
                        ),
                        SizedBox(width: 16),
                        AdminStatisticCardWidget(
                          title: 'Pengajuan Disetujui',
                          value: '512',
                          icon: Icons.check_circle,
                          color: Colors.teal,
                        ),
                        SizedBox(width: 16),
                        AdminStatisticCardWidget(
                          title: 'Pengajuan Ditolak',
                          value: '120',
                          icon: Icons.cancel,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Placeholder for other admin sections or charts
                  const Text(
                    'Ringkasan Aktivitas Terkini',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Add widgets for recent activities, pending approvals, etc.
                  Container(
                    height: 200,
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Text('Placeholder for recent activities list'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Statistik Lainnya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 250,
                    color: Colors.white.withOpacity(0.8),
                    child: Center(
                      child: Text('Placeholder for charts or graphs'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Create this file: lib/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart
