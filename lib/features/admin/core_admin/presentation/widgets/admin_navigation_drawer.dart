import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../../auth/services/admin_auth_service.dart';

/// Custom navigation drawer for the admin panel
///
/// Displays navigation items for various admin sections with
/// visual feedback for the active route and smooth animations
class AdminNavigationDrawer extends StatefulWidget {
  const AdminNavigationDrawer({super.key});

  @override
  State<AdminNavigationDrawer> createState() => _AdminNavigationDrawerState();
}

class _AdminNavigationDrawerState extends State<AdminNavigationDrawer> {
  // UI Constants
  static const double _spacing = 16.0;
  static const double _mediumSpacing = 12.0;
  static const double _smallSpacing = 10.0;
  static const double _miniSpacing = 8.0;
  static const double _microSpacing = 6.0;
  static const double _tinySpacing = 4.0;
  static const double _microTinySpacing = 3.0;
  static const double _minusculeSpacing = 1.5;
  static const double _atomicSpacing = 1.0;

  static const double _borderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 10.0;
  static const double _miniBorderRadius = 8.0;
  static const double _tinyBorderRadius = 6.0;

  static const double _iconSize = 24.0;
  static const double _smallIconSize = 18.0;
  static const double _microIconSize = 16.0;
  static const double _miniIconSize = 10.0;
  static const double _dotSize = 6.0;

  static const double _titleFontSize = 18.0;
  static const double _subtitleFontSize = 13.0;
  static const double _bodyFontSize = 12.0;
  static const double _smallFontSize = 10.0;
  static const double _microFontSize = 9.0;

  // Current route to highlight active item
  String? _currentRoute;

