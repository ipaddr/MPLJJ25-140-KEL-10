import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_user_card_widget.dart';
import '../../data/admin_user_service.dart';
import 'package:intl/intl.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage>
    with TickerProviderStateMixin {
  final AdminUserService _userService = AdminUserService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<String> _locations = ['Semua Lokasi'];
  Map<String, int> _statusCounts = {};
  String _searchText = '';
  String? _selectedLocationFilter;
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _statuses = [
    {
      'value': 'Semua Status',
      'icon': Icons.all_inclusive_rounded,
      'color': Colors.grey,
    },
    {
      'value': 'active',
      'icon': Icons.verified_user_rounded,
      'color': Colors.green,
    },
    {
      'value': 'pending_verification',
      'icon': Icons.hourglass_empty_rounded,
      'color': Colors.orange,
    },
    {'value': 'suspended', 'icon': Icons.block_rounded, 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocationFilter = _locations.first;
    _selectedStatusFilter = _statuses.first['value'];
    _initializeAnimations();
    _loadUsers();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _userService.getAllUsers(),
        _userService.getUserLocations(),
        _userService.getUsersCountByStatus(),
      ]);

      final users = results[0] as List<Map<String, dynamic>>;
      final locations = results[1] as List<String>;
      final statusCounts = results[2] as Map<String, int>;

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _locations = locations;
        _statusCounts = statusCounts;
        if (!_locations.contains(_selectedLocationFilter)) {
          _selectedLocationFilter = _locations.first;
        }
        _isLoading = false;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    List<Map<String, dynamic>> users =
        _allUsers.where((user) {
          final nameLower = _safeGetString(user, 'fullName').toLowerCase();
          final emailLower = _safeGetString(user, 'email').toLowerCase();
          final searchTextLower = _searchText.toLowerCase();

          final searchMatch =
              nameLower.contains(searchTextLower) ||
              emailLower.contains(searchTextLower);
          final locationMatch =
              _selectedLocationFilter == _locations.first ||
              _safeGetString(user, 'location') == _selectedLocationFilter;
          final statusMatch =
              _selectedStatusFilter == _statuses.first['value'] ||
              _safeGetString(user, 'accountStatus') == _selectedStatusFilter;

          return searchMatch && locationMatch && statusMatch;
        }).toList();

    setState(() {
      _filteredUsers = users;
    });
  }

  String _safeGetString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  int _safeGetInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  void _editUser(String userId) {
    context.go('${RouteNames.adminEditUser}/$userId');
  }

  Future<void> _deleteUser(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(child: Text('Konfirmasi Hapus')),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'Apakah Anda yakin ingin menghapus pengguna ini?\n\nTindakan ini tidak dapat dibatalkan.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: const Text('Hapus'),
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
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final success = await _userService.deleteUser(userId);
        if (success) {
          _showSuccessSnackBar('Pengguna berhasil dihapus');
          await _loadUsers();
        } else {
          _showErrorSnackBar('Gagal menghapus pengguna');
        }
      } catch (e) {
        _showErrorSnackBar('Error: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'active':
        return 'Terverifikasi';
      case 'pending_verification':
        return 'Menunggu Verifikasi';
      case 'suspended':
        return 'Ditangguhkan';
      default:
        return status;
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(),
              Expanded(
                child:
                    _isLoading && _filteredUsers.isEmpty
                        ? _buildLoadingWidget()
                        : _errorMessage != null
                        ? _buildErrorWidget()
                        : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildContentArea(),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
      drawer: const AdminNavigationDrawer(),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola data pengguna aplikasi',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _isLoading ? null : _loadUsers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Colors.blue.shade600,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Memuat data pengguna...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildStatsSection(),
          _buildFiltersSection(),
          Expanded(child: _buildUsersList()),
          // ✅ ADDED: Extra space at bottom for better scrolling experience
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              const Text(
                'Statistik Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _statuses.skip(1).map((status) {
                    final count = _statusCounts[status['value']] ?? 0;
                    final color = status['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.1),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              status['icon'] as IconData,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            _getStatusDisplayName(status['value']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list_rounded, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Filter & Pencarian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau email pengguna...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
                _filterUsers();
              },
            ),
          ),
          const SizedBox(height: 16),

          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Lokasi',
                  value: _selectedLocationFilter,
                  items: _locations,
                  onChanged: (value) {
                    setState(() => _selectedLocationFilter = value);
                    _filterUsers();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  items: _statuses.map((s) => s['value'] as String).toList(),
                  onChanged: (value) {
                    setState(() => _selectedStatusFilter = value);
                    _filterUsers();
                  },
                  displayNameMapper:
                      (value) =>
                          value == 'Semua Status'
                              ? value
                              : _getStatusDisplayName(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String Function(String)? displayNameMapper,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    displayNameMapper?.call(item) ?? item,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_outline_rounded,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada pengguna',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Belum ada pengguna yang sesuai dengan filter yang dipilih',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          32,
        ), // ✅ INCREASED: Added extra bottom padding
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ), // ✅ ADDED: Space between cards
            child: AdminUserCardWidget(
              user: {
                'id': _safeGetString(user, 'id'),
                'nama_lengkap': _safeGetString(user, 'fullName'),
                'email': _safeGetString(user, 'email'),
                'lokasi': _safeGetString(user, 'location'),
                'penghasilan': _formatCurrency(
                  _safeGetInt(user, 'monthlyIncome'),
                ),
                'status': _getStatusDisplayName(
                  _safeGetString(user, 'accountStatus'),
                ),
                'phone_number': _safeGetString(user, 'phoneNumber'),
                'nik': _safeGetString(user, 'nik'),
                'job_type': _safeGetString(user, 'jobType'),
                'created_at': user['createdAt'],
                'last_login': user['lastLogin'],
              },
              onEdit: () => _editUser(_safeGetString(user, 'id')),
              onDelete: () => _deleteUser(_safeGetString(user, 'id')),
            ),
          );
        },
      ),
    );
  }
}
