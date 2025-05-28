import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../../data/admin_user_service.dart';
import 'package:intl/intl.dart';

/// Page for editing user information by admin
///
/// Allows admins to update user personal information, role, and status
class AdminEditUserPage extends StatefulWidget {
  final String userId;

  const AdminEditUserPage({super.key, required this.userId});

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage>
    with TickerProviderStateMixin {
  // UI Constants
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _miniSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _microTinySpacing = 4.0;
  static const double _borderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 10.0;
  static const double _miniBorderRadius = 8.0;

  static const double _titleFontSize = 22.0;
  static const double _subtitleFontSize = 18.0;
  static const double _bodyFontSize = 16.0;
  static const double _smallFontSize = 14.0;
  static const double _captionFontSize = 12.0;

  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;

  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Services
  final AdminUserService _userService = AdminUserService();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedRole;
  String? _selectedStatus;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Options
  final List<String> _roles = ['user', 'admin'];
  final List<String> _statuses = ['active', 'inactive', 'suspended'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Load user data from the service
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await _userService.getUserById(widget.userId);

      if (userData != null && mounted) {
        setState(() {
          _userData = userData;
          _nameController.text = userData['fullName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phoneNumber'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _selectedRole = userData['role'] ?? 'user';
          _selectedStatus = userData['status'] ?? 'active';
          _isLoading = false;
        });

        _fadeController.forward();
        _slideController.forward();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'User tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data user: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Update user data with form values
  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _userService.updateUser(
        userId: widget.userId,
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        role: _selectedRole!,
        status: _selectedStatus!,
      );

      if (mounted) {
        if (success) {
          _showSuccessSnackBar('User berhasil diperbarui');
          context.go(RouteNames.adminUserList);
        } else {
          _showErrorSnackBar('Gagal memperbarui user');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Show a success message in a snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: _miniSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_miniBorderRadius),
        ),
      ),
    );
  }

  /// Show an error message in a snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: _miniSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_miniBorderRadius),
        ),
      ),
    );
  }

  /// Get display name for role
  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'user':
        return 'User';
      default:
        return role;
    }
  }

  /// Get display name for status
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'suspended':
        return 'Ditangguhkan';
      default:
        return status;
    }
  }

  /// Get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingWidget()
                        : _errorMessage != null
                        ? _buildErrorWidget()
                        : _buildEditUserContent(),
              ),
            ],
          ),
        ),
      ),
      drawer: const AdminNavigationDrawer(),
    );
  }

  /// Build the custom app bar
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      child: Row(
        children: [
          // Menu Button
          _buildAppBarButton(
            icon: Icons.menu_rounded,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: _smallSpacing),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola data pengguna sistem',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _smallFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          _buildAppBarButton(
            icon: Icons.refresh_rounded,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _loadUserData,
          ),
        ],
      ),
    );
  }

  /// Build a button for the app bar
  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon:
            isLoading
                ? const SizedBox(
                  width: _iconSize - 4,
                  height: _iconSize - 4,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Icon(icon, color: Colors.white, size: _iconSize),
        onPressed: onPressed,
      ),
    );
  }

  /// Build the loading widget
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(_spacing),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: _smallSpacing),
            Text(
              'Memuat data user...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: _bodyFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the error widget
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(_spacing),
        padding: const EdgeInsets.all(_spacing),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_midSpacing),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(_smallSpacing),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: _smallSpacing),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _miniSpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: _smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _spacing),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadUserData,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_smallBorderRadius),
                    ),
                  ),
                ),
                const SizedBox(width: _microSpacing),
                OutlinedButton.icon(
                  onPressed: () => context.go(RouteNames.adminUserList),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Kembali'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_smallBorderRadius),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the main form content
  Widget _buildEditUserContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_spacing),
              topRight: Radius.circular(_spacing),
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(_smallSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info Header
                  if (_userData != null) _buildUserInfoHeader(),

                  // Personal Information Section
                  _buildFormSection('Informasi Pribadi', Icons.person_rounded, [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap user',
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap tidak boleh kosong';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: _smallSpacing),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Masukkan alamat email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: _smallSpacing),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Nomor Telepon',
                      hint: 'Contoh: +62812345678',
                      icon: Icons.phone_rounded,
                      keyboardType: TextInputType.phone,
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
                    const SizedBox(height: _smallSpacing),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Alamat',
                      hint: 'Masukkan alamat lengkap',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ]),

                  // Role & Status Section
                  _buildFormSection(
                    'Role & Status User',
                    Icons.admin_panel_settings_rounded,
                    [
                      Row(
                        children: [
                          // Role Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Role',
                              icon: Icons.security_rounded,
                              value: _selectedRole,
                              items:
                                  _roles
                                      .map(
                                        (role) => DropdownMenuItem<String>(
                                          value: role,
                                          child: Text(
                                            _getRoleDisplayName(role),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih role user';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: _smallSpacing),
                          // Status Dropdown
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Status',
                              icon: Icons.toggle_on_rounded,
                              value: _selectedStatus,
                              items:
                                  _statuses
                                      .map(
                                        (status) => DropdownMenuItem<String>(
                                          value: status,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _getStatusColor(
                                                    status,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: _miniSpacing,
                                              ),
                                              Text(
                                                _getStatusDisplayName(status),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pilih status user';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons
                  _buildSaveButton(),

                  const SizedBox(height: _smallSpacing),

                  // Cancel Button
                  _buildCancelButton(),

                  const SizedBox(height: _spacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the user info header card
  Widget _buildUserInfoHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacing),
      padding: const EdgeInsets.all(_midSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(_smallBorderRadius),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: _iconSize,
                ),
              ),
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi User',
                      style: TextStyle(
                        fontSize: _subtitleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Data lengkap user yang akan diedit',
                      style: TextStyle(
                        fontSize: _smallFontSize,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          Container(
            padding: const EdgeInsets.all(_smallSpacing),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  'User ID',
                  widget.userId,
                  Icons.fingerprint_rounded,
                ),
                _buildInfoRow(
                  'Dibuat',
                  _formatDate(_userData!['createdAt']?.toDate()),
                  Icons.calendar_today_rounded,
                ),
                _buildInfoRow(
                  'Login Terakhir',
                  _formatDate(_userData!['lastLogin']?.toDate()),
                  Icons.access_time_rounded,
                ),
                _buildInfoRow(
                  'Status Saat Ini',
                  _getStatusDisplayName(_selectedStatus ?? 'active'),
                  Icons.info_rounded,
                  statusColor: _getStatusColor(_selectedStatus ?? 'active'),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a text field with consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isSaving,
      validator: validator,
    );
  }

  /// Build a dropdown field with consistent styling
  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String? Function(T?) validator,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
      ),
      value: value,
      items: items,
      onChanged: _isSaving ? null : onChanged,
      validator: validator,
    );
  }

  /// Build an info row for the user header
  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : _microSpacing),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: _microIconSize,
          ),
          const SizedBox(width: _microSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: _captionFontSize,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: _microTinySpacing - 2),
                statusColor != null
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _miniSpacing,
                        vertical: _microTinySpacing - 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(_miniSpacing),
                        border: Border.all(color: statusColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: _captionFontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: const TextStyle(
                        fontSize: _smallFontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a form section with a title and icon
  Widget _buildFormSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: _spacing),
      padding: const EdgeInsets.all(_midSpacing),
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
                padding: const EdgeInsets.all(_miniSpacing),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(_miniSpacing),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: _smallIconSize,
                ),
              ),
              const SizedBox(width: _microSpacing),
              Text(
                title,
                style: TextStyle(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          ...children,
        ],
      ),
    );
  }

  /// Build the save button
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _updateUser,
        icon:
            _isSaving
                ? const SizedBox(
                  width: _smallIconSize,
                  height: _smallIconSize,
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
            vertical: _smallSpacing,
            horizontal: _midSpacing,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_smallBorderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: _bodyFontSize,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// Build the cancel button
  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: _isSaving ? null : _showExitConfirmation,
      icon: const Icon(Icons.close_rounded),
      label: const Text('Batal'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade400),
        padding: const EdgeInsets.symmetric(vertical: _smallSpacing),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
        ),
        textStyle: const TextStyle(
          fontSize: _bodyFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Show exit confirmation dialog
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
                Container(
                  padding: const EdgeInsets.all(_miniSpacing),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(_miniSpacing),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.orange.shade600,
                    size: _iconSize,
                  ),
                ),
                const SizedBox(width: _microSpacing),
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
                  context.go(RouteNames.adminUserList);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_miniSpacing),
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
    );
  }
}
