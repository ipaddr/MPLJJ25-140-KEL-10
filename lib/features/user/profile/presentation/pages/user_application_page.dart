import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socio_care/core/navigation/route_names.dart';

/// Halaman untuk menampilkan status pengajuan pengguna
class UserApplicationsPage extends StatefulWidget {
  const UserApplicationsPage({super.key});

  @override
  State<UserApplicationsPage> createState() => _UserApplicationsPageState();
}

class _UserApplicationsPageState extends State<UserApplicationsPage>
    with SingleTickerProviderStateMixin {
  // State variables
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  Stream<QuerySnapshot>? _applicationsStream;

  // Tab controller for filtering
  late TabController _tabController;

  // Filter constants
  static const List<String> _statusFilters = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Disetujui',
    'Ditolak',
  ];

  // Collection path constant
  static const String _applicationsCollectionPath = 'applications';

  // UI constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _borderRadius = 16.0;
  static const double _borderWidth = 2.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 18.0;
  static const double _microIconSize = 16.0;
  static const double _cardPadding = 20.0;

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

  /// Menginisialisasi data pengajuan
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
      debugPrint('Error initializing applications: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data pengajuan';
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

  /// Mengatur stream untuk data pengajuan
  void _setupApplicationsStream() {
    try {
      _applicationsStream =
          FirebaseFirestore.instance
              .collection(_applicationsCollectionPath)
              .where('userId', isEqualTo: _currentUser!.uid)
              .snapshots();
    } catch (e) {
      debugPrint('Applications stream setup failed: $e');
      _applicationsStream = null;
    }
  }

  /// Menyegarkan data pengajuan
  Future<void> _refreshApplications() async {
    await _initializeApplications();
  }

  /// Mendapatkan nama tampilan status pengajuan
  String _getApplicationStatusDisplayName(String status) {
    final lowerStatus = status.toLowerCase();
    if (['disetujui', 'approved'].contains(lowerStatus)) {
      return 'Disetujui';
    } else if (['ditolak', 'rejected'].contains(lowerStatus)) {
      return 'Ditolak';
    } else if (['diproses', 'reviewed'].contains(lowerStatus)) {
      return 'Diproses';
    } else if (['baru', 'pending'].contains(lowerStatus)) {
      return 'Menunggu Review';
    } else {
      return status;
    }
  }

  /// Mendapatkan warna untuk status pengajuan
  Color _getApplicationStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (['disetujui', 'approved'].contains(lowerStatus)) {
      return Colors.green;
    } else if (['ditolak', 'rejected'].contains(lowerStatus)) {
      return Colors.red;
    } else if (['diproses', 'reviewed'].contains(lowerStatus)) {
      return Colors.blue;
    } else if (['baru', 'pending'].contains(lowerStatus)) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  /// Mendapatkan ikon untuk status pengajuan
  IconData _getApplicationStatusIcon(String status) {
    final lowerStatus = status.toLowerCase();
    if (['disetujui', 'approved'].contains(lowerStatus)) {
      return Icons.check_circle_rounded;
    } else if (['ditolak', 'rejected'].contains(lowerStatus)) {
      return Icons.cancel_rounded;
    } else if (['diproses', 'reviewed'].contains(lowerStatus)) {
      return Icons.visibility_rounded;
    } else if (['baru', 'pending'].contains(lowerStatus)) {
      return Icons.schedule_rounded;
    } else {
      return Icons.help_outline_rounded;
    }
  }

  /// Memfilter pengajuan berdasarkan status
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

  /// Memformat tanggal ke format Indonesia singkat
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

  /// Memformat tanggal relatif
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
      appBar: _buildSimpleAppBar(),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: _spacing),
              Text('Memuat pengajuan...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun tampilan error
  Widget _buildErrorState() {
    return Scaffold(
      appBar: _buildSimpleAppBar(),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: _spacing),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _spacing),
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

  /// Membangun konten utama
  Widget _buildMainContent() {
    return Scaffold(
      appBar: _buildAppBarWithTabs(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: _buildBackgroundGradient(),
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

  /// Membangun AppBar sederhana
  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
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
    );
  }

  /// Membangun AppBar dengan tabs
  PreferredSizeWidget _buildAppBarWithTabs() {
    return AppBar(
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

  /// Membangun daftar pengajuan
  Widget _buildApplicationsList(String statusFilter) {
    if (_applicationsStream == null) {
      return _buildStreamErrorView();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _applicationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildListLoadingView();
        }

        if (snapshot.hasError) {
          return _buildListErrorView(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyListView();
        }

        // Process applications
        final applications = snapshot.data!.docs.toList();
        _sortApplicationsByDate(applications);

        // Filter by status
        final filteredApplications = _filterApplicationsByStatus(
          applications,
          statusFilter,
        );

        if (filteredApplications.isEmpty) {
          return _buildEmptyFilterView(statusFilter);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(_spacing),
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

  /// Menyortir pengajuan berdasarkan tanggal
  void _sortApplicationsByDate(List<QueryDocumentSnapshot> applications) {
    applications.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>;
      final bData = b.data() as Map<String, dynamic>;

      final aDate =
          aData['submissionDate'] ?? aData['createdAt'] ?? Timestamp.now();
      final bDate =
          bData['submissionDate'] ?? bData['createdAt'] ?? Timestamp.now();

      final aDateTime = aDate is Timestamp ? aDate.toDate() : DateTime.now();
      final bDateTime = bDate is Timestamp ? bDate.toDate() : DateTime.now();

      return bDateTime.compareTo(aDateTime); // Newest first
    });
  }

  /// Membangun tampilan error untuk stream
  Widget _buildStreamErrorView() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: _spacing),
          Text(
            'Stream tidak tersedia',
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: _smallSpacing),
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

  /// Membangun tampilan loading untuk daftar
  Widget _buildListLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: _spacing),
          Text('Memuat pengajuan...'),
        ],
      ),
    );
  }

  /// Membangun tampilan error untuk daftar
  Widget _buildListErrorView(String error) {
    final errorMessage =
        error.length > 100 ? '${error.substring(0, 100)}...' : error;

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: _spacing),
          Text(
            'Gagal memuat pengajuan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: _tinySpacing),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 12, color: Colors.red.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _spacing),
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

  /// Membangun tampilan kosong untuk daftar
  Widget _buildEmptyListView() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: _spacing),
          Text(
            'Belum ada pengajuan program',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: _tinySpacing),
          Text(
            'Silakan ajukan program bantuan terlebih dahulu',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Membangun tampilan kosong untuk filter
  Widget _buildEmptyFilterView(String filter) {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: _spacing),
          Text(
            'Tidak ada pengajuan dengan status "$filter"',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: _tinySpacing),
          Text(
            'Coba pilih filter status lain',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  /// Membangun kartu pengajuan
  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final status = application['status'] ?? 'Baru';
    final submissionDate = _getDateFromField(application, [
      'submissionDate',
      'createdAt',
    ]);
    final reviewDate = _getDateFromField(application, ['reviewDate']);
    final statusColor = _getApplicationStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: _spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: _borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            _buildCardHeader(application, status, statusColor),
            const SizedBox(height: _cardPadding),

            // Timeline information
            _buildTimelineInfo(submissionDate, reviewDate),

            // Application ID
            if (application['id'] != null) ...[
              const SizedBox(height: _smallSpacing),
              _buildApplicationId(application['id']),
            ],

            // Admin notes
            if (_hasNotes(application)) ...[
              const SizedBox(height: _spacing),
              _buildAdminNotes(application['notes']),
            ],

            // Program details
            if (_hasProgramDetails(application)) ...[
              const SizedBox(height: _spacing),
              _buildProgramOrganizer(application['programDetails']),
            ],
          ],
        ),
      ),
    );
  }

  /// Mendapatkan tanggal dari field yang tersedia
  DateTime? _getDateFromField(
    Map<String, dynamic> data,
    List<String> possibleFields,
  ) {
    for (final field in possibleFields) {
      final value = data[field];
      if (value != null && value is Timestamp) {
        return value.toDate();
      }
    }
    return null;
  }

  /// Membangun header kartu
  Widget _buildCardHeader(
    Map<String, dynamic> application,
    String status,
    Color statusColor,
  ) {
    final programName =
        application['programName'] ??
        application['programTitle'] ??
        'Program Bantuan';
    final category = application['category'] ?? 'Tidak diketahui';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(_smallSpacing),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_smallSpacing),
          ),
          child: Icon(
            _getApplicationStatusIcon(status),
            color: statusColor,
            size: _iconSize,
          ),
        ),
        const SizedBox(width: _spacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                programName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kategori: $category',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _spacing,
            vertical: _tinySpacing,
          ),
          decoration: BoxDecoration(
            color: statusColor,
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
    );
  }

  /// Membangun informasi timeline
  Widget _buildTimelineInfo(DateTime? submissionDate, DateTime? reviewDate) {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_tinySpacing),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: _smallIconSize,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: _tinySpacing),
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
              if (submissionDate != null)
                Text(
                  _formatRelativeDate(submissionDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          if (reviewDate != null) ...[
            const SizedBox(height: _tinySpacing),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: _smallIconSize,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: _tinySpacing),
                Text(
                  'Direview: ${_formatDate(reviewDate)}',
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
    );
  }

  /// Membangun ID pengajuan
  Widget _buildApplicationId(String id) {
    return Row(
      children: [
        Icon(
          Icons.tag_rounded,
          size: _microIconSize,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: _tinySpacing),
        Text(
          'ID Pengajuan: ${id.substring(0, min(12, id.length))}...',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// Membangun catatan admin
  Widget _buildAdminNotes(String notes) {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_smallSpacing),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_rounded,
                size: _smallIconSize,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: _tinySpacing),
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
          const SizedBox(height: _tinySpacing),
          Text(
            notes,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun organisasi program
  Widget _buildProgramOrganizer(Map<String, dynamic> programDetails) {
    final organizer = programDetails['organizer'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_tinySpacing),
      ),
      child: Row(
        children: [
          Icon(
            Icons.business_rounded,
            size: _microIconSize,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: _tinySpacing),
          Text(
            'Penyelenggara: $organizer',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  /// Memeriksa apakah pengajuan memiliki catatan
  bool _hasNotes(Map<String, dynamic> application) {
    return application['notes'] != null &&
        application['notes'].toString().isNotEmpty;
  }

  /// Memeriksa apakah pengajuan memiliki detail program
  bool _hasProgramDetails(Map<String, dynamic> application) {
    return application['programDetails'] is Map;
  }

  /// Mengembalikan nilai minimum dari dua angka
  int min(int a, int b) => a < b ? a : b;
}
