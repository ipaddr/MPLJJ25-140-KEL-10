import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLoginFormWidget extends StatefulWidget {
  const AdminLoginFormWidget({super.key});

  @override
  _AdminLoginFormWidgetState createState() => _AdminLoginFormWidgetState();
}

class _AdminLoginFormWidgetState extends State<AdminLoginFormWidget> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Authenticate with Firebase
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          // 2. Check if user exists in 'admin_profiles' collection
          DocumentSnapshot adminDoc = await FirebaseFirestore.instance
              .collection('admin_profiles')
              .doc(user.uid)
              .get();

          if (adminDoc.exists) {
            // Admin found in admin_profiles collection
            Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;
            
            // 3. Check if admin account is active
            bool isActive = adminData['isActive'] ?? true;
            if (!isActive) {
              await FirebaseAuth.instance.signOut();
              throw Exception('Akun admin Anda tidak aktif. Hubungi super admin.');
            }

            // 4. Update last login timestamp
            await FirebaseFirestore.instance
                .collection('admin_profiles')
                .doc(user.uid)
                .update({
              'lastLogin': FieldValue.serverTimestamp(),
            });

            // 5. Navigate to admin dashboard
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login admin berhasil!'),
                  backgroundColor: Colors.green,
                ),
              );
              context.go(RouteNames.adminDashboard);
            }
          } else {
            // Check if this email belongs to a regular user
            DocumentSnapshot userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

            if (userDoc.exists) {
              await FirebaseAuth.instance.signOut();
              throw Exception('Gunakan halaman login user untuk akun ini.');
            } else {
              await FirebaseAuth.instance.signOut();
              throw Exception('Data admin tidak ditemukan.');
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Email admin tidak terdaftar.';
            break;
          case 'wrong-password':
            errorMessage = 'Password salah.';
            break;
          case 'invalid-email':
            errorMessage = 'Format email tidak valid.';
            break;
          case 'user-disabled':
            errorMessage = 'Akun admin telah dinonaktifkan.';
            break;
          case 'too-many-requests':
            errorMessage = 'Terlalu banyak percobaan login. Coba lagi nanti.';
            break;
          case 'invalid-credential':
            errorMessage = 'Email atau password salah.';
            break;
          default:
            errorMessage = 'Terjadi kesalahan: ${e.message}';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
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
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              hintText: 'Email Admin',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              isDense: true,
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
            controller: _passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              hintText: 'Password',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              isDense: true,
            ),
            obscureText: !_isPasswordVisible,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
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
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Masuk sebagai Admin',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
          ),
        ],
      ),
    );
  }
}