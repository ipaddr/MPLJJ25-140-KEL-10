import 'package:flutter/material.dart';

class AdminEditProfileFormWidget extends StatefulWidget {
  const AdminEditProfileFormWidget({super.key});

  @override
  _AdminEditProfileFormWidgetState createState() =>
      _AdminEditProfileFormWidgetState();
}

class _AdminEditProfileFormWidgetState
    extends State<AdminEditProfileFormWidget> {
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with placeholder data (would be fetched from a real source)
    _namaLengkapController.text = "Admin Utama";
    _nomorTeleponController.text = "081234567890";
    _emailController.text = "admin.utama@example.com";
    _jabatanController.text = "Super Admin";
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: Implement save changes logic
    print('Nama Lengkap: ${_namaLengkapController.text}');
    print('Nomor Telepon: ${_nomorTeleponController.text}');
    print('Email: ${_emailController.text}');
    print('Jabatan: ${_jabatanController.text}');

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan data berhasil disimpan')),
    );

    // Navigate back to profile page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _namaLengkapController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              hintText: 'Masukkan nama lengkap Anda',
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _nomorTeleponController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: 'Masukkan nomor telepon Anda',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Masukkan email Anda',
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _jabatanController,
            decoration: const InputDecoration(
              labelText: 'Jabatan',
              hintText: 'Masukkan jabatan Anda',
            ),
          ),
          const SizedBox(height: 24.0),
          // Update button styling
          ElevatedButton(
            onPressed: _saveChanges,
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
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
