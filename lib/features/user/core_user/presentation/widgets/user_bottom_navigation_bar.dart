import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Widget bottom navigation bar untuk halaman utama pengguna
///
/// Menyediakan navigasi ke 4 halaman utama: Beranda, AI Chat, Edukasi, dan Profil
class UserBottomNavigationBar extends StatelessWidget {
  /// Index item yang sedang dipilih (0-3)
  final int selectedIndex;

  // UI Constants
  static const double _navBarHeight = 70.0;
  static const double _navBarMargin = 16.0;
  static const double _navBarRadius = 25.0;
  static const double _iconPaddingSelected = 8.0;
  static const double _iconPaddingNormal = 6.0;
  static const double _iconSizeSelected = 22.0;
  static const double _iconSizeNormal = 20.0;
  static const double _textSizeSelected = 11.0;
  static const double _textSizeNormal = 10.0;
  static const double _iconRadius = 12.0;
  static const double _verticalSpacing = 4.0;

  // Animation Constants
  static const Duration _animationDuration = Duration(milliseconds: 200);

  // Route Names
  static const Map<int, String> _routeNames = {
    0: 'user-dashboard',
    1: 'user-chatbot',
    2: 'user-education',
    3: 'user-profile',
  };

  // Navigation Items Data
  static const List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Beranda'},
    {'icon': Icons.smart_toy_rounded, 'label': 'AI Chat'},
    {'icon': Icons.menu_book_rounded, 'label': 'Edukasi'},
    {'icon': Icons.person_rounded, 'label': 'Profil'},
  ];

  const UserBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _navBarHeight,
      margin: const EdgeInsets.all(_navBarMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_navBarRadius),
        boxShadow: _buildNavBarShadows(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_navBarRadius),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildNavigationItems(context),
        ),
      ),
    );
  }

  /// Membangun efek bayangan untuk navbar
  List<BoxShadow> _buildNavBarShadows() {
    return [
      BoxShadow(
        color: Colors.blue.withOpacity(0.15),
        blurRadius: 20,
        offset: const Offset(0, 5),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Membangun semua item navigasi
  List<Widget> _buildNavigationItems(BuildContext context) {
    return List.generate(_navItems.length, (index) {
      final item = _navItems[index];
      final isSelected = selectedIndex == index;

      return _buildNavItem(
        context,
        icon: item['icon'],
        label: item['label'],
        index: index,
        isSelected: isSelected,
      );
    });
  }

  /// Membangun item navigasi tunggal
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleNavigation(context, index),
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isSelected ? _buildSelectedGradient() : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavIcon(icon, isSelected),
              const SizedBox(height: _verticalSpacing),
              _buildNavLabel(label, isSelected),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun gradient latar belakang untuk item yang dipilih
  LinearGradient _buildSelectedGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blue.shade50, Colors.blue.shade100.withOpacity(0.3)],
    );
  }

  /// Membangun ikon navigasi dengan animasi
  Widget _buildNavIcon(IconData icon, bool isSelected) {
    return AnimatedContainer(
      duration: _animationDuration,
      padding: EdgeInsets.all(
        isSelected ? _iconPaddingSelected : _iconPaddingNormal,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade700 : Colors.transparent,
        borderRadius: BorderRadius.circular(_iconRadius),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Icon(
        icon,
        size: isSelected ? _iconSizeSelected : _iconSizeNormal,
        color: isSelected ? Colors.white : Colors.grey.shade600,
      ),
    );
  }

  /// Membangun label navigasi dengan animasi
  Widget _buildNavLabel(String label, bool isSelected) {
    return AnimatedDefaultTextStyle(
      duration: _animationDuration,
      style: TextStyle(
        fontSize: isSelected ? _textSizeSelected : _textSizeNormal,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }

  /// Menangani navigasi ke halaman berdasarkan index
  void _handleNavigation(BuildContext context, int index) {
    // Skip navigasi jika sudah berada di halaman yang sama
    if (index == selectedIndex) return;

    // Navigasi ke halaman sesuai index
    final routeName = _routeNames[index];
    if (routeName != null) {
      GoRouter.of(context).goNamed(routeName);
    }
  }
}
