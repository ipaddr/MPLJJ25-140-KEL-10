import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/user/core_user/presentation/widgets/user_bottom_navigation_bar.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  // ✅ SIMPLIFIED: Only user data stream needed
  Stream<DocumentSnapshot>? _userDataStream;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

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
      print('Error initializing profile: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data profil';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ SIMPLIFIED: Setup only user data stream
  void _setupUserDataStream() {
    _userDataStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .snapshots();
  }

  Future<void> _loadInitialUserData() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        await _migrateUserStatusIfNeeded(_userData!);
      }
    } catch (e) {
      print('Error loading initial user data: $e');
    }
  }

  // Method to migrate old status format to admin-compatible format
  Future<void> _migrateUserStatusIfNeeded(Map<String, dynamic> userData) async {
    try {
      final currentStatus = userData['status'];
      final isVerified = userData['isVerified'];
      final accountStatus = userData['accountStatus'];

      String newStatus = 'active';
      bool needsUpdate = false;

      if (currentStatus != null) {
        if (['active', 'inactive', 'suspended'].contains(currentStatus)) {
          return;
        }
      }

      if (isVerified == true) {
        newStatus = 'active';
        needsUpdate = true;
      } else if (accountStatus == 'pending_verification' ||
          accountStatus == 'Menunggu Verifikasi') {
        newStatus = 'inactive';
        needsUpdate = true;
      } else if (accountStatus == 'suspended' ||
          accountStatus == 'Ditangguhkan') {
        newStatus = 'suspended';
        needsUpdate = true;
      } else if (accountStatus == 'active' ||
          accountStatus == 'Terverifikasi') {
        newStatus = 'active';
        needsUpdate = true;
      }

      if (needsUpdate) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .update({
              'status': newStatus,
              'accountStatus': newStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        _userData!['status'] = newStatus;
        _userData!['accountStatus'] = newStatus;

        print('Migrated user status to: $newStatus');
      }
    } catch (e) {
      print('Error migrating user status: $e');
    }
  }

  Future<void> _refreshProfile() async {
    await _initializeProfile();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
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

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go(RouteNames.login);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Helper method to get field with fallback
  String _getFieldWithFallback(
    Map<String, dynamic>? userData,
    String newField,
    String oldField, [
    String defaultValue = 'Tidak tersedia',
  ]) {
    final newValue = userData?[newField];
    final oldValue = userData?[oldField];

    if (newValue != null && newValue.toString().isNotEmpty) {
      return newValue.toString();
    }
    if (oldValue != null && oldValue.toString().isNotEmpty) {
      return oldValue.toString();
    }
    return defaultValue;
  }

  // Updated status helper
  String _getUserStatus(Map<String, dynamic>? userData) {
    final status = userData?['status'] ?? userData?['accountStatus'];

    switch (status) {
      case 'active':
        return 'active';
      case 'inactive':
        return 'inactive';
      case 'suspended':
        return 'suspended';
      default:
        final isVerified = userData?['isVerified'];
        if (isVerified == true) return 'active';
        return 'inactive';
    }
  }

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

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Akun", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat profil...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Akun", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
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

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ User Profile Card with real-time updates
                StreamBuilder<DocumentSnapshot>(
                  stream: _userDataStream,
                  builder: (context, snapshot) {
                    Map<String, dynamic>? currentUserData = _userData;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      currentUserData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                    }

                    if (currentUserData == null) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text('Data profil tidak tersedia'),
                        ),
                      );
                    }

                    final userStatus = _getUserStatus(currentUserData);

                    return Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade800],
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentUserData['fullName'] ??
                                currentUserData['name'] ??
                                'Nama tidak tersedia',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentUserData['email'] ?? 'Email tidak tersedia',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade100,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(userStatus),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(userStatus),
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusDisplayName(userStatus),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                // ✅ User Information Section with real-time data
                StreamBuilder<DocumentSnapshot>(
                  stream: _userDataStream,
                  builder: (context, snapshot) {
                    Map<String, dynamic>? currentUserData = _userData;

                    if (snapshot.hasData && snapshot.data!.exists) {
                      currentUserData =
                          snapshot.data!.data() as Map<String, dynamic>?;
                    }

                    return Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
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
                                Icons.person_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Informasi Pengguna",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          _buildInfoItem(
                            Icons.credit_card,
                            'NIK',
                            currentUserData?['nik'] ?? 'Tidak tersedia',
                          ),
                          _buildInfoItem(
                            Icons.phone,
                            'Nomor Telepon',
                            currentUserData?['phoneNumber'] ?? 'Tidak tersedia',
                          ),
                          _buildInfoItem(
                            Icons.work,
                            'Jenis Pekerjaan',
                            _getFieldWithFallback(
                              currentUserData,
                              'occupation',
                              'jobType',
                            ),
                          ),
                          _buildInfoItem(
                            Icons.location_on,
                            'Lokasi',
                            _getFieldWithFallback(
                              currentUserData,
                              'address',
                              'location',
                            ),
                          ),
                          _buildInfoItem(
                            Icons.attach_money,
                            'Pendapatan Per Bulan',
                            currentUserData?['monthlyIncome'] != null
                                ? _formatCurrency(
                                  currentUserData!['monthlyIncome'].toDouble(),
                                )
                                : 'Tidak tersedia',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                // ✅ NEW: Quick Action Card untuk navigasi ke Status Pengajuan
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
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
                            size: 24,
                          ),
                          const SizedBox(width: 8),
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
                      const SizedBox(height: 16),
                      _buildQuickActionCard(
                        title: 'Status Pengajuan',
                        subtitle: 'Lihat status semua pengajuan program Anda',
                        icon: Icons.assignment_outlined,
                        color: Colors.blue,
                        onTap: () => context.go(RouteNames.userApplications),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // ✅ Action Buttons
                Column(
                  children: [
                    // Edit Data Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            RouteNames.editUserProfile,
                            extra: _userData,
                          );
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
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),

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
                            borderRadius: BorderRadius.circular(12.0),
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
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const UserBottomNavigationBar(selectedIndex: 3),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
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
}
