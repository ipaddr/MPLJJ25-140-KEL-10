import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminNavigationDrawer extends StatefulWidget {
  const AdminNavigationDrawer({super.key});

  @override
  State<AdminNavigationDrawer> createState() => _AdminNavigationDrawerState();
}

class _AdminNavigationDrawerState extends State<AdminNavigationDrawer> {
  String? _currentRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get current route to highlight active menu
    _currentRoute = GoRouterState.of(context).uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Compact Drawer Header
              _buildDrawerHeader(),

              // Navigation Items - Takes remaining space
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      title: 'Dashboard',
                      route: RouteNames.adminDashboard,
                      description: 'Statistik & Overview',
                    ),
                    _buildNavItem(
                      icon: Icons.people_rounded,
                      title: 'Manajemen Pengguna',
                      route: RouteNames.adminUserList,
                      description: 'Kelola data pengguna',
                    ),
                    _buildNavItem(
                      icon: Icons.campaign_rounded,
                      title: 'Manajemen Program',
                      route: RouteNames.adminProgramList,
                      description: 'Kelola program bantuan',
                    ),
                    _buildNavItem(
                      icon: Icons.assignment_rounded,
                      title: 'Manajemen Pengajuan',
                      route: RouteNames.adminSubmissionManagement,
                      description: 'Review pengajuan',
                    ),
                    _buildNavItem(
                      icon: Icons.school_rounded,
                      title: 'Konten Edukasi',
                      route: RouteNames.adminEducationContent,
                      description: 'Kelola konten edukasi',
                    ),

                    // Compact Divider
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.grey.shade300,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    _buildNavItem(
                      icon: Icons.account_circle_rounded,
                      title: 'Profil Admin',
                      route: RouteNames.adminProfile,
                      description: 'Pengaturan profil',
                    ),

                    // Add bottom padding to prevent overflow
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Compact Logout Section
              _buildLogoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Header Row
          Row(
            children: [
              // Admin Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panel Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'SocioCare Management',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    required String description,
  }) {
    final isActive = _currentRoute?.contains(route) ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient:
            isActive
                ? LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade200],
                )
                : null,
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            context.go(route);
            Navigator.pop(context);

            // Show snackbar for feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigasi ke $title'),
                duration: const Duration(milliseconds: 1000),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        isActive ? Colors.blue.shade600 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          color:
                              isActive
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isActive
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Active Indicator
                if (isActive)
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact Admin Info
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@sociocare.com',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Compact Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmation(),
              icon: Icon(
                Icons.logout_rounded,
                size: 16,
                color: Colors.red.shade600,
              ),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                side: BorderSide(color: Colors.red.shade600, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Konfirmasi Logout'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari panel admin?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close drawer
                  context.go(RouteNames.adminLogin);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout berhasil'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
