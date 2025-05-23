import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../../data/admin_profile_service.dart';
import '../../data/models/admin_profile_model.dart';
import 'package:intl/intl.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AdminProfileService _profileService = AdminProfileService();
  
  AdminProfileModel? _adminProfile;
  List<Map<String, dynamic>> _managedPrograms = [];
  Map<String, int> _statistics = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _profileService.getCurrentAdminProfile(),
        _profileService.getManagedPrograms(),
        _profileService.getAdminStatistics(),
      ]);

      setState(() {
        _adminProfile = results[0] as AdminProfileModel?;
        _managedPrograms = results[1] as List<Map<String, dynamic>>;
        _statistics = results[2] as Map<String, int>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data profil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari sistem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _profileService.signOut();
        if (mounted) {
          context.go(RouteNames.adminLogin);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logout: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Admin"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadProfileData,
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfileData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfileData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // Profile Picture
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.blue.shade100,
                                  backgroundImage: _adminProfile?.profilePictureUrl != null
                                      ? NetworkImage(_adminProfile!.profilePictureUrl!)
                                      : null,
                                  child: _adminProfile?.profilePictureUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.blue.shade700,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                // Profile Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _adminProfile?.fullName ?? 'Admin',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _adminProfile?.position ?? 'Administrator',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _adminProfile?.isActive == true ? 'Aktif' : 'Tidak Aktif',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Admin Information
                        const Text(
                          "Informasi Admin",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Email', _adminProfile?.email ?? 'N/A'),
                                _buildInfoRow('Nomor Telepon', _adminProfile?.phoneNumber ?? 'N/A'),
                                _buildInfoRow('Jabatan', _adminProfile?.position ?? 'N/A'),
                                _buildInfoRow('Role', _adminProfile?.role ?? 'N/A'),
                                _buildInfoRow('Bergabung', _formatDate(_adminProfile?.createdAt)),
                                _buildInfoRow('Login Terakhir', _formatDate(_adminProfile?.lastLogin)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Statistics
                        const Text(
                          "Statistik",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Pengguna',
                                _statistics['totalUsers']?.toString() ?? '0',
                                Icons.people,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Program Dikelola',
                                _statistics['managedPrograms']?.toString() ?? '0',
                                Icons.assignment,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Aplikasi Direview',
                                _statistics['reviewedApplications']?.toString() ?? '0',
                                Icons.rate_review,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Konten Dipublikasi',
                                _statistics['publishedContent']?.toString() ?? '0',
                                Icons.article,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Program Management Section
                        const Text(
                          "Program yang Dikelola",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        _managedPrograms.isEmpty
                            ? Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      'Belum ada program yang dikelola',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _managedPrograms.length,
                                itemBuilder: (context, index) {
                                  final program = _managedPrograms[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: ListTile(
                                      title: Text(program['name'] ?? 'Program ${index + 1}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(program['description'] ?? 'Tidak ada deskripsi'),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Status: ${program['status'] ?? 'N/A'} • ${program['totalApplicants'] ?? 0} pelamar',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                      onTap: () {
                                        // Navigate to program detail page
                                        // context.push('${RouteNames.adminProgramDetail}/${program['id']}');
                                      },
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 24.0),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(RouteNames.adminEditProfile);
                            },
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
                            child: const Text("Ubah Data"),
                          ),
                        ),
                        const SizedBox(height: 8.0),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _logout,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                                horizontal: 20.0,
                              ),
                              side: const BorderSide(
                                color: Colors.red,
                                width: 2,
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
                            child: const Text("Logout"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}