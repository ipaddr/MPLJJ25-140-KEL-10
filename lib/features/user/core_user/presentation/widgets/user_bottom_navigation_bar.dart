import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const UserBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              label: 'Beranda',
              index: 0,
              isSelected: selectedIndex == 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.smart_toy_rounded,
              label: 'AI Chat',
              index: 1,
              isSelected: selectedIndex == 1,
            ),
            _buildNavItem(
              context,
              icon: Icons.menu_book_rounded,
              label: 'Edukasi',
              index: 2,
              isSelected: selectedIndex == 2,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: 'Profil',
              index: 3,
              isSelected: selectedIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == selectedIndex) return;

          // Add haptic feedback
          _navigateToPage(context, index);
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100.withOpacity(0.3),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animation container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.blue.shade700
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
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
                  size: isSelected ? 22 : 20,
                  color: isSelected 
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).goNamed('user-dashboard');
        break;
      case 1:
        GoRouter.of(context).goNamed('user-chatbot');
        break;
      case 2:
        GoRouter.of(context).goNamed('user-education');
        break;
      case 3:
        GoRouter.of(context).goNamed('user-profile');
        break;
    }
  }
}