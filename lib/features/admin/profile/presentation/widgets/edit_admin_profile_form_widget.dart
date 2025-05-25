import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'dart:io';
import '../../data/admin_profile_service.dart';
import '../../data/models/admin_profile_model.dart';

class AdminEditProfileFormWidget extends StatefulWidget {
  const AdminEditProfileFormWidget({super.key});

  @override
  State<AdminEditProfileFormWidget> createState() =>
      _AdminEditProfileFormWidgetState();
}

class _AdminEditProfileFormWidgetState
    extends State<AdminEditProfileFormWidget> {
  final AdminProfileService _profileService = AdminProfileService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();

  AdminProfileModel? _currentProfile;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _nomorTeleponController.dispose();
    _emailController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getCurrentAdminProfile();

      if (profile != null && mounted) {
        setState(() {
          _currentProfile = profile;
          _namaLengkapController.text = profile.fullName;
          _nomorTeleponController.text = profile.phoneNumber;
          _emailController.text = profile.email;
          _jabatanController.text = profile.position;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat profil admin';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _profileService.updateProfile(
        fullName: _namaLengkapController.text.trim(),
        phoneNumber: _nomorTeleponController.text.trim(),
        position: _jabatanController.text.trim(),
        profileImage: _selectedImage,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Perubahan data berhasil disimpan'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.go(RouteNames.adminProfile);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Gagal menyimpan perubahan'),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
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
          _isSaving = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text(
                'Memuat data profil...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCurrentProfile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header Section - SAMA SEPERTI UserEditProfile
            if (_currentProfile != null) ...[
              _buildFormSection(
                'Foto Profil Admin',
                Icons.account_circle_rounded,
                [
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade50,
                                backgroundImage:
                                    _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : _currentProfile?.profilePictureUrl !=
                                            null
                                        ? NetworkImage(
                                          _currentProfile!.profilePictureUrl!,
                                        )
                                        : null,
                                child:
                                    _selectedImage == null &&
                                            _currentProfile
                                                    ?.profilePictureUrl ==
                                                null
                                        ? Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                          color: Colors.blue.shade400,
                                        )
                                        : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_selectedImage != null ||
                            _currentProfile?.profilePictureUrl != null)
                          TextButton.icon(
                            onPressed: _removeImage,
                            icon: Icon(
                              Icons.delete_rounded,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
                            label: Text(
                              'Hapus Foto',
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'ID: ${_currentProfile?.id ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Role: ${_currentProfile?.role ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Personal Information Section - SAMA SEPERTI UserEditProfile
            _buildFormSection('Informasi Pribadi', Icons.person_rounded, [
              TextFormField(
                controller: _namaLengkapController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap admin',
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
                    Icons.person_outline_rounded,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama lengkap minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _nomorTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Contoh: +62812345678',
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
                    Icons.phone_rounded,
                    color: Colors.grey.shade600,
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Nomor telepon minimal 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'admin@sociocare.com',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  prefixIcon: Icon(
                    Icons.email_rounded,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: Icon(
                    Icons.lock_rounded,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ),
                enabled: false,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Email tidak dapat diubah demi keamanan akun',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            // Work Information Section - SAMA SEPERTI UserEditProfile
            _buildFormSection('Informasi Jabatan', Icons.work_rounded, [
              TextFormField(
                controller: _jabatanController,
                decoration: InputDecoration(
                  labelText: 'Jabatan',
                  hintText: 'Contoh: Administrator, Manager, dll',
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
                    Icons.work_outline_rounded,
                    color: Colors.grey.shade600,
                  ),
                ),
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jabatan tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ]),

            // Change Password Section
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
                                'Ubah Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                'Perbarui password untuk keamanan akun',
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
                        onPressed: _isSaving ? null : _showChangePasswordDialog,
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

            // Action Buttons - SAMA SEPERTI UserEditProfile
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
                onPressed: _isSaving ? null : _saveChanges,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Menyimpan...' : 'Simpan Perubahan'),
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
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Cancel Button
            OutlinedButton.icon(
              onPressed:
                  _isSaving
                      ? null
                      : () {
                        _showExitConfirmation();
                      },
              icon: const Icon(Icons.close_rounded),
              label: const Text('Batal'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Konfirmasi Keluar'),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar? Perubahan yang belum disimpan akan hilang.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Tetap Edit',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go(RouteNames.adminProfile);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade700,
                                  ),
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
                                    const SnackBar(
                                      content: Text(
                                        'Password baru minimal 6 karakter',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (newPasswordController.text !=
                                    confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Konfirmasi password tidak cocok',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setDialogState(() {
                                  isChangingPassword = true;
                                });

                                try {
                                  final success = await _profileService
                                      .changePassword(
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
                                            Text(
                                              'Gagal mengubah password. Periksa password saat ini.',
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
}
