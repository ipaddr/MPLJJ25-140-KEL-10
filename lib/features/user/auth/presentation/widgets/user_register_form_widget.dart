import 'package:flutter/material.dart';

class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _konfirmasiEmailController =
      TextEditingController();
  final TextEditingController _kataSandiController = TextEditingController();
  final TextEditingController _konfirmasiKataSandiController =
      TextEditingController();
  final TextEditingController _pendapatanPerBulanController =
      TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _jenisPekerjaanController.dispose();
    _lokasiController.dispose();
    _emailController.dispose();
    _konfirmasiEmailController.dispose();
    _kataSandiController.dispose();
    _konfirmasiKataSandiController.dispose();
    _pendapatanPerBulanController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // Process registration
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processing Data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            controller: _nikController,
            decoration: const InputDecoration(
              labelText: 'Nomor Induk Kependudukan (NIK)',
              hintText: 'Masukkan NIK',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'NIK tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _namaLengkapController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              hintText: 'Nama Lengkap',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama Lengkap tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _nomorTeleponController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: 'Nomor Telepon',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor Telepon tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _jenisPekerjaanController,
            decoration: const InputDecoration(
              labelText: 'Jenis Pekerjaan',
              hintText: 'Jenis Pekerjaan',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jenis Pekerjaan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _lokasiController,
            decoration: const InputDecoration(
              labelText: 'Lokasi',
              hintText: 'Lokasi',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lokasi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              // Add email format validation if needed
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _konfirmasiEmailController,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Email',
              hintText: 'Konfirmasi Email',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi Email tidak boleh kosong';
              }
              if (value != _emailController.text) {
                return 'Email tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _kataSandiController,
            decoration: const InputDecoration(
              labelText: 'Password',
              hintText: 'Masukkan Kata Sandi',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(
                Icons.visibility_outlined,
              ), // Placeholder eye icon
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata Sandi tidak boleh kosong';
              }
              // Add password strength validation if needed
              return null;
            },
          ),
          const SizedBox(
            height: 8.0,
          ), // Space between password field and requirements
          // Password requirements list
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ Minimal 8 karakter', style: TextStyle(fontSize: 12)),
              Text(
                '❌ Mengandung setidaknya 1 huruf besar',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '❌ Mengandung setidaknya 1 huruf kecil',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '❌ Mengandung setidaknya 1 angka',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '❌ Mengandung setidaknya 1 spesial karakter',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16.0), // Space after password requirements
          TextFormField(
            controller: _konfirmasiKataSandiController,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Kata Sandi',
              hintText: 'Konfirmasi Kata Sandi Anda',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
              suffixIcon: Icon(
                Icons.visibility_outlined,
              ), // Placeholder eye icon
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi Kata Sandi tidak boleh kosong';
              }
              if (value != _kataSandiController.text) {
                return 'Kata Sandi tidak cocok';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _pendapatanPerBulanController,
            decoration: const InputDecoration(
              labelText: 'Pendapatan per Bulan',
              hintText: 'Masukkan Pendapatan Per Bulan Anda',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pendapatan Per Bulan tidak boleh kosong';
              }
              // Add numerical validation if needed
              return null;
            },
          ),
          const SizedBox(height: 24.0), // Space before photo upload section
          const Text(
            'Lampiran Foto',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0), // Space after Lampiran Foto text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Swafoto Dengan KTP upload area
              Expanded(
                child: Container(
                  height: 120, // Adjust height as needed
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                      ), // Placeholder camera icon
                      SizedBox(height: 8.0),
                      Text('Swafoto Dengan KTP', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16.0), // Space between upload areas
              // Foto KTP upload area
              Expanded(
                child: Container(
                  height: 120, // Adjust height as needed
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                      ), // Placeholder camera icon
                      SizedBox(height: 8.0),
                      Text('Foto KTP', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              backgroundColor: const Color(
                0xFF0066CC,
              ), // Changed from Colors.blue
              foregroundColor: Colors.white, // Changed from white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0), // Changed from 8.0
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            child: const Text('Buat Akun'),
          ),
        ],
      ),
    );
  }
}