  // Navigation items data for easier maintenance
  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.dashboard_rounded,
      'title': 'Dashboard',
      'route': RouteNames.adminDashboard,
      'description': 'Statistik & Overview',
    },
    {
      'icon': Icons.people_rounded,
      'title': 'Manajemen Pengguna',
      'route': RouteNames.adminUserList,
      'description': 'Kelola data pengguna',
    },
    {
      'icon': Icons.campaign_rounded,
      'title': 'Manajemen Program',
      'route': RouteNames.adminProgramList,
      'description': 'Kelola program bantuan',
    },
    {
      'icon': Icons.assignment_rounded,
      'title': 'Manajemen Pengajuan',
      'route': RouteNames.adminSubmissionManagement,
      'description': 'Review pengajuan',
    },
    {
      'icon': Icons.school_rounded,
      'title': 'Konten Edukasi',
      'route': RouteNames.adminEducationContent,
      'description': 'Kelola konten edukasi',
    },
    // Divider position is managed in the build method
    {
      'icon': Icons.account_circle_rounded,
      'title': 'Profil Admin',
      'route': RouteNames.adminProfile,
      'description': 'Pengaturan profil',
    },
  ];

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
          topRight: Radius.circular(_mediumBorderRadius),
          bottomRight: Radius.circular(_mediumBorderRadius),
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
              // Drawer Header
              _buildDrawerHeader(),

              // Navigation Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: _tinySpacing),
                  itemCount: _navItems.length + 1, // +1 for the divider
                  itemBuilder: (context, index) {
                    // Insert divider before the last item
                    if (index == _navItems.length - 1) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDivider(),
                          _buildNavItem(
                            icon: _navItems[index]['icon'],
                            title: _navItems[index]['title'],
                            route: _navItems[index]['route'],
                            description: _navItems[index]['description'],
                          ),
                        ],
                      );
                    }

                    // Regular navigation items
                    if (index < _navItems.length) {
                      return _buildNavItem(
                        icon: _navItems[index]['icon'],
                        title: _navItems[index]['title'],
                        route: _navItems[index]['route'],
                        description: _navItems[index]['description'],
                      );
                    }

                    // Extra bottom space
                    return const SizedBox(height: 20);
                  },
                ),
              ),

              // Logout Section
              _buildLogoutSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the drawer header with logo and status
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_borderRadius),
          bottomRight: Radius.circular(_borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Admin Icon
          _buildHeaderIcon(),
          const SizedBox(width: _mediumSpacing),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SocioCare Management',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          _buildStatusBadge(),
        ],
      ),
    );
  }

  /// Builds the admin icon in the header
  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(_miniSpacing),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: const Icon(
        Icons.admin_panel_settings_rounded,
        size: _iconSize,
        color: Colors.white,
      ),
    );
  }

  /// Builds the online status badge
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _microSpacing,
        vertical: _microTinySpacing,
      ),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _tinySpacing),
          const Text(
            'Online',
            style: TextStyle(
              color: Colors.white,
              fontSize: _smallFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a navigation item with icon, title and description
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String route,
    required String description,
  }) {
    final isActive = _currentRoute?.contains(route) ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _miniSpacing,
        vertical: _minusculeSpacing,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_microBorderRadius),
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
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ]
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          onTap: () => _handleNavigation(title, route),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _mediumSpacing,
              vertical: _smallSpacing,
            ),
            child: Row(
              children: [
                // Icon Container
                _buildNavItemIcon(icon, isActive),
                const SizedBox(width: _mediumSpacing),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: _subtitleFontSize,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          color:
                              isActive
                                  ? Colors.blue.shade800
                                  : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: _atomicSpacing),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: _smallFontSize,
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

  /// Builds the icon for a navigation item
  Widget _buildNavItemIcon(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade600 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(_tinyBorderRadius),
      ),
      child: Icon(
        icon,
        size: _smallIconSize,
        color: isActive ? Colors.white : Colors.grey.shade600,
      ),
    );
  }

  /// Builds a divider between nav sections
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: _miniSpacing,
        horizontal: _spacing,
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
    );
  }

  /// Builds the logout section at the bottom
  Widget _buildLogoutSection() {
    return Container(
      padding: const EdgeInsets.all(_mediumSpacing),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Admin Info
          _buildAdminInfoCard(),
          const SizedBox(height: _miniSpacing),

          // Logout Button
          _buildLogoutButton(),
        ],
      ),
    );
  }

  /// Builds the admin info card
  Widget _buildAdminInfoCard() {
    return Container(
      padding: const EdgeInsets.all(_miniSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_microBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              size: _microIconSize,
            ),
          ),
          const SizedBox(width: _smallSpacing),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'admin@sociocare.com',
                  style: TextStyle(
                    fontSize: _microFontSize,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the logout button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutConfirmation,
        icon: Icon(
          Icons.logout_rounded,
          size: _microIconSize,
          color: Colors.red.shade600,
        ),
        label: Text(
          'Logout',
          style: TextStyle(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w600,
            fontSize: _bodyFontSize,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: _miniSpacing),
          side: BorderSide(color: Colors.red.shade600, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_miniSpacing),
          ),
          minimumSize: const Size(0, 36),
        ),
      ),
    );
  }

  /// Handles navigation to a new route
  void _handleNavigation(String title, String route) {
    context.go(route);
    Navigator.pop(context);

    // Show snackbar for feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigasi ke $title'),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_miniSpacing),
        ),
      ),
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_spacing),
            ),
            title: Row(
              children: [
                Icon(Icons.logout_rounded, color: Colors.red.shade600),
                const SizedBox(width: _miniSpacing),
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
                onPressed: () => _performLogout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_miniSpacing),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  /// Performs the logout action
  Future<void> _performLogout() async {
    try {
      // First close the dialog and drawer
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(); // Close drawer

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 16),
              Text('Logging out...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Use AdminAuthService to properly clear all session data
      final AdminAuthService authService = AdminAuthService();
      await authService.logout();

      // Navigate to login page
      if (context.mounted) {
        context.go(RouteNames.adminLogin);

        // Show success message
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout berhasil'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
