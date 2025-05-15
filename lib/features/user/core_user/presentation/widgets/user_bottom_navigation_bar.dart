import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/navigation/route_names.dart';

class UserBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const UserBottomNavigationBar({Key? key, required this.selectedIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        // Don't navigate if we're already on this page
        if (index == selectedIndex) return;

        // Use a different approach based on the index
        switch (index) {
          case 0:
            GoRouter.of(context).goNamed('dashboard');
            break;
          case 1:
            GoRouter.of(context).goNamed('chatbot');
            break;
          case 2:
            GoRouter.of(context).goNamed('education');
            break;
          case 3:
            GoRouter.of(context).goNamed('profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
    );
  }
}
