import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Admin"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      drawer:
          const AdminNavigationDrawer(), // Your Admin Navigation Drawer widget
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Information
            const Text(
              "Informasi Admin",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Nama Lengkap: Admin Utama"),
                    SizedBox(height: 4.0),
                    Text("Email: admin.utama@example.com"),
                    SizedBox(height: 4.0),
                    Text("Nomor Telepon: 081234567890"),
                    SizedBox(height: 4.0),
                    Text("Jabatan: Super Admin"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Program Management Section
            const Text(
              "Program yang Dikelola",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // List of managed programs
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Placeholder count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text("Program Bantuan ${index + 1}"),
                    subtitle: const Text("Status: Aktif"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to program detail page (example)
                      // context.push(RouteNames.adminProgramDetail);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24.0),

            // Edit Data Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push(RouteNames.adminEditProfile);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: const Text("Ubah Data"),
              ),
            ),
            const SizedBox(height: 8.0),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Simple logout navigation
                  context.go(RouteNames.adminLogin);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 20.0,
                  ),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 255, 0, 0),
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: const Text("Logout"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
