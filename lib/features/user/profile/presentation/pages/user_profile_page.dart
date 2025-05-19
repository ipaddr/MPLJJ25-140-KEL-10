import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Akun", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for User Information
              const Text(
                "Informasi Pengguna",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Nama Lengkap: [Nama Pengguna]"),
                      SizedBox(height: 4.0),
                      Text("Email: [Email Pengguna]"),
                      SizedBox(height: 4.0),
                      Text("Nomor Telepon: [Nomor Telepon Pengguna]"),
                      SizedBox(height: 4.0),
                      Text("Jenis Pekerjaan: [Jenis Pekerjaan Pengguna]"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Placeholder for Status Pengajuan Program
              const Text(
                "Status Pengajuan Program",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              // Placeholder for list of submissions
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Placeholder count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        "Program Bantuan ${index + 1}",
                      ), // Placeholder
                      subtitle: Text(
                        "Status: [Status ${index + 1}]",
                      ), // Placeholder
                      // Add more details or actions if needed
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
                    context.push(RouteNames.editUserProfile);
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
                    context.go(RouteNames.login);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    side: const BorderSide(color: Color(0xFF0066CC), width: 2),
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
      ),
      bottomNavigationBar: const UserBottomNavigationBar(
        selectedIndex: 3, // Profile is the fourth item
      ),
    );
  }
}
