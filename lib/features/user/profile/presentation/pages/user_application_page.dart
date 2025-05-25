import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class UserApplicationsPage extends StatefulWidget {
  const UserApplicationsPage({super.key});

  @override
  State<UserApplicationsPage> createState() => _UserApplicationsPageState();
}

class _UserApplicationsPageState extends State<UserApplicationsPage>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  // ✅ Simplified stream without fallback complexity
  Stream<QuerySnapshot>? _applicationsStream;

  // ✅ Tab controller for filtering
  late TabController _tabController;
  List<String> _statusFilters = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Disetujui',
    'Ditolak',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _initializeApplications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        _setupApplicationsStream();
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      print('Error initializing applications: $e');
      setState(() {
        _errorMessage = 'Gagal memuat data pengajuan';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Simplified stream setup without fallback logic
  void _setupApplicationsStream() {
    try {
      _applicationsStream =
          FirebaseFirestore.instance
              .collection('applications')
              .where('userId', isEqualTo: _currentUser!.uid)
              .snapshots();
    } catch (e) {
      print('❌ Applications stream setup failed: $e');
      _applicationsStream = null;
    }
  }

  Future<void> _refreshApplications() async {
    await _initializeApplications();
  }

  // ✅ Application status helpers
  String _getApplicationStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return 'Disetujui';
      case 'ditolak':
      case 'rejected':
        return 'Ditolak';
      case 'diproses':
      case 'reviewed':
        return 'Diproses';
      case 'baru':
      case 'pending':
        return 'Menunggu Review';
      default:
        return status;
    }
  }

  Color _getApplicationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return Colors.green;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      case 'diproses':
      case 'reviewed':
        return Colors.blue;
      case 'baru':
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getApplicationStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return Icons.check_circle_rounded;
      case 'ditolak':
      case 'rejected':
        return Icons.cancel_rounded;
      case 'diproses':
      case 'reviewed':
        return Icons.visibility_rounded;
      case 'baru':
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  // ✅ Filter applications by status
  List<QueryDocumentSnapshot> _filterApplicationsByStatus(
    List<QueryDocumentSnapshot> applications,
    String filter,
  ) {
    if (filter == 'Semua') return applications;

    return applications.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString().toLowerCase();

      switch (filter) {
        case 'Menunggu':
          return ['baru', 'pending'].contains(status);
        case 'Diproses':
          return ['diproses', 'reviewed', 'processing'].contains(status);
        case 'Disetujui':
          return ['disetujui', 'approved'].contains(status);
        case 'Ditolak':
          return ['ditolak', 'rejected'].contains(status);
        default:
          return true;
      }
    }).toList();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Status Pengajuan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(RouteNames.userProfile),
            tooltip: 'Kembali ke Profil',
          ),
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
                Text('Memuat pengajuan...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Status Pengajuan",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue.shade700,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(RouteNames.userProfile),
            tooltip: 'Kembali ke Profil',
          ),
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
                  onPressed: _refreshApplications,
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
          "Status Pengajuan",
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(RouteNames.userProfile),
          tooltip: 'Kembali ke Profil',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshApplications,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _statusFilters.map((filter) => Tab(text: filter)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
        ),
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
        child: TabBarView(
          controller: _tabController,
          children:
              _statusFilters.map((filter) {
                return RefreshIndicator(
                  onRefresh: _refreshApplications,
                  child: _buildApplicationsList(filter),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildApplicationsList(String statusFilter) {
    if (_applicationsStream == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Stream tidak tersedia',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _refreshApplications,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _applicationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat pengajuan...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat pengajuan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString().length > 100
                      ? '${snapshot.error.toString().substring(0, 100)}...'
                      : snapshot.error.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.red.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshApplications,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pengajuan program',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan ajukan program bantuan terlebih dahulu',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // ✅ Process and filter applications with client-side sorting
        var applications = snapshot.data!.docs.toList();

        // Sort by submission date (newest first)
        applications.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aDate =
              aData['submissionDate'] ?? aData['createdAt'] ?? Timestamp.now();
          final bDate =
              bData['submissionDate'] ?? bData['createdAt'] ?? Timestamp.now();

          final aDateTime =
              aDate is Timestamp ? aDate.toDate() : DateTime.now();
          final bDateTime =
              bDate is Timestamp ? bDate.toDate() : DateTime.now();

          return bDateTime.compareTo(aDateTime);
        });

        // Filter by status
        final filteredApplications = _filterApplicationsByStatus(
          applications,
          statusFilter,
        );

        if (filteredApplications.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada pengajuan dengan status "$statusFilter"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba pilih filter status lain',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredApplications.length,
          itemBuilder: (context, index) {
            final applicationDoc = filteredApplications[index];
            final application = applicationDoc.data() as Map<String, dynamic>;
            application['id'] = applicationDoc.id;

            return _buildApplicationCard(application);
          },
        );
      },
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status'] ?? 'Baru';
    final submissionDate =
        application['submissionDate']?.toDate() ??
        application['createdAt']?.toDate();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            _getApplicationStatusColor(status).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getApplicationStatusColor(status).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getApplicationStatusColor(status).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header with status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getApplicationStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getApplicationStatusIcon(status),
                    color: _getApplicationStatusColor(status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application['programName'] ??
                            application['programTitle'] ??
                            'Program Bantuan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kategori: ${application['category'] ?? 'Tidak diketahui'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getApplicationStatusColor(status),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _getApplicationStatusDisplayName(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Timeline information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        submissionDate != null
                            ? 'Diajukan: ${_formatDate(submissionDate)}'
                            : 'Tanggal tidak tersedia',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        submissionDate != null
                            ? _formatRelativeDate(submissionDate)
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  if (application['reviewDate'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Direview: ${_formatDate(application['reviewDate'].toDate())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ✅ Application ID
            if (application['id'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.tag_rounded,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ID Pengajuan: ${application['id'].toString().substring(0, 12)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],

            // ✅ Admin notes
            if (application['notes'] != null &&
                application['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.note_alt_rounded,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Catatan Admin:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      application['notes'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ✅ Program details
            if (application['programDetails'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_rounded,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Penyelenggara: ${application['programDetails']['organizer'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
