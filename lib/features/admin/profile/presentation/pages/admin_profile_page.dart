import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../../../auth/services/admin_auth_service.dart';
import '../../data/admin_profile_service.dart';
import '../../data/models/admin_profile_model.dart';
import 'package:intl/intl.dart';

/// Halaman untuk menampilkan profil administrator
///
/// Menampilkan informasi profil, statistik aktivitas, dan opsi
/// manajemen akun seperti edit profile dan logout
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage>
    with TickerProviderStateMixin {
  // Keys & Services
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AdminProfileService _profileService = AdminProfileService();
  final AdminAuthService _authService = AdminAuthService();

  // State variables
  AdminProfileModel? _adminProfile;
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // UI Constants
  static const double _spacing = 16.0;
  static const double _largeSpacing = 20.0;
  static const double _mediumSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _miniSpacing = 4.0;

  static const double _borderRadius = 20.0;
  static const double _mediumBorderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;

  static const double _headingFontSize = 24.0;
  static const double _subheadingFontSize = 22.0;
  static const double _titleFontSize = 18.0;
  static const double _bodyFontSize = 16.0;
  static const double _smallFontSize = 14.0;
  static const double _microFontSize = 12.0;

  static const double _largeIconSize = 48.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 6.0;

  static const double _avatarRadius = 45.0;
  static const double _profilePicIconSize = 50.0;

  static const Duration _fadeAnimationDuration = Duration(milliseconds: 800);
  static const Duration _slideAnimationDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
  }

  /// Inisialisasi controller animasi
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: _fadeAnimationDuration,
      vsync: this,
    );

    _slideController = AnimationController(
      duration: _slideAnimationDuration,
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
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Memuat data profil administrator dan statistik
  Future<void> _loadProfileData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Reset animations before loading new data
    _fadeController.reset();
    _slideController.reset();

    try {
      final results = await Future.wait([
        _profileService.getCurrentAdminProfile(),
        _profileService.getAdminStatistics(),
      ]);

      if (mounted) {
        setState(() {
          _adminProfile = results[0] as AdminProfileModel?;
          _statistics = results[1] as Map<String, int>;
          _isLoading = false;
        });

        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data profil: ${e.toString()}';
          _isLoading = false;
        });
        debugPrint('Error loading profile data: $e');
      }
    }
  }

  /// Proses logout dari aplikasi dengan konfirmasi
  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLogoutConfirmationDialog(),
    );

    if (confirmed == true && mounted) {
      try {
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 16),
                Text('Logging out...'),
              ],
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Use AdminAuthService to properly clear all session data
        await _authService.logout();

        if (mounted) {
          _showSnackBar(message: 'Logout berhasil', isError: false);
          context.go(RouteNames.adminLogin);
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            message: 'Error logout: ${e.toString()}',
            isError: true,
          );
          debugPrint('Error during logout: $e');
        }
      }
    }
  }

  /// Menampilkan dialog konfirmasi logout
  Widget _buildLogoutConfirmationDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
      ),
      icon: Container(
        padding: const EdgeInsets.all(_mediumSpacing),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.logout_rounded,
          color: Colors.red.shade600,
          size: _largeIconSize,
        ),
      ),
      title: const Text(
        'Konfirmasi Logout',
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Apakah Anda yakin ingin keluar dari sistem?',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }

  /// Menampilkan snackbar pesan informasi atau error
  void _showSnackBar({required String message, required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: _microSpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
      ),
    );
  }

  /// Format tanggal dengan format yang lebih mudah dibaca
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  /// Mendapatkan warna sesuai status akun
  Color _getStatusColor(bool isActive) {
    return isActive ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody(),
      drawer: const AdminNavigationDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Membangun struktur utama body halaman
  Widget _buildBody() {
    return Container(
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
            // Custom App Bar
            _buildCustomAppBar(),

            // Main Content
            Expanded(
              child:
                  _isLoading
                      ? _buildLoadingWidget()
                      : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildProfileContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_largeSpacing),
      child: Row(
        children: [
          // Menu Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: _iconSize,
              ),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          const SizedBox(width: _mediumSpacing),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _headingFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola informasi akun admin',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _smallFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Refresh Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: IconButton(
              icon: AnimatedRotation(
                turns: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 1000),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: _iconSize,
                ),
              ),
              onPressed: _isLoading ? null : _loadProfileData,
              tooltip: 'Segarkan Data',
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tampilan loading
  Widget _buildLoadingWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: _mediumSpacing),
            Text(
              'Memuat data profil...',
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

  /// Membangun tampilan error
  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(_largeSpacing),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(_mediumSpacing),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: _largeIconSize,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: _mediumSpacing),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                color: Colors.white,
                fontSize: _titleFontSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: _microSpacing),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: _smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: _largeSpacing),
            ElevatedButton.icon(
              onPressed: _loadProfileData,
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
          ],
        ),
      ),
    );
  }

  /// Membangun konten utama profil
  Widget _buildProfileContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(_largeSpacing + 4),
              topRight: Radius.circular(_largeSpacing + 4),
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _loadProfileData,
            color: Colors.blue.shade700,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: _largeSpacing, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Section
                  _buildProfileHeader(),

                  // Admin Information
                  _buildAdminInformation(),

                  // Statistics
                  _buildStatistics(),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun header profil dengan foto dan info dasar
  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(_largeSpacing),
      padding: const EdgeInsets.all(_largeSpacing + 4),
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
      child: Row(
        children: [
          // Profile Picture
          _buildProfilePicture(),
          const SizedBox(width: _largeSpacing),

          // Profile Info
          _buildProfileInfo(),
        ],
      ),
    );
  }

  /// Membangun tampilan foto profil
  Widget _buildProfilePicture() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: _avatarRadius,
        backgroundColor: Colors.white,
        backgroundImage:
            _adminProfile?.profilePictureUrl != null
                ? NetworkImage(_adminProfile!.profilePictureUrl!)
                : null,
        child:
            _adminProfile?.profilePictureUrl == null
                ? Icon(
                  Icons.person_rounded,
                  size: _profilePicIconSize,
                  color: Colors.blue.shade700,
                )
                : null,
      ),
    );
  }

  /// Membangun informasi profil di header
  Widget _buildProfileInfo() {
    final isActive = _adminProfile?.isActive ?? true;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _adminProfile?.fullName ?? 'Admin',
            style: const TextStyle(
              fontSize: _subheadingFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: _miniSpacing),
          Text(
            _adminProfile?.position ?? 'Administrator',
            style: TextStyle(
              fontSize: _bodyFontSize,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: _smallSpacing),
          _buildStatusBadge(isActive),
        ],
      ),
    );
  }

  /// Membangun badge status akun
  Widget _buildStatusBadge(bool isActive) {
    final statusColor = _getStatusColor(isActive);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _smallSpacing,
        vertical: _tinySpacing,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _microIconSize,
            height: _microIconSize,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: _tinySpacing),
          Text(
            isActive ? 'Aktif' : 'Tidak Aktif',
            style: const TextStyle(
              fontSize: _microFontSize,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian informasi admin
  Widget _buildAdminInformation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        _largeSpacing,
        0,
        _largeSpacing,
        _largeSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informasi Admin",
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _smallSpacing),
          Container(
            padding: const EdgeInsets.all(_largeSpacing),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_mediumBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.email_rounded,
                  'Email',
                  _adminProfile?.email ?? 'N/A',
                  Colors.blue,
                ),
                _buildInfoRow(
                  Icons.phone_rounded,
                  'Nomor Telepon',
                  _adminProfile?.phoneNumber ?? 'N/A',
                  Colors.green,
                ),
                _buildInfoRow(
                  Icons.work_rounded,
                  'Jabatan',
                  _adminProfile?.position ?? 'N/A',
                  Colors.purple,
                ),
                _buildInfoRow(
                  Icons.security_rounded,
                  'Role',
                  _adminProfile?.getRoleDisplayName() ?? 'N/A',
                  Colors.orange,
                ),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'Bergabung',
                  _formatDate(_adminProfile?.createdAt),
                  Colors.teal,
                ),
                _buildInfoRow(
                  Icons.access_time_rounded,
                  'Login Terakhir',
                  _formatDate(_adminProfile?.lastLogin),
                  Colors.red,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun baris informasi admin
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : _mediumSpacing),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(_microSpacing),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_microBorderRadius),
            ),
            child: Icon(icon, size: _smallIconSize, color: color),
          ),
          const SizedBox(width: _mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: _smallFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: _miniSpacing),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: _bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian statistik
  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        _largeSpacing,
        0,
        _largeSpacing,
        _largeSpacing,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistik",
            style: TextStyle(
              fontSize: _titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _smallSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Pengguna',
                  _statistics['totalUsers']?.toString() ?? '0',
                  Icons.people_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: _buildStatCard(
                  'Program Dikelola',
                  _statistics['managedPrograms']?.toString() ?? '0',
                  Icons.assignment_rounded,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Aplikasi Direview',
                  _statistics['reviewedApplications']?.toString() ?? '0',
                  Icons.rate_review_rounded,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: _buildStatCard(
                  'Konten Dipublikasi',
                  _statistics['publishedContent']?.toString() ?? '0',
                  Icons.article_rounded,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Membangun kartu statistik
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(_mediumSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: _iconSize),
              Text(
                value,
                style: TextStyle(
                  fontSize: _headingFontSize,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: _microSpacing),
          Text(
            title,
            style: TextStyle(
              fontSize: _microFontSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol aksi
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        _largeSpacing,
        0,
        _largeSpacing,
        _largeSpacing,
      ),
      child: Column(
        children: [
          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(RouteNames.adminEditProfile),
              icon: const Icon(Icons.edit_rounded),
              label: const Text("Ubah Data Profil"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: _mediumSpacing),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_smallBorderRadius),
                ),
                elevation: 2,
                textStyle: const TextStyle(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: _smallSpacing),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout_rounded, color: Colors.red.shade600),
              label: Text(
                "Logout",
                style: TextStyle(color: Colors.red.shade600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: _mediumSpacing),
                side: BorderSide(color: Colors.red.shade600, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_smallBorderRadius),
                ),
                textStyle: const TextStyle(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun floating action button
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(_mediumBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.adminEditProfile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: _iconSize,
        ),
        label: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: _bodyFontSize,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_mediumBorderRadius),
        ),
      ),
    );
  }
}
