import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Halaman untuk membuat kata sandi baru setelah reset
class UserNewPasswordPage extends StatefulWidget {
  final Map<String, dynamic>? resetData;

  const UserNewPasswordPage({super.key, this.resetData});

  @override
  State<UserNewPasswordPage> createState() => _UserNewPasswordPageState();
}

class _UserNewPasswordPageState extends State<UserNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;
  late String _email;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /// Inisialisasi data dari parameter
  void _initializeData() {
    if (widget.resetData != null) {
      _email = widget.resetData!['email'] as String? ?? '';
      _userId = widget.resetData!['userId'] as String? ?? '';
    } else {
      _email = '';
      _userId = '';
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Mengecek kekuatan password
  bool _isPasswordStrong(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password);
  }

  /// Mendapatkan teks kekuatan kata sandi
  String _getPasswordStrengthText() {
    final password = _passwordController.text;
    if (password.isEmpty) return '';

    if (password.length < 6) {
      return 'Terlalu pendek';
    } else if (password.length < 8) {
      return 'Lemah';
    } else if (_isPasswordStrong(password)) {
      return 'Kuat';
    } else {
      return 'Sedang';
    }
  }

  /// Mendapatkan warna indikator kekuatan kata sandi
  Color _getPasswordStrengthColor() {
    final password = _passwordController.text;
    if (password.isEmpty) return Colors.grey;

    if (password.length < 6) {
      return Colors.red;
    } else if (password.length < 8) {
      return Colors.orange;
    } else if (_isPasswordStrong(password)) {
      return Colors.green;
    } else {
      return Colors.yellow.shade700;
    }
  }

  /// Proses reset kata sandi
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await _updateUserPassword();
        await _updateUserDocument();
        await _signOutAndNavigateToLogin();
      } catch (e) {
        _showErrorMessage(e.toString());
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    }
  }

  /// Update password pengguna
  Future<void> _updateUserPassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please try again.');
    }
    await user.updatePassword(_passwordController.text);
  }

  /// Update dokumen pengguna di Firestore
  Future<void> _updateUserDocument() async {
    if (_userId.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Keluar dan navigasi ke halaman login
  Future<void> _signOutAndNavigateToLogin() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      _showSuccessMessage();
      context.go(RouteNames.login);
    }
  }

  /// Menampilkan pesan sukses
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Kata sandi berhasil diperbarui'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Menampilkan pesan error
  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Error: $message')),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Validasi kata sandi
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  /// Validasi konfirmasi kata sandi
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  /// Membangun AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Kata Sandi Baru',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.go(RouteNames.forgotPassword);
        },
      ),
    );
  }

  /// Membangun body utama
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.blue.shade200],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 24.0),
              _buildFormSection(),
              const SizedBox(height: 24.0),
              _buildSecurityNotice(),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun bagian header
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Key Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              size: 50,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Buat Kata Sandi Baru',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            _email.isNotEmpty
                ? 'Silakan buat kata sandi baru untuk akun $_email'
                : 'Silakan buat kata sandi baru untuk akun Anda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Membangun bagian form
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSecurityInfoBox(),
            const SizedBox(height: 20),
            _buildNewPasswordField(),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 16.0),
            _buildConfirmPasswordField(),
            const SizedBox(height: 24.0),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  /// Membangun kotak info keamanan
  Widget _buildSecurityInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.purple.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.purple.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Keamanan Kata Sandi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan kata sandi mengandung:\n• Minimal 8 karakter\n• Kombinasi huruf besar dan kecil\n• Minimal 1 angka',
            style: TextStyle(fontSize: 12, color: Colors.purple.shade600),
          ),
        ],
      ),
    );
  }

  /// Membangun field kata sandi baru
  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Kata Sandi Baru',
        hintText: 'Masukkan kata sandi baru',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      enabled: !_isUpdating,
      onChanged:
          (_) => setState(() {}), // Trigger rebuild for strength indicator
      validator: _validatePassword,
    );
  }

  /// Membangun indikator kekuatan kata sandi
  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Text(
            'Kekuatan: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          Text(
            _getPasswordStrengthText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getPasswordStrengthColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun field konfirmasi kata sandi
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Kata Sandi Baru',
        hintText: 'Masukkan kembali kata sandi baru',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: Colors.grey.shade600,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isConfirmPasswordVisible,
      enabled: !_isUpdating,
      validator: _validateConfirmPassword,
    );
  }

  /// Membangun tombol simpan
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isUpdating ? null : _resetPassword,
        icon:
            _isUpdating
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.save_rounded),
        label: Text(_isUpdating ? 'Menyimpan...' : 'Simpan Kata Sandi Baru'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Membangun pesan keamanan
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Setelah kata sandi diperbarui, Anda akan diarahkan ke halaman login untuk masuk dengan kata sandi baru.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
