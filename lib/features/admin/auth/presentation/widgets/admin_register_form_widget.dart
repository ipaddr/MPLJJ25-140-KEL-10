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

        final user = userCredential.user;
        if (user == null) {
          throw Exception('Gagal membuat akun admin');
        }

        // 2. Send email verification
        await user.sendEmailVerification();

        // 3. Store admin data in Firestore (using admin_profiles collection)
        await FirebaseFirestore.instance
            .collection('admin_profiles')
            .doc(user.uid)
            .set({
              'fullName': _namaLengkapController.text.trim(),
              'phoneNumber': _nomorTeleponController.text.trim(),
              'email': _emailController.text.trim(),
              'role': 'admin',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true,
              'emailVerified': false,
            });

        // 4. Update Firebase Auth display name
        await user.updateDisplayName(_namaLengkapController.text.trim());

        // 5. Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi admin berhasil! Silakan periksa email Anda untuk verifikasi.',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // 6. Navigate to admin login
          context.go(RouteNames.adminLogin);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email sudah terdaftar';
            break;
          case 'weak-password':
            errorMessage = 'Password terlalu lemah (minimal 6 karakter)';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Operasi tidak diizinkan';
            break;
          default:
            errorMessage = 'Terjadi kesalahan: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama Lengkap tidak boleh kosong';
              }
              if (value.trim().length < 3) {
                return 'Nama Lengkap minimal 3 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          TextFormField(
            controller: _nomorTeleponController,
            decoration: const InputDecoration(
              labelText: 'Nomor Telepon',
              hintText: 'Contoh: 08123456789',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.phone,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nomor Telepon tidak boleh kosong';
              }
              if (!value.startsWith('08') || value.length < 10) {
                return 'Masukkan nomor telepon yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'contoh@email.com',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!value.contains('@') || !value.contains('.')) {
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
              hintText: 'Masukkan email yang sama',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
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
              labelText: 'Kata Sandi',
              hintText: 'Masukkan Kata Sandi (minimal 6 karakter)',
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
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
              ),
            ),
            obscureText: !_isPasswordVisible,
            enabled: !_isLoading,
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

          TextFormField(
            controller: _konfirmasiKataSandiController,
            decoration: InputDecoration(
              labelText: 'Konfirmasi Kata Sandi',
              hintText: 'Masukkan kata sandi yang sama',
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
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
              ),
            ),
            obscureText: !_isConfirmPasswordVisible,
            enabled: !_isLoading,
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
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Membuat Akun Admin...'),
                      ],
                    )
                    : const Text('Buat Akun Admin'),
          ),
        ],
      ),
    );
  }
}
