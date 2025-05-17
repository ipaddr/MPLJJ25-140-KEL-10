import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminNavigationDrawer extends StatelessWidget {
  const AdminNavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue.shade700),
            child: const Text(
              'Menu Admin',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manajemen Pengguna'),
            onTap: () {
              context.go(
                RouteNames.adminUserList,
              ); // Assuming this route exists
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Manajemen Program'),
            onTap: () {
              context.go(RouteNames.adminProgramList);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Manajemen Pengajuan'),
            onTap: () {
              context.go(RouteNames.adminSubmissionManagement);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Manajemen Konten Edukasi'),
            onTap: () {
              context.go(RouteNames.adminEducationContent);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profil Admin'),
            onTap: () {
              context.go(RouteNames.adminProfile);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              context.go(RouteNames.adminLogin);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
