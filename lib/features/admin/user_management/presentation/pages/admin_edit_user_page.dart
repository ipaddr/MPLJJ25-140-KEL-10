import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminEditUserPage extends StatelessWidget {
  final String userId; // To receive the user ID from navigation

  const AdminEditUserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch user data based on userId
    // Placeholder for fetching user data
    final Map<String, dynamic> userData = {
      'id': userId,
      'nama_lengkap': 'Nama Pengguna ${userId}', // Placeholder data
      'email': 'email.${userId}@example.com',
      'lokasi': 'Lokasi ${userId}',
      'penghasilan': 'Penghasilan ${userId}',
      'status': 'Status ${userId}',
      // Add other user fields
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Pengguna: ${userData['nama_lengkap']}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to User List Page
            context.go(RouteNames.adminUserList);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade200,
            ], // Consistent gradient
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TODO: Build the form for editing user data
                Text(
                  'Formulir Edit Pengguna untuk ${userData['nama_lengkap']}',
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  initialValue: userData['nama_lengkap'],
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  // TODO: Add controller and validation
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: userData['email'],
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  // TODO: Add controller and validation
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: userData['lokasi'],
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                  // TODO: Add controller and validation
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: userData['penghasilan'],
                  decoration: const InputDecoration(
                    labelText: 'Perkiraan Penghasilan',
                  ),
                  keyboardType: TextInputType.number,
                  // TODO: Add controller and validation
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value:
                      userData['status'], // This will need to be managed with state
                  decoration: const InputDecoration(labelText: 'Status Akun'),
                  items:
                      ['Terverifikasi', 'Menunggu Verifikasi', 'Diblokir'].map((
                        String status,
                      ) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    // TODO: Update status (will need state management)
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save changes logic
                    print('Saving changes for user: ${userData['id']}');
                    // After saving, navigate back to the user list
                    // context.go(RouteNames.adminUserList);
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
