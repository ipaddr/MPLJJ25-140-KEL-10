import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Widget form untuk pendaftaran akun pengguna
class RegisterFormWidget extends StatefulWidget {
  const RegisterFormWidget({super.key});

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
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

  // UI state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _kataSandiController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    // Dispose all controllers
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

  /// Validasi kekuatan password
  void _validatePassword() {
    final password = _kataSandiController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  /// Cek apakah password valid sesuai semua kriteria
  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar;

  /// Proses registrasi pengguna
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Check if password meets requirements
      if (!_isPasswordValid) {
        _showErrorMessage('Password harus memenuhi semua persyaratan');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        await _checkNikAvailability();
        final user = await _createFirebaseUser();
        await _sendEmailVerification(user);
        await _storeUserData(user);
        await _updateUserDisplayName(user);
        _showSuccessMessage();
        _navigateToLogin();
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

  /// Memeriksa apakah NIK sudah terdaftar
  Future<void> _checkNikAvailability() async {
    final QuerySnapshot nikQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .where('nik', isEqualTo: _nikController.text.trim())
            .get();

    if (nikQuery.docs.isNotEmpty) {
      throw Exception('NIK sudah terdaftar');
    }
  }

  /// Membuat user baru di Firebase Authentication
  Future<User> _createFirebaseUser() async {
    final UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _kataSandiController.text,
        );

    final User? user = userCredential.user;
    if (user == null) {
      throw Exception('Gagal membuat akun');
    }
    return user;
  }

  /// Mengirim email verifikasi
  Future<void> _sendEmailVerification(User user) async {
    await user.sendEmailVerification();
  }

  /// Menyimpan data user ke Firestore
  Future<void> _storeUserData(User user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'nik': _nikController.text.trim(),
      'fullName': _namaLengkapController.text.trim(),
      'phoneNumber': _nomorTeleponController.text.trim(),
      'jobType': _jenisPekerjaanController.text.trim(),
      'location': _lokasiController.text.trim(),
      'email': _emailController.text.trim(),
      'monthlyIncome':
          double.tryParse(_pendapatanPerBulanController.text.trim()) ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isVerified': false, // Will be manually verified by admin later if needed
      'isActive': true,
      'emailVerified': false,
      'role': 'user',
      'documentStatus':
          'pending', // Can be updated later when user uploads documents
    });
  }

  /// Update display name di Firebase Auth
  Future<void> _updateUserDisplayName(User user) async {
    await user.updateDisplayName(_namaLengkapController.text.trim());
  }

  /// Menampilkan pesan sukses
  void _showSuccessMessage() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registrasi berhasil! Silakan periksa email Anda untuk verifikasi.',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// Navigasi ke halaman login
  void _navigateToLogin() {
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  /// Menangani error Firebase Auth
  void _handleAuthError(FirebaseAuthException e) {
    if (!mounted) return;

    String errorMessage;
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'Email sudah terdaftar';
        break;
      case 'weak-password':
        errorMessage = 'Password terlalu lemah';
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

  /// Widget persyaratan password
  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isValid ? Colors.green : Colors.red.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: isValid ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Icon(
              isValid ? Icons.check : Icons.close,
              color: isValid ? Colors.white : Colors.red,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget bagian form dengan judul dan ikon
  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.blue.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Dekorasi umum untuk input field
  InputDecoration _getInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
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
        borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
      suffixIcon: suffixIcon,
      prefixText: prefixText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Personal Information Section
          _buildFormSection('Informasi Pribadi', Icons.person, [
            // NIK Field
            TextFormField(
              controller: _nikController,
              decoration: _getInputDecoration(
                labelText: 'Nomor Induk Kependudukan (NIK)',
                hintText: 'Masukkan NIK (16 digit)',
                prefixIcon: Icons.credit_card,
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'NIK tidak boleh kosong';
                }
                if (value.length != 16) {
                  return 'NIK harus 16 digit';
                }
                if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'NIK hanya boleh berisi angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Nama Lengkap Field
            TextFormField(
              controller: _namaLengkapController,
              decoration: _getInputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Nama Lengkap sesuai KTP',
                prefixIcon: Icons.person_outline,
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

            // Nomor Telepon Field
            TextFormField(
              controller: _nomorTeleponController,
              decoration: _getInputDecoration(
                labelText: 'Nomor Telepon',
                hintText: 'Contoh: 08123456789',
                prefixIcon: Icons.phone,
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
          ]),

          // Work Information Section
          _buildFormSection('Informasi Pekerjaan', Icons.work, [
            // Jenis Pekerjaan Field
            TextFormField(
              controller: _jenisPekerjaanController,
              decoration: _getInputDecoration(
                labelText: 'Jenis Pekerjaan',
                hintText: 'Contoh: Karyawan, Wiraswasta, dll',
                prefixIcon: Icons.work_outline,
              ),
              keyboardType: TextInputType.text,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jenis Pekerjaan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Lokasi Field
            TextFormField(
              controller: _lokasiController,
              decoration: _getInputDecoration(
                labelText: 'Lokasi',
                hintText: 'Kota/Kabupaten tempat tinggal',
                prefixIcon: Icons.location_on,
              ),
              keyboardType: TextInputType.text,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Pendapatan Field
            TextFormField(
              controller: _pendapatanPerBulanController,
              decoration: _getInputDecoration(
                labelText: 'Pendapatan per Bulan',
                hintText: 'Masukkan dalam Rupiah (contoh: 5000000)',
                prefixIcon: Icons.attach_money,
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pendapatan Per Bulan tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan angka yang valid';
                }
                if (double.parse(value) < 0) {
                  return 'Pendapatan tidak boleh negatif';
                }
                return null;
              },
            ),
          ]),

          // Account Information Section
          _buildFormSection('Informasi Akun', Icons.account_circle, [
            // Email Field
            TextFormField(
              controller: _emailController,
              decoration: _getInputDecoration(
                labelText: 'Email',
                hintText: 'contoh@email.com',
                prefixIcon: Icons.email,
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Konfirmasi Email Field
            TextFormField(
              controller: _konfirmasiEmailController,
              decoration: _getInputDecoration(
                labelText: 'Konfirmasi Email',
                hintText: 'Masukkan email yang sama',
                prefixIcon: Icons.email_outlined,
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
          ]),

          // Password Section
          _buildFormSection('Kata Sandi', Icons.lock, [
            // Password Field
            TextFormField(
              controller: _kataSandiController,
              decoration: _getInputDecoration(
                labelText: 'Password',
                hintText: 'Masukkan Kata Sandi',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade600,
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
                if (!_isPasswordValid) {
                  return 'Password harus memenuhi semua persyaratan';
                }
                return null;
              },
            ),
            const SizedBox(height: 12.0),

            // Password requirements
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Persyaratan Password:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordRequirement(
                    'Minimal 8 karakter',
                    _hasMinLength,
                  ),
                  _buildPasswordRequirement(
                    'Mengandung huruf besar',
                    _hasUppercase,
                  ),
                  _buildPasswordRequirement(
                    'Mengandung huruf kecil',
                    _hasLowercase,
                  ),
                  _buildPasswordRequirement('Mengandung angka', _hasNumber),
                  _buildPasswordRequirement(
                    'Mengandung karakter khusus (!@#\$%^&*)',
                    _hasSpecialChar,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Konfirmasi Password Field
            TextFormField(
              controller: _konfirmasiKataSandiController,
              decoration: _getInputDecoration(
                labelText: 'Konfirmasi Kata Sandi',
                hintText: 'Masukkan kata sandi yang sama',
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey.shade600,
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
          ]),

          // Info Notice
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.blue.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Informasi Penting',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✓ Akun Anda akan langsung aktif setelah registrasi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✓ Dokumen KTP dapat diupload nanti melalui profil',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '✓ Verifikasi email diperlukan untuk keamanan akun',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32.0),

          // Register Button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Sedang Membuat Akun...'),
                        ],
                      )
                      : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add, size: 24),
                          SizedBox(width: 12),
                          Text('Buat Akun Saya'),
                        ],
                      ),
            ),
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
