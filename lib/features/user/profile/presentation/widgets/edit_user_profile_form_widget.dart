import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

/// Widget form untuk mengedit profil pengguna
class EditUserProfileFormWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditUserProfileFormWidget({super.key, this.initialData});

  @override
  State<EditUserProfileFormWidget> createState() =>
      _EditUserProfileFormWidgetState();
}

class _EditUserProfileFormWidgetState extends State<EditUserProfileFormWidget> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pendapatanPerBulanController =
      TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  // UI constants
  static const double _spacing = 16.0;
  static const double _borderRadius = 16.0;
  static const double _fieldRadius = 10.0;
  static const double _buttonRadius = 12.0;
  static const double _sectionSpacing = 24.0;
  static const double _iconSize = 20.0;

  // State
  bool _isLoading = false;
  bool _isChangingPassword =
      false; // Added class-level variable for password change state
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeData();
  }

  /// Mengisi form dengan data awal
  void _initializeData() {
    if (widget.initialData != null) {
      _namaLengkapController.text = widget.initialData!['fullName'] ?? '';
      _nomorTeleponController.text = widget.initialData!['phoneNumber'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _pendapatanPerBulanController.text =
          widget.initialData!['monthlyIncome']?.toString() ?? '';

      // Support both new and old field names
      _jenisPekerjaanController.text =
          widget.initialData!['occupation'] ??
          widget.initialData!['jobType'] ??
          '';
      _lokasiController.text =
          widget.initialData!['address'] ??
          widget.initialData!['location'] ??
          '';
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _pendapatanPerBulanController.dispose();
    _jenisPekerjaanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  /// Menyimpan perubahan data pengguna
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUser == null) {
      _showErrorSnackBar('User tidak ditemukan');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email is being changed
      final newEmail = _emailController.text.trim();
      final oldEmail = widget.initialData?['email'] ?? '';

      // Prepare update data
      final updateData = _prepareUpdateData(newEmail);

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      // Update Firebase Auth display name
      await _currentUser!.updateDisplayName(_namaLengkapController.text.trim());

      // Update email if changed
      if (newEmail != oldEmail) {
        await _updateEmail(newEmail, oldEmail);
      }

      if (mounted) {
        _showSuccessSnackBar('Data berhasil diperbarui');
        context.pop();
      }
    } catch (e) {
      _handleSaveError(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menyiapkan data untuk update ke Firestore
  Map<String, dynamic> _prepareUpdateData(String newEmail) {
    return {
      'fullName': _namaLengkapController.text.trim(),
      'phoneNumber': _nomorTeleponController.text.trim(),
      'email': newEmail,
      'monthlyIncome':
          double.tryParse(_pendapatanPerBulanController.text.trim()) ?? 0,

      // New field names (admin compatible)
      'occupation': _jenisPekerjaanController.text.trim(),
      'address': _lokasiController.text.trim(),

      // Old field names (backward compatibility)
      'jobType': _jenisPekerjaanController.text.trim(),
      'location': _lokasiController.text.trim(),

      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Memperbarui email pengguna
  Future<void> _updateEmail(String newEmail, String oldEmail) async {
    try {
      await _currentUser!.updateEmail(newEmail);
      await _currentUser!.sendEmailVerification();

      if (mounted) {
        _showWarningSnackBar(
          'Email berhasil diubah. Silakan verifikasi email baru Anda.',
        );
      }
    } catch (e) {
      // If email update fails, revert the email in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({'email': oldEmail});

      throw Exception('Gagal mengubah email: ${e.toString()}');
    }
  }

  /// Menangani error saat menyimpan data
  void _handleSaveError(dynamic e) {
    if (!mounted) return;

    String errorMessage = 'Gagal menyimpan perubahan';

    if (e.toString().contains('requires-recent-login')) {
      errorMessage = 'Silakan login ulang untuk mengubah email';
    } else if (e.toString().contains('email-already-in-use')) {
      errorMessage = 'Email sudah digunakan akun lain';
    } else if (e.toString().contains('invalid-email')) {
      errorMessage = 'Format email tidak valid';
    }

    _showErrorSnackBar(errorMessage);
  }

  /// Method untuk mengubah password
  Future<bool> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUser == null) return false;

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: _currentUser!.email!,
        password: currentPassword,
      );

      await _currentUser!.reauthenticateWithCredential(credential);
      await _currentUser!.updatePassword(newPassword);
      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  /// Membangun bagian form dengan judul dan ikon
  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: _sectionSpacing),
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                child: Icon(icon, color: Colors.blue.shade700, size: _iconSize),
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
          const SizedBox(height: _spacing),
          ...children,
        ],
      ),
    );
  }

  /// Membuat input field untuk form
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
        prefixText: prefixText,
      ),
      keyboardType: keyboardType,
      enabled: !_isLoading,
      validator: validator,
    );
  }

  /// Membangun field password untuk dialog
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_fieldRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }

  /// Menampilkan dialog ubah password
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    // Reset password change state
    setState(() {
      _isChangingPassword = false;
    });

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_borderRadius),
                  ),
                  title: _buildDialogTitle(),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPasswordField(
                          controller: currentPasswordController,
                          labelText: 'Password Saat Ini',
                          hintText: 'Masukkan password lama',
                          isObscure: obscureCurrentPassword,
                          onToggleVisibility: () {
                            setDialogState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                        ),
                        const SizedBox(height: _spacing),
                        _buildPasswordField(
                          controller: newPasswordController,
                          labelText: 'Password Baru',
                          hintText: 'Minimal 6 karakter',
                          isObscure: obscureNewPassword,
                          onToggleVisibility: () {
                            setDialogState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                        ),
                        const SizedBox(height: _spacing),
                        _buildPasswordField(
                          controller: confirmPasswordController,
                          labelText: 'Konfirmasi Password Baru',
                          hintText: 'Ulangi password baru',
                          isObscure: obscureConfirmPassword,
                          onToggleVisibility: () {
                            setDialogState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: _spacing),
                        _buildPasswordInfo(),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          _isChangingPassword
                              ? null
                              : () => Navigator.of(context).pop(),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _isChangingPassword
                              ? null
                              : () => _processPasswordChange(
                                context,
                                setDialogState,
                                currentPasswordController,
                                newPasswordController,
                                confirmPasswordController,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isChangingPassword
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Ubah Password'),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Membangun title dialog ubah password
  Widget _buildDialogTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.lock_rounded,
            color: Colors.blue.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Text('Ubah Password'),
      ],
    );
  }

  /// Membangun informasi password
  Widget _buildPasswordInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: Colors.blue.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Password harus minimal 6 karakter dan mengandung kombinasi huruf dan angka.',
              style: TextStyle(color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Proses perubahan password
  Future<void> _processPasswordChange(
    BuildContext context,
    StateSetter setDialogState,
    TextEditingController currentPasswordController,
    TextEditingController newPasswordController,
    TextEditingController confirmPasswordController,
  ) async {
    // Validasi input
    if (newPasswordController.text.trim().length < 6) {
      _showErrorSnackBar('Password minimal 6 karakter');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showErrorSnackBar('Konfirmasi password tidak cocok');
      return;
    }

    // Update state using the class variable through setDialogState
    setDialogState(() {
      _isChangingPassword = true;
    });

    try {
      final success = await _changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar('Password berhasil diubah');
      } else if (mounted) {
        _showErrorSnackBar('Gagal mengubah password');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        // Reset state using the class variable through setDialogState
        setDialogState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  /// Menampilkan snackbar sukses
  void _showSuccessSnackBar(String message) {
    _showSnackBar(
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
    );
  }

  /// Menampilkan snackbar error
  void _showErrorSnackBar(String message) {
    _showSnackBar(
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade600,
    );
  }

  /// Menampilkan snackbar warning
  void _showWarningSnackBar(String message) {
    _showSnackBar(
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade600,
    );
  }

  /// Menampilkan snackbar dengan kustomisasi
  void _showSnackBar({
    required String message,
    required IconData icon,
    required Color backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Personal Information Section
            _buildFormSection('Informasi Pribadi', Icons.person, [
              _buildInputField(
                controller: _namaLengkapController,
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap Anda',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama lengkap minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: _spacing),
              _buildInputField(
                controller: _nomorTeleponController,
                labelText: 'Nomor Telepon',
                hintText: 'Contoh: 08123456789',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  if (!value.startsWith('08') || value.length < 10) {
                    return 'Masukkan nomor telepon yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: _spacing),
              _buildInputField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'contoh@email.com',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
            ]),

            // Work Information Section
            _buildFormSection('Informasi Pekerjaan', Icons.work, [
              _buildInputField(
                controller: _jenisPekerjaanController,
                labelText: 'Jenis Pekerjaan',
                hintText: 'Contoh: Karyawan, Wiraswasta, dll',
                prefixIcon: Icons.work_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jenis pekerjaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: _spacing),
              _buildInputField(
                controller: _lokasiController,
                labelText: 'Lokasi',
                hintText: 'Kota/Kabupaten tempat tinggal',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: _spacing),
              _buildInputField(
                controller: _pendapatanPerBulanController,
                labelText: 'Pendapatan Per Bulan',
                hintText: 'Masukkan dalam Rupiah (contoh: 5000000)',
                prefixIcon: Icons.attach_money,
                prefixText: 'Rp ',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pendapatan per bulan tidak boleh kosong';
                  }
                  final amount = double.tryParse(value.trim());
                  if (amount == null) {
                    return 'Masukkan angka yang valid';
                  }
                  if (amount < 0) {
                    return 'Pendapatan tidak boleh negatif';
                  }
                  return null;
                },
              ),
            ]),

            // Security Section
            _buildFormSection('Keamanan Akun', Icons.security_rounded, [
              _buildSecuritySection(),
            ]),

            // Warning Notice
            _buildWarningNotice(),
            const SizedBox(height: _sectionSpacing),

            // Save Button
            _buildSaveButton(),
            const SizedBox(height: _sectionSpacing),
          ],
        ),
      ),
    );
  }

  /// Membangun bagian keamanan
  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.lock_rounded, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keamanan Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Ubah password secara berkala untuk keamanan akun',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _showChangePasswordDialog,
              icon: const Icon(Icons.key_rounded),
              label: const Text('Ubah Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun peringatan
  Widget _buildWarningNotice() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perhatian',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jika Anda mengubah email, verifikasi ulang akan diperlukan.',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol simpan
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveChanges,
        icon:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.save),
        label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0066CC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
