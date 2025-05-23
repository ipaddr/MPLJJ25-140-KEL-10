import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _isLoading = false;

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

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Create user with Firebase Auth
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _kataSandiController.text,
            );

        // 2. Send email verification
        await userCredential.user!.sendEmailVerification();

        // 3. Store admin data in Firestore
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(userCredential.user!.uid)
            .set({
              'fullName': _namaLengkapController.text.trim(),
              'phoneNumber': _nomorTeleponController.text.trim(),
              'email': _emailController.text.trim(),
              'role': 'admin', // Default role for new admins
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'emailVerified': false, // Track verification status
            });

        // 4. Show success message with verification instructions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil! Silakan periksa email Anda untuk verifikasi.',
            ),
          ),
        );

        // 5. Navigate to admin login
        if (mounted) {
          context.go(RouteNames.adminLogin);
        }
      } on FirebaseAuthException catch (e) {
        // Error handling code remains the same
      }
      // Rest of the method remains the same
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Existing Name field
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

          // Existing Phone field
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

          // Existing Email field
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

          // MISSING: Konfirmasi Email field
          TextFormField(
            controller: _konfirmasiEmailController,
            decoration: const InputDecoration(
              labelText: 'Konfirmasi Email',
              hintText: 'Masukkan Email Lagi',
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

          // MISSING: Kata Sandi field
          TextFormField(
            controller: _kataSandiController,
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              hintText: 'Masukkan Kata Sandi',
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
              if (value.length < 6) {
                return 'Kata Sandi minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          // MISSING: Konfirmasi Kata Sandi field
          TextFormField(
            controller: _konfirmasiKataSandiController,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Kata Sandi',
              hintText: 'Masukkan Kata Sandi Lagi',
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

          // Existing Register button
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Buat Akun Admin'),
          ),
        ],
      ),
    );
  }
}
