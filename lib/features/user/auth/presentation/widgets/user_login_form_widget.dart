import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/user_auth_service.dart';

/// Widget form untuk login pengguna
class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  _LoginFormWidgetState createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserAuthService _authService = UserAuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Proses login pengguna
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Authenticate with Firebase
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        final User? user = userCredential.user;
        if (user != null) {
          await _verifyUserAccount(user);
        }
      } on FirebaseAuthException catch (e) {
        _handleAuthError(e);
      } catch (e) {
        _showErrorMessage(e.toString().replaceAll('Exception: ', ''));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Verifikasi akun pengguna
  Future<void> _verifyUserAccount(User user) async {
    // Check if user exists in 'users' collection
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (userDoc.exists) {
      await _processValidUserLogin(
        user,
        userDoc.data() as Map<String, dynamic>,
      );
    } else {
      await _checkIfAdminAccount(user);
    }
  }

  /// Proses login untuk pengguna valid
  Future<void> _processValidUserLogin(
    User user,
    Map<String, dynamic> userData,
  ) async {
    // Check if user account is active
    final bool isActive = userData['isActive'] ?? true;
    if (!isActive) {
      await FirebaseAuth.instance.signOut();
      throw Exception('Akun Anda tidak aktif. Hubungi administrator.');
    }

    // Get token and save login information
    String? authToken = await user.getIdToken();

    if (authToken == null) {
      throw Exception('Gagal mendapatkan token autentikasi.');
    }

    // Save login information to persist across app sessions
    await _authService.saveLoginInfo(
      authToken: authToken,
      userId: user.uid,
      name: userData['name'] ?? userData['fullName'] ?? '',
      email: user.email ?? _emailController.text.trim(),
    );

    // Update last login timestamp
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });

    // Navigate to user dashboard
    if (mounted) {
      _showSuccessMessage();
      context.go(RouteNames.userDashboard);
    }
  }

  /// Periksa jika akun adalah akun admin
  Future<void> _checkIfAdminAccount(User user) async {
    final DocumentSnapshot adminDoc =
        await FirebaseFirestore.instance
            .collection('admin_profiles')
            .doc(user.uid)
            .get();

    await FirebaseAuth.instance.signOut();

    if (adminDoc.exists) {
      throw Exception('Gunakan halaman login admin untuk akun ini.');
    } else {
      throw Exception('Data pengguna tidak ditemukan.');
    }
  }

  /// Menampilkan pesan sukses
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login berhasil!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Menangani error autentikasi
  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'Email tidak terdaftar.';
        break;
      case 'wrong-password':
        errorMessage = 'Password salah.';
        break;
      case 'invalid-email':
        errorMessage = 'Format email tidak valid.';
        break;
      case 'user-disabled':
        errorMessage = 'Akun telah dinonaktifkan.';
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

    _showErrorMessage(errorMessage);
  }

  /// Menampilkan pesan error
  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              hintText: 'Email',
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
          
          // Password Field
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: _isLoading 
                    ? null 
                    : () {
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
          
          // Login Button
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
                    'Masuk',
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
          ),
        ],
      ),
    );
  }
}