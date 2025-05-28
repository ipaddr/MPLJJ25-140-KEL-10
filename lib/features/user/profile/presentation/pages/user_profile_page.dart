import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';
import '../../../auth/services/user_auth_service.dart';

/// Halaman untuk menampilkan dan mengelola profil pengguna
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final UserAuthService _authService = UserAuthService();

  // State variables
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  // User data stream
  Stream<DocumentSnapshot>? _userDataStream;

  // Collection path constant
  static const String _usersCollectionPath = 'users';

  // UI constants
  static const double _cardSpacing = 24.0;
  static const double _itemSpacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _cardRadius = 16.0;
  static const double _statusRadius = 16.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  /// Mengambil dan menginisialisasi data profil pengguna
  Future<void> _initializeProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        _setupUserDataStream();
        await _loadInitialUserData();
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      debugPrint('Error initializing profile: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data profil';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Mengatur stream untuk data pengguna
  void _setupUserDataStream() {
    _userDataStream =
        FirebaseFirestore.instance
            .collection(_usersCollectionPath)
            .doc(_currentUser!.uid)
            .snapshots();
  }

  /// Memuat data pengguna awal dan melakukan migrasi status jika diperlukan
  Future<void> _loadInitialUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection(_usersCollectionPath)
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        if (_userData != null) {
          await _migrateUserStatusIfNeeded(_userData!);
        }
      }
    } catch (e) {
      debugPrint('Error loading initial user data: $e');
    }
  }

  /// Migrasi format status pengguna lama ke format yang kompatibel dengan admin
  Future<void> _migrateUserStatusIfNeeded(Map<String, dynamic> userData) async {
    try {
      final currentStatus = userData['status'];
      final isVerified = userData['isVerified'];
      final accountStatus = userData['accountStatus'];

      // Check if we already have correct status format
      if (currentStatus != null &&
          ['active', 'inactive', 'suspended'].contains(currentStatus)) {
        return;
      }

      // Determine new status based on existing fields
      String? newStatus;
      if (isVerified == true) {
        newStatus = 'active';
      } else if ([
        'pending_verification',
        'Menunggu Verifikasi',
      ].contains(accountStatus)) {
        newStatus = 'inactive';
      } else if (['suspended', 'Ditangguhkan'].contains(accountStatus)) {
        newStatus = 'suspended';
      } else if (['active', 'Terverifikasi'].contains(accountStatus)) {
        newStatus = 'active';
      }

      // Only update if we determined a new status
      if (newStatus != null) {
        await FirebaseFirestore.instance
            .collection(_usersCollectionPath)
            .doc(_currentUser!.uid)
            .update({
              'status': newStatus,
              'accountStatus': newStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Update local data
        _userData!['status'] = newStatus;
        _userData!['accountStatus'] = newStatus;

        debugPrint('Migrated user status to: $newStatus');
      }
    } catch (e) {
      debugPrint('Error migrating user status: $e');
    }
  }

  /// Menyegarkan data profil
  Future<void> _refreshProfile() async {
    await _initializeProfile();
  }

  /// Logout dari aplikasi dengan konfirmasi
  Future<void> _logout() async {
    final shouldLogout = await _showLogoutConfirmation();

    if (shouldLogout == true) {
      try {
        // Show loading indicator
        if (mounted) {
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
        }

        // Use UserAuthService to properly clear all session data
        await _authService.logout();

        if (mounted) {
          // Navigate to login page
          context.go(RouteNames.login);

          // Show success message
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout berhasil'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Gagal logout: $e');
        }
      }
    }
  }

  /// Menampilkan dialog konfirmasi logout
  Future<bool?> _showLogoutConfirmation() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            title: const Text('Konfirmasi Logout'),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  /// Menampilkan snackbar error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Mendapatkan nilai field dengan alternatif
  String _getFieldWithFallback(
    Map<String, dynamic>? userData,
    String newField,
    String oldField, [
    String defaultValue = 'Tidak tersedia',
  ]) {
    if (userData == null) return defaultValue;

    final newValue = userData[newField];
    if (newValue != null && newValue.toString().isNotEmpty) {
      return newValue.toString();
    }

    final oldValue = userData[oldField];
    if (oldValue != null && oldValue.toString().isNotEmpty) {
      return oldValue.toString();
    }

    return defaultValue;
  }

  /// Mendapatkan status pengguna dari data
  String _getUserStatus(Map<String, dynamic>? userData) {
    if (userData == null) return 'inactive';

    final status = userData['status'] ?? userData['accountStatus'];

    switch (status) {
      case 'active':
        return 'active';
      case 'inactive':
        return 'inactive';
      case 'suspended':
        return 'suspended';
      default:
        return userData['isVerified'] == true ? 'active' : 'inactive';
    }
  }

  /// Mendapatkan nama yang ditampilkan untuk status
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Terverifikasi';
      case 'inactive':
        return 'Menunggu Verifikasi';
      case 'suspended':
        return 'Ditangguhkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  /// Mendapatkan warna untuk status
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

  /// Mendapatkan ikon untuk status
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.verified;
      case 'inactive':
        return Icons.pending;
      case 'suspended':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  /// Format angka sebagai mata uang
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildMainContent();
  }

  /// Membangun tampilan loading
  Widget _buildLoadingState() {
    return Scaffold(
      appBar: _buildSimpleAppBar('Akun'),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: _itemSpacing),
              Text('Memuat profil...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun tampilan error
  Widget _buildErrorState() {
    return Scaffold(
      appBar: _buildSimpleAppBar('Akun'),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: _itemSpacing),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _itemSpacing),
              ElevatedButton.icon(
                onPressed: _refreshProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun konten utama
  Widget _buildMainContent() {
    return Scaffold(
      appBar: _buildMainAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackgroundGradient(),
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(_itemSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card
                _buildProfileCard(),
                const SizedBox(height: _cardSpacing),

                // User Information Section
                _buildUserInformationSection(),
                const SizedBox(height: _cardSpacing),

                // Quick Action Card
                _buildQuickActionCard(),
                const SizedBox(height: _cardSpacing),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: _cardSpacing),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(selectedIndex: 3),
    );
  }

  /// Membangun AppBar sederhana untuk loading/error
  PreferredSizeWidget _buildSimpleAppBar(String title) {
    return AppBar(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.blue.shade700,
      centerTitle: true,
    );
  }

  /// Membangun AppBar utama
  PreferredSizeWidget _buildMainAppBar() {
    return AppBar(
      title: const Text(
        "Akun",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      backgroundColor: Colors.blue.shade700,
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshProfile,
          tooltip: 'Refresh Data',
        ),
      ],
    );
  }

  /// Membangun gradient background
  BoxDecoration _buildBackgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade50, Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// Membangun kartu profil
  Widget _buildProfileCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        Map<String, dynamic>? currentUserData = _userData;

        if (snapshot.hasData && snapshot.data!.exists) {
          currentUserData = snapshot.data!.data() as Map<String, dynamic>?;
        }

        if (currentUserData == null) {
          return Container(
            padding: const EdgeInsets.all(_cardSpacing),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(_cardRadius),
            ),
            child: const Center(child: Text('Data profil tidak tersedia')),
          );
        }

        final userStatus = _getUserStatus(currentUserData);

        return Container(
          margin: const EdgeInsets.all(_cardSpacing),
          padding: const EdgeInsets.all(_cardSpacing),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
            borderRadius: BorderRadius.circular(_cardSpacing),
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
              _buildProfilePicture(currentUserData),
              const SizedBox(width: _cardSpacing),

              // Profile Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFieldWithFallback(
                        currentUserData,
                        'fullName',
                        'name',
                        'Nama tidak tersedia',
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFieldWithFallback(
                        currentUserData,
                        'email',
                        'email',
                        'Email tidak tersedia',
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: _smallSpacing),
                    _buildStatusBadge(userStatus),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Membangun gambar profil
  Widget _buildProfilePicture(Map<String, dynamic> userData) {
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
        radius: 45,
        backgroundColor: Colors.white,
        backgroundImage:
            userData['profilePictureUrl'] != null
                ? NetworkImage(userData['profilePictureUrl'])
                : null,
        child:
            userData['profilePictureUrl'] == null
                ? Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: Colors.blue.shade700,
                )
                : null,
      ),
    );
  }

  /// Membangun badge status
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _smallSpacing,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(_statusRadius),
        border: Border.all(color: _getStatusColor(status), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusDisplayName(status),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian informasi pengguna
  Widget _buildUserInformationSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        Map<String, dynamic>? currentUserData = _userData;

        if (snapshot.hasData && snapshot.data!.exists) {
          currentUserData = snapshot.data!.data() as Map<String, dynamic>?;
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(
            _cardSpacing,
            0,
            _cardSpacing,
            _cardSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Informasi Pengguna",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: _smallSpacing),
              Container(
                padding: const EdgeInsets.all(_cardSpacing),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.credit_card,
                      'NIK',
                      currentUserData?['nik'] ?? 'Tidak tersedia',
                      Colors.blue.shade700,
                    ),
                    _buildInfoRow(
                      Icons.phone,
                      'Nomor Telepon',
                      currentUserData?['phoneNumber'] ?? 'Tidak tersedia',
                      Colors.blue.shade700,
                    ),
                    _buildInfoRow(
                      Icons.work,
                      'Jenis Pekerjaan',
                      _getFieldWithFallback(
                        currentUserData,
                        'occupation',
                        'jobType',
                      ),
                      Colors.blue.shade700,
                    ),
                    _buildInfoRow(
                      Icons.location_on,
                      'Lokasi',
                      _getFieldWithFallback(
                        currentUserData,
                        'address',
                        'location',
                      ),
                      Colors.blue.shade700,
                    ),
                    _buildInfoRow(
                      Icons.attach_money,
                      'Pendapatan Per Bulan',
                      currentUserData?['monthlyIncome'] != null
                          ? _formatCurrency(
                            currentUserData!['monthlyIncome'].toDouble(),
                          )
                          : 'Tidak tersedia',
                      Colors.blue.shade700,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Membangun baris informasi
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : _itemSpacing),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: _smallIconSize, color: color),
          ),
          const SizedBox(width: _itemSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  /// Membangun kartu aksi cepat
  Widget _buildQuickActionCard() {
    return Container(
      padding: const EdgeInsets.all(_cardSpacing),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
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
              Icon(
                Icons.dashboard_outlined,
                color: Colors.blue.shade700,
                size: _iconSize,
              ),
              const SizedBox(width: _tinySpacing),
              const Text(
                "Aksi Cepat",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: _itemSpacing),
          _buildQuickActionItem(
            title: 'Status Pengajuan',
            subtitle: 'Lihat status semua pengajuan program Anda',
            icon: Icons.assignment_outlined,
            color: Colors.blue,
            onTap: () => context.go(RouteNames.userApplications),
          ),
        ],
      ),
    );
  }

  /// Membangun item aksi cepat
  Widget _buildQuickActionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_smallSpacing),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_smallSpacing),
        child: Padding(
          padding: const EdgeInsets.all(_itemSpacing),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_tinySpacing),
                ),
                child: Icon(icon, color: color, size: _iconSize),
              ),
              const SizedBox(width: _itemSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun tombol aksi
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Edit Data Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.push(RouteNames.editUserProfile, extra: _userData);
            },
            icon: const Icon(Icons.edit),
            label: const Text("Ubah Data"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallSpacing),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
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
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallSpacing),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
