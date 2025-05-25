import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class EditUserProfileFormWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const EditUserProfileFormWidget({super.key, this.initialData});

  @override
  State<EditUserProfileFormWidget> createState() =>
      _EditUserProfileFormWidgetState();
}

class _EditUserProfileFormWidgetState extends State<EditUserProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pendapatanPerBulanController =
      TextEditingController();
  final TextEditingController _jenisPekerjaanController =
      TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeData();
  }

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
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _pendapatanPerBulanController.dispose();
    _jenisPekerjaanController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('User tidak ditemukan'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email is being changed
      final newEmail = _emailController.text.trim();
      final oldEmail = widget.initialData?['email'] ?? '';

      // Prepare update data with both new and old field names for compatibility
      final updateData = {
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

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      // Update Firebase Auth display name
      await _currentUser!.updateDisplayName(_namaLengkapController.text.trim());

      // Update email if changed
      if (newEmail != oldEmail) {
        try {
          await _currentUser!.updateEmail(newEmail);

          // Send verification email for new email
          await _currentUser!.sendEmailVerification();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Email berhasil diubah. Silakan verifikasi email baru Anda.',
                    ),
                  ],
                ),
                backgroundColor: Colors.orange.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 5),
              ),
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Data berhasil diperbarui'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Go back to profile page
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Gagal menyimpan perubahan';

        if (e.toString().contains('requires-recent-login')) {
          errorMessage = 'Silakan login ulang untuk mengubah email';
        } else if (e.toString().contains('email-already-in-use')) {
          errorMessage = 'Email sudah digunakan akun lain';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Format email tidak valid';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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

  // Method untuk mengubah password (unchanged)
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

      // Update password
      await _currentUser!.updatePassword(newPassword);

      return true;
    } catch (e) {
      print('Error changing password: $e');
      return false;
    }
  }

  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isChangingPassword = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
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
                  ),
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: Colors.blue.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Password harus minimal 6 karakter dan mengandung kombinasi huruf dan angka.',
                                  style: TextStyle(color: Colors.blue.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isChangingPassword
                              ? null
                              : () => Navigator.of(context).pop(),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          isChangingPassword
                              ? null
                              : () async {
                                if (newPasswordController.text.trim().length <
                                    6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Password minimal 6 karakter'),
                                        ],
                                      ),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (newPasswordController.text !=
                                    confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Konfirmasi password tidak cocok',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.red.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  isChangingPassword = true;
                                });

                                try {
                                  final success = await _changePassword(
                                    currentPassword:
                                        currentPasswordController.text,
                                    newPassword: newPasswordController.text,
                                  );

                                  if (success && mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Password berhasil diubah'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Gagal mengubah password'),
                                          ],
                                        ),
                                        backgroundColor: Colors.red.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Error: ${e.toString()}',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.red.shade600,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setDialogState(() {
                                      isChangingPassword = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isChangingPassword
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Personal Information Section
            _buildFormSection('Informasi Pribadi', Icons.person, [
              TextFormField(
                controller: _namaLengkapController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabled: !_isLoading,
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _nomorTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Contoh: 08123456789',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(Icons.phone, color: Colors.grey.shade600),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
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
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'contoh@email.com',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
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
              TextFormField(
                controller: _jenisPekerjaanController,
                decoration: InputDecoration(
                  labelText: 'Jenis Pekerjaan',
                  hintText: 'Contoh: Karyawan, Wiraswasta, dll',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.work_outline,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jenis pekerjaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  hintText: 'Kota/Kabupaten tempat tinggal',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.location_on,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _pendapatanPerBulanController,
                decoration: InputDecoration(
                  labelText: 'Pendapatan Per Bulan',
                  hintText: 'Masukkan dalam Rupiah (contoh: 5000000)',
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
                    borderSide: BorderSide(
                      color: Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.grey.shade600,
                  ),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: Colors.blue.shade600,
                          size: 24,
                        ),
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
                        onPressed:
                            _isLoading ? null : _showChangePasswordDialog,
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
              ),
            ]),

            // Warning Notice
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange.shade700,
                    size: 24,
                  ),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Save Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
