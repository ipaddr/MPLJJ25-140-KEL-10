import 'package:flutter/material.dart';

class EditUserProfileFormWidget extends StatefulWidget {
  const EditUserProfileFormWidget({Key? key}) : super(key: key);

  @override
  _EditUserProfileFormWidgetState createState() =>
      _EditUserProfileFormWidgetState();
}

class _EditUserProfileFormWidgetState extends State<EditUserProfileFormWidget> {
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pendapatanPerBulanController =
      TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _pendapatanPerBulanController.dispose();
    _jenisPekerjaanController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: Implement save changes logic
    print('Nama Lengkap: ${_namaLengkapController.text}');
    print('Nomor Telepon: ${_nomorTeleponController.text}');
    print('Email: ${_emailController.text}');
    print('Pendapatan Per Bulan: ${_pendapatanPerBulanController.text}');
    print('Jenis Pekerjaan: ${_jenisPekerjaanController.text}');
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
            controller: _pendapatanPerBulanController,
            decoration: const InputDecoration(
              labelText: 'Pendapatan Per Bulan',
              hintText: 'Masukkan pendapatan per bulan Anda',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _jenisPekerjaanController,
            decoration: const InputDecoration(
              labelText: 'Jenis Pekerjaan',
              hintText: 'Masukkan jenis pekerjaan Anda',
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _saveChanges,
            child: const Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }
}
