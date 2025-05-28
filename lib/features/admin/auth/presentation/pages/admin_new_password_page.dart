import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Halaman pembuatan kata sandi baru untuk admin
class AdminNewPasswordPage extends StatefulWidget {
  final Map<String, dynamic> resetData;

  const AdminNewPasswordPage({super.key, required this.resetData});

  @override
  State<AdminNewPasswordPage> createState() => _AdminNewPasswordPageState();
}

class _AdminNewPasswordPageState extends State<AdminNewPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isUpdating = false;
  late String _email;
  late String _adminId;

  @override
  void initState() {
    super.initState();
    _email = widget.resetData['email'] as String;
    _adminId = widget.resetData['adminId'] as String;
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
        await _updatePassword();
        await _updateAdminDocument();
        await _signOutAndShowSuccess();
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
  Future<void> _updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated. Please try again.');
    }
    await user.updatePassword(_passwordController.text);
  }

  /// Update dokumen admin di Firestore
  Future<void> _updateAdminDocument() async {
    await FirebaseFirestore.instance.collection('admins').doc(_adminId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sign out dan tampilkan pesan sukses
  Future<void> _signOutAndShowSuccess() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      _showSuccessMessage();
      context.go(RouteNames.adminLogin);
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
      return 'Kata sandi tidak sama';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
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
      ),
    );
  }

  /// AppBar untuk halaman kata sandi baru
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          context.go(RouteNames.adminForgotPassword);
        },
      ),
    );
  }

  /// Widget bagian header halaman
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: 50,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),

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
            'Buat kata sandi baru untuk akun $_email',
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

  /// Widget bagian form kata sandi baru
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
            _buildPasswordField(),
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 24),
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  /// Widget field kata sandi
  Widget _buildPasswordField() {
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
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed:
              _isUpdating
                  ? null
                  : () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
      obscureText: !_isPasswordVisible,
      enabled: !_isUpdating,
      onChanged: (_) => setState(() {}), // Update strength indicator
      validator: _validatePassword,
    );
  }

  /// Widget indikator kekuatan kata sandi
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Kekuatan: ${_getPasswordStrengthText()}',
              style: TextStyle(
                fontSize: 12,
                color: _getPasswordStrengthColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.info_outline, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              'Minimal 8 karakter dengan huruf besar, kecil & angka',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value:
              password.length < 6
                  ? 0.3
                  : (password.length < 8
                      ? 0.6
                      : (_isPasswordStrong(password) ? 1.0 : 0.8)),
          backgroundColor: Colors.grey.shade200,
          color: _getPasswordStrengthColor(),
        ),
      ],
    );
  }

  /// Widget field konfirmasi kata sandi
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: InputDecoration(
        labelText: 'Konfirmasi Kata Sandi',
        hintText: 'Masukkan kata sandi yang sama',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey.shade600,
          ),
          onPressed:
              _isUpdating
                  ? null
                  : () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
        ),
      ),
      obscureText: !_isConfirmPasswordVisible,
      enabled: !_isUpdating,
      validator: _validateConfirmPassword,
    );
  }

  /// Widget tombol reset kata sandi
  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _isUpdating ? null : _resetPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      child:
          _isUpdating
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
                  Text('Menyimpan...'),
                ],
              )
              : const Text('Simpan Kata Sandi Baru'),
    );
  }

  /// Widget informasi keamanan
  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Keamanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan kata sandi yang kuat dan jangan pernah membagikannya. Anda akan diminta untuk login kembali setelah mengubah kata sandi.',
                  style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
