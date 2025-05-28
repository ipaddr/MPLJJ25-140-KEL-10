import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_auth_service.dart';

/// Widget form untuk login admin
class AdminLoginFormWidget extends StatefulWidget {
  const AdminLoginFormWidget({super.key});

  @override
  _AdminLoginFormWidgetState createState() => _AdminLoginFormWidgetState();
}

class _AdminLoginFormWidgetState extends State<AdminLoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AdminAuthService _authService = AdminAuthService();
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Proses login admin
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
          await _verifyAdminAccount(user);
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

  /// Verifikasi akun admin
  Future<void> _verifyAdminAccount(User user) async {
    // Check if user exists in 'admin_profiles' collection
    DocumentSnapshot adminDoc = await FirebaseFirestore.instance
        .collection('admin_profiles')
        .doc(user.uid)
        .get();

    if (adminDoc.exists) {
      await _processValidAdminLogin(user, adminDoc.data() as Map<String, dynamic>);
    } else {
      await _checkIfRegularUser(user);
    }
  }

  /// Pemrosesan login untuk admin yang tervalidasi
  Future<void> _processValidAdminLogin(User user, Map<String, dynamic> adminData) async {
    // Check if admin account is active
    bool isActive = adminData['isActive'] ?? true;
    if (!isActive) {
      await FirebaseAuth.instance.signOut();
      throw Exception('Akun admin Anda tidak aktif. Hubungi super admin.');
    }

    // Get current Firebase user and token
    String? authToken = await user.getIdToken();
    
    if (authToken == null) {
      throw Exception('Gagal mendapatkan token autentikasi.');
    }
    
    // Save login information to persist across app sessions
    await _authService.saveLoginInfo(
      authToken: authToken,
      adminId: user.uid,
      name: adminData['name'] ?? adminData['fullName'] ?? '',
      email: user.email ?? _emailController.text.trim(),
    );

    // Update last login timestamp
    await FirebaseFirestore.instance
        .collection('admin_profiles')
        .doc(user.uid)
        .update({
      'lastLogin': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      _showSuccessMessage();
      context.go(RouteNames.adminDashboard);
    }
  }

  /// Periksa apakah akun adalah pengguna biasa
  Future<void> _checkIfRegularUser(User user) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseAuth.instance.signOut();
    
    if (userDoc.exists) {
      throw Exception('Gunakan halaman login user untuk akun ini.');
    } else {
      throw Exception('Data admin tidak ditemukan.');
    }
  }

  /// Menampilkan pesan sukses login
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login admin berhasil!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Menangani error autentikasi
  void _handleAuthError(FirebaseAuthException e) {
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

    _showErrorMessage(errorMessage);
  }

  /// Menampilkan pesan error
  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!value.contains('@')) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  /// Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: 16.0),
          _buildPasswordField(),
          const SizedBox(height: 24.0),
          _buildLoginButton(),
        ],
      ),
    );
  }

  /// Widget field email
  Widget _buildEmailField() {
    return TextFormField(
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
      validator: _validateEmail,
    );
  }

  /// Widget field password
  Widget _buildPasswordField() {
    return TextFormField(
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
      validator: _validatePassword,
    );
  }

  /// Widget tombol login
  Widget _buildLoginButton() {
    return ElevatedButton(
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
    );
  }
}