import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminRegisterFormWidget extends StatefulWidget {
  const AdminRegisterFormWidget({super.key});

  @override
  State<AdminRegisterFormWidget> createState() =>
      _AdminRegisterFormWidgetState();
}

class _AdminRegisterFormWidgetState extends State<AdminRegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _konfirmasiEmailController =
      TextEditingController();
  final TextEditingController _kataSandiController = TextEditingController();
  final TextEditingController _konfirmasiKataSandiController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _konfirmasiEmailController.dispose();
    _kataSandiController.dispose();
    _konfirmasiKataSandiController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Admin Registration logic using Bloc/Cubit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Processing Admin Registration Data')),
      );
      // After successful registration, maybe navigate to a success page or login page
      // context.go(RouteNames.adminLogin);
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
            controller: _namaLengkapController,
            decoration: const InputDecoration(
              labelText: 'Nama Lengkap',
              hintText: 'Nama Lengkap Admin',
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
              hintText: 'Nomor Telepon Admin',
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
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Email Admin',
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
              if (!value.contains('@')) {
                return 'Masukkan email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _konfirmasiEmailController,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Email',
              hintText: 'Konfirmasi Email Admin',
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
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Masukkan Kata Sandi Admin',
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata Sandi tidak boleh kosong';
              }
              // Basic password strength check (can be expanded)
              if (value.length < 8) {
                return 'Kata Sandi minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 8.0,
          ), // Space between password field and requirements
          // Password requirements list - Simplified for admin registration if needed, or keep full
          // based on your decision. Using simplified here for example.
          const Text('Minimal 8 karakter', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 16.0), // Space after password requirements
          TextFormField(
            controller: _konfirmasiKataSandiController,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Kata Sandi',
              hintText: 'Konfirmasi Kata Sandi Admin Anda',
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
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
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: Colors.blue, // Blue background
              foregroundColor: Colors.white, // White text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('BUAT AKUN ADMIN'),
          ),
        ],
      ),
    );
  }
}
