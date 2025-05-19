import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/navigation/route_names.dart';

class UserBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const UserBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD6F0FF), // Solid light blue color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Edukasi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Akun',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor:
            Colors.blue.shade700, // Darker blue for selected items
        unselectedItemColor: Colors.blue.shade400, // Medium blue for unselected
        backgroundColor: Colors.transparent,
        elevation: 0,
        onTap: (index) {
          // Don't navigate if we're already on this page
          if (index == selectedIndex) return;

          // Use a different approach based on the index
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
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
