import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/admin_profile_service.dart';
import '../../data/models/admin_profile_model.dart';

class AdminEditProfileFormWidget extends StatefulWidget {
  const AdminEditProfileFormWidget({super.key});

  @override
  State<AdminEditProfileFormWidget> createState() => _AdminEditProfileFormWidgetState();
}

class _AdminEditProfileFormWidgetState extends State<AdminEditProfileFormWidget> {
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
      
      if (profile != null) {
        setState(() {
          _currentProfile = profile;
          _namaLengkapController.text = profile.fullName;
          _nomorTeleponController.text = profile.phoneNumber;
          _emailController.text = profile.email;
          _jabatanController.text = profile.position;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat profil admin';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
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
    if (_formKey.currentState!.validate()) {
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

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perubahan data berhasil disimpan')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan perubahan')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCurrentProfile,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue.shade100,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : _currentProfile?.profilePictureUrl != null
                                ? NetworkImage(_currentProfile!.profilePictureUrl!)
                                : null,
                        child: _selectedImage == null && _currentProfile?.profilePictureUrl == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blue.shade700,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImage != null || _currentProfile?.profilePictureUrl != null)
                    TextButton(
                      onPressed: _removeImage,
                      child: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            TextFormField(
              controller: _namaLengkapController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap Anda',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Nomor Telepon',
                hintText: 'Masukkan nomor telepon Anda',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
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
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Email tidak dapat diubah',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              enabled: false, // Email cannot be changed
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16.0),

            TextFormField(
              controller: _jabatanController,
              decoration: const InputDecoration(
                labelText: 'Jabatan',
                hintText: 'Masukkan jabatan Anda',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Jabatan tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24.0),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Perubahan'),
            ),

            const SizedBox(height: 16.0),

            // Change Password Button
            OutlinedButton(
              onPressed: () {
                _showChangePasswordDialog();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
                side: const BorderSide(color: Colors.blue, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              child: const Text('Ubah Password'),
            ),
          ],
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

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ubah Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: obscureCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setDialogState(() {
                        obscureCurrentPassword = !obscureCurrentPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setDialogState(() {
                        obscureNewPassword = !obscureNewPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setDialogState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text.trim().length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password baru minimal 6 karakter')),
                  );
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Konfirmasi password tidak cocok')),
                  );
                  return;
                }

                try {
                  final success = await _profileService.changePassword(
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );

                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password berhasil diubah')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mengubah password. Periksa password saat ini.')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Ubah Password'),
            ),
          ],
        ),
      ),
    );
  }
}