import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminEditUserPage extends StatefulWidget {
  final String userId; // To receive the user ID from navigation

  const AdminEditUserPage({super.key, required this.userId});

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  late String selectedStatus;
  late Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user data based on userId
    // Placeholder for fetching user data
    userData = {
      'id': widget.userId,
      'nama_lengkap': 'Nama Pengguna ${widget.userId}', // Placeholder data
      'email': 'email.${widget.userId}@example.com',
      'lokasi': 'Lokasi ${widget.userId}',
      'penghasilan': 'Penghasilan ${widget.userId}',
      // Use a valid default status instead of 'Status user_001'
    };

    // Initialize with a valid status
    selectedStatus = 'Terverifikasi';
  }

  @override
  Widget build(BuildContext context) {
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
                      selectedStatus, // Use state variable instead of userData
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
                    if (newValue != null) {
                      setState(() {
                        selectedStatus = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save changes logic
                    print('Saving changes for user: ${userData['id']}');
                    print('New status: $selectedStatus');
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
