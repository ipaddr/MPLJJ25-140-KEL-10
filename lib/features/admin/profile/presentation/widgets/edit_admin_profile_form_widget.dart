import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'dart:io';
import '../../data/admin_profile_service.dart';
import '../../data/models/admin_profile_model.dart';

/// Widget form untuk mengedit profil administrator
///
/// Menyediakan antarmuka untuk mengubah nama lengkap, nomor telepon,
/// jabatan, dan foto profil administrator
class AdminEditProfileFormWidget extends StatefulWidget {
  const AdminEditProfileFormWidget({super.key});

  @override
  State<AdminEditProfileFormWidget> createState() =>
      _AdminEditProfileFormWidgetState();
}

class _AdminEditProfileFormWidgetState
    extends State<AdminEditProfileFormWidget> {
  // Services & Controllers
  final AdminProfileService _profileService = AdminProfileService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();

  // State variables
  AdminProfileModel? _currentProfile;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChangingPassword =
      false; // Added class-level variable for password change state
  String? _errorMessage;

  // UI Constants
  static const double _spacing = 16.0;
  static const double _largeSpacing = 24.0;
  static const double _mediumSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _miniSpacing = 4.0;

  static const double _borderRadius = 16.0;
  static const double _mediumBorderRadius = 12.0;
  static const double _smallBorderRadius = 10.0;
  static const double _microBorderRadius = 8.0;

  static const double _textSizeLarge = 18.0;
  static const double _textSizeMedium = 16.0;
  static const double _textSizeSmall = 14.0;
  static const double _textSizeMicro = 12.0;
  static const double _textSizeTiny = 11.0;

  static const double _iconSizeMedium = 24.0;
  static const double _iconSizeSmall = 20.0;
  static const double _iconSizeTiny = 16.0;

  static const double _avatarRadius = 50.0;
  static const double _avatarIconSize = 50.0;

  static const double _buttonHeight = 16.0;

  static const Color _primaryColor = Color(0xFF0066CC);

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

  /// Memuat data profil admin saat ini dari service
  Future<void> _loadCurrentProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getCurrentAdminProfile();

      if (!mounted) return;

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
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Memilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Menghapus gambar yang dipilih
  void _removeImage() {
    if (!mounted) return;

    setState(() {
      _selectedImage = null;
    });
  }

  /// Menyimpan perubahan data profil admin
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

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

      if (!mounted) return;

      if (success) {
        _showSnackBar(
          'Perubahan data berhasil disimpan',
          Icons.check_circle,
          Colors.green.shade600,
        );
        context.go(RouteNames.adminProfile);
      } else {
        _showSnackBar(
          'Gagal menyimpan perubahan',
          Icons.error_outline,
          Colors.red.shade600,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Error: ${e.toString()}',
        Icons.error_outline,
        Colors.red.shade600,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Menampilkan snackbar dengan pesan dan ikon
  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: _microSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
      ),
    );
  }

  /// Menampilkan dialog konfirmasi keluar dari halaman edit
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            title: Row(
              children: [
                _buildDialogHeaderIcon(Icons.warning_rounded, Colors.orange),
                const SizedBox(width: _smallSpacing),
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
                    borderRadius: BorderRadius.circular(_microBorderRadius),
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }

  /// Menampilkan dialog untuk mengubah password
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
                  title: Row(
                    children: [
                      _buildDialogHeaderIcon(Icons.lock_rounded, Colors.blue),
                      const SizedBox(width: _smallSpacing),
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

                        _buildInfoBox(
                          'Password harus minimal 6 karakter dan mengandung kombinasi huruf dan angka.',
                          Colors.blue,
                        ),
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
                                setDialogState,
                                currentPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            _microBorderRadius,
                          ),
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

  /// Memproses perubahan password dari dialog
  Future<void> _processPasswordChange(
    StateSetter setDialogState,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    // Validasi password baru
    if (newPassword.trim().length < 6) {
      _showSnackBar(
        'Password baru minimal 6 karakter',
        Icons.error_outline,
        Colors.red.shade600,
      );
      return;
    }

    // Validasi konfirmasi password
    if (newPassword != confirmPassword) {
      _showSnackBar(
        'Konfirmasi password tidak cocok',
        Icons.error_outline,
        Colors.red.shade600,
      );
      return;
    }

    // Set status loading
    setDialogState(() => _isChangingPassword = true);

    try {
      final success = await _profileService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        _showSnackBar(
          'Password berhasil diubah',
          Icons.check_circle,
          Colors.green.shade600,
        );
      } else {
        _showSnackBar(
          'Gagal mengubah password. Periksa password saat ini.',
          Icons.error_outline,
          Colors.red.shade600,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Error: ${e.toString()}',
        Icons.error_outline,
        Colors.red.shade600,
      );
    } finally {
      if (mounted) {
        setDialogState(() => _isChangingPassword = false);
      }
    }
  }

  /// Membangun ikon header untuk dialog
  Widget _buildDialogHeaderIcon(IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: color.shade100,
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Icon(icon, color: color.shade600, size: _iconSizeMedium),
    );
  }

  /// Membangun field untuk input password dengan toggle visibilitas
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
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
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

  /// Membangun seksi form dengan judul dan ikon
  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: _largeSpacing),
      padding: const EdgeInsets.all(_largeSpacing),
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
                padding: const EdgeInsets.all(_microSpacing),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(_microBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: _iconSizeSmall,
                ),
              ),
              const SizedBox(width: _smallSpacing),
              Text(
                title,
                style: TextStyle(
                  fontSize: _textSizeMedium,
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

  /// Membangun kotak info dengan warna dan ikon
  Widget _buildInfoBox(String message, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_rounded, color: color.shade600, size: _iconSizeTiny),
          const SizedBox(width: _microSpacing),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: _textSizeTiny,
                color: color.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun field input teks dengan styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600),
        suffixIcon:
            readOnly
                ? Icon(
                  Icons.lock_rounded,
                  color: Colors.grey.shade500,
                  size: 20,
                )
                : null,
      ),
      enabled: enabled && !readOnly,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  /// Membangun seksi foto profil
  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(children: [_buildProfilePhotoCircle(), _buildCameraButton()]),
          const SizedBox(height: _spacing),

          if (_hasProfilePhoto())
            TextButton.icon(
              onPressed: _removeImage,
              icon: Icon(
                Icons.delete_rounded,
                color: Colors.red.shade600,
                size: _iconSizeTiny,
              ),
              label: Text(
                'Hapus Foto',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: _textSizeMicro,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const SizedBox(height: _smallSpacing),
          _buildProfileInfo(),
        ],
      ),
    );
  }

  /// Mengecek apakah ada foto profil (yang dipilih atau yang ada)
  bool _hasProfilePhoto() {
    return _selectedImage != null || _currentProfile?.profilePictureUrl != null;
  }

  /// Membangun lingkaran foto profil
  Widget _buildProfilePhotoCircle() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue.shade200, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: Colors.grey.shade50,
        backgroundImage: _getProfileImage(),
        child:
            _hasProfilePhoto()
                ? null
                : Icon(
                  Icons.person_rounded,
                  size: _avatarIconSize,
                  color: Colors.blue.shade400,
                ),
      ),
    );
  }

  /// Mendapatkan image provider untuk foto profil
  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_currentProfile?.profilePictureUrl != null) {
      return NetworkImage(_currentProfile!.profilePictureUrl!);
    }
    return null;
  }

  /// Membangun tombol kamera untuk mengambil foto
  Widget _buildCameraButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
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
    );
  }

  /// Membangun informasi profil (ID dan role)
  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Column(
        children: [
          Text(
            'ID: ${_currentProfile?.id ?? 'N/A'}',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: _textSizeMicro,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: _miniSpacing),
          Text(
            'Role: ${_currentProfile?.getRoleDisplayName() ?? 'N/A'}',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: _textSizeMicro,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun seksi informasi pribadi
  Widget _buildPersonalInfoSection() {
    return _buildFormSection('Informasi Pribadi', Icons.person_rounded, [
      _buildTextField(
        controller: _namaLengkapController,
        labelText: 'Nama Lengkap',
        hintText: 'Masukkan nama lengkap admin',
        prefixIcon: Icons.person_outline_rounded,
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
      const SizedBox(height: _spacing),

      _buildTextField(
        controller: _nomorTeleponController,
        labelText: 'Nomor Telepon',
        hintText: 'Contoh: +62812345678',
        prefixIcon: Icons.phone_rounded,
        enabled: !_isSaving,
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
      const SizedBox(height: _spacing),

      _buildTextField(
        controller: _emailController,
        labelText: 'Email',
        hintText: 'admin@sociocare.com',
        prefixIcon: Icons.email_rounded,
        readOnly: true,
      ),
      const SizedBox(height: _microSpacing),

      _buildInfoBox(
        'Email tidak dapat diubah demi keamanan akun',
        Colors.orange,
      ),
    ]);
  }

  /// Membangun seksi informasi jabatan
  Widget _buildPositionInfoSection() {
    return _buildFormSection('Informasi Jabatan', Icons.work_rounded, [
      _buildTextField(
        controller: _jabatanController,
        labelText: 'Jabatan',
        hintText: 'Contoh: Administrator, Manager, dll',
        prefixIcon: Icons.work_outline_rounded,
        enabled: !_isSaving,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Jabatan tidak boleh kosong';
          }
          return null;
        },
      ),
    ]);
  }

  /// Membangun seksi keamanan akun
  Widget _buildSecuritySection() {
    return _buildFormSection('Keamanan Akun', Icons.security_rounded, [
      Container(
        padding: const EdgeInsets.all(_spacing),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  color: Colors.blue.shade600,
                  size: _iconSizeMedium,
                ),
                const SizedBox(width: _smallSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: _textSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'Perbarui password untuk keamanan akun',
                        style: TextStyle(
                          fontSize: _textSizeMicro,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _smallSpacing),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _showChangePasswordDialog,
                icon: const Icon(Icons.key_rounded),
                label: const Text('Ubah Password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade700,
                  side: BorderSide(color: Colors.blue.shade300),
                  padding: const EdgeInsets.symmetric(vertical: _smallSpacing),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_microBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  /// Membangun tombol aksi (simpan dan batal)
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_mediumBorderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
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
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: _buttonHeight,
                horizontal: _largeSpacing,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_mediumBorderRadius),
              ),
              textStyle: const TextStyle(
                fontSize: _textSizeMedium,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: _spacing),

        // Cancel Button
        OutlinedButton.icon(
          onPressed: _isSaving ? null : _showExitConfirmation,
          icon: const Icon(Icons.close_rounded),
          label: const Text('Batal'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade700,
            side: BorderSide(color: Colors.grey.shade400),
            padding: const EdgeInsets.symmetric(vertical: _buttonHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_mediumBorderRadius),
            ),
            textStyle: const TextStyle(
              fontSize: _textSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(_spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Photo Section
            if (_currentProfile != null)
              _buildFormSection(
                'Foto Profil Admin',
                Icons.account_circle_rounded,
                [_buildProfilePhotoSection()],
              ),

            // Personal Information Section
            _buildPersonalInfoSection(),

            // Position Information Section
            _buildPositionInfoSection(),

            // Security Section
            _buildSecuritySection(),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: _largeSpacing),
          ],
        ),
      ),
    );
  }

  /// Membangun widget tampilan loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue.shade600),
            const SizedBox(height: _spacing),
            Text(
              'Memuat data profil...',
              style: TextStyle(
                fontSize: _textSizeMedium,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun widget tampilan error
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(_largeSpacing),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(_spacing),
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
            const SizedBox(height: _spacing),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: _textSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _microSpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: _textSizeSmall,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _largeSpacing),
            ElevatedButton.icon(
              onPressed: _loadCurrentProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_mediumBorderRadius),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
