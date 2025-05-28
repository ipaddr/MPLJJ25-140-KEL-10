import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import '../widgets/admin_user_card_widget.dart';
import '../../data/admin_user_service.dart';
import 'package:intl/intl.dart';

/// Page for displaying and managing user accounts in admin panel
///
/// Provides functionality to view, filter, search, edit, and delete users
/// as well as displaying statistics about user status counts.
class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage>
    with TickerProviderStateMixin {
  // Services and keys
  final AdminUserService _userService = AdminUserService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // UI Constants
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _miniSpacing = 8.0;

  static const double _borderRadius = 24.0;
  static const double _mediumBorderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;
  static const double _miniBorderRadius = 8.0;

  static const double _titleFontSize = 24.0;
  static const double _subtitleFontSize = 18.0;
  static const double _bodyFontSize = 16.0;
  static const double _smallFontSize = 14.0;
  static const double _captionFontSize = 12.0;

  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;

  // State variables
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<String> _locations = ['Semua Lokasi'];
  Map<String, int> _statusCounts = {};
  String _searchText = '';
  String? _selectedLocationFilter;
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Status options as proper objects for better type safety
  final List<StatusOption> _statusOptions = [
    StatusOption('Semua Status', Icons.all_inclusive_rounded, Colors.grey),
    StatusOption('active', Icons.verified_user_rounded, Colors.green),
    StatusOption(
      'pending_verification',
      Icons.hourglass_empty_rounded,
      Colors.orange,
    ),
    StatusOption('suspended', Icons.block_rounded, Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocationFilter = _locations.first;
    _selectedStatusFilter = _statusOptions.first.value;
    _initializeAnimations();
    _loadUsers();
  }

  /// Initialize animation controllers and animations
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

  /// Load all user data and related information
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all data in parallel for better performance
      final results = await Future.wait([
        _userService.getAllUsers(),
        _userService.getUserLocations(),
        _userService.getUsersCountByStatus(),
      ]);

      if (mounted) {
        setState(() {
          _allUsers = results[0] as List<Map<String, dynamic>>;
          _filteredUsers = _allUsers;
          _locations = results[1] as List<String>;
          _statusCounts = results[2] as Map<String, int>;

          // Ensure selected location is in the list
          if (!_locations.contains(_selectedLocationFilter)) {
            _selectedLocationFilter = _locations.first;
          }
          _isLoading = false;
        });

        // Start animations
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Filter users based on search text, location, and status
  void _filterUsers() {
    if (!mounted) return;

    final searchTextLower = _searchText.toLowerCase();
    final isLocationAll = _selectedLocationFilter == _locations.first;
    final isStatusAll = _selectedStatusFilter == _statusOptions.first.value;

    final filteredUsers =
        _allUsers.where((user) {
          // Search filter
          final nameLower = _safeGetString(user, 'fullName').toLowerCase();
          final emailLower = _safeGetString(user, 'email').toLowerCase();
          final searchMatch =
              nameLower.contains(searchTextLower) ||
              emailLower.contains(searchTextLower);

          // Location filter
          final locationMatch =
              isLocationAll ||
              _safeGetString(user, 'location') == _selectedLocationFilter;

          // Status filter
          final statusMatch =
              isStatusAll ||
              _safeGetString(user, 'accountStatus') == _selectedStatusFilter;

          return searchMatch && locationMatch && statusMatch;
        }).toList();

    setState(() {
      _filteredUsers = filteredUsers;
    });
  }

  /// Safely get string value from map, with default value if not found
  String _safeGetString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  /// Safely get int value from map, with conversion from various types
  int _safeGetInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Navigate to user edit page
  void _editUser(String userId) {
    context.go('${RouteNames.adminEditUser}/$userId');
  }

  /// Show confirmation dialog and delete user if confirmed
  Future<void> _deleteUser(String userId) async {
    final confirmed = await _showDeleteConfirmationDialog();

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        final success = await _userService.deleteUser(userId);
        if (success && mounted) {
          _showSuccessSnackBar('Pengguna berhasil dihapus');
          await _loadUsers();
        } else if (mounted) {
          _showErrorSnackBar('Gagal menghapus pengguna');
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_mediumBorderRadius),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(_microSpacing),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(_microSpacing),
                  ),
                  child: Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: _smallSpacing),
                const Expanded(child: Text('Konfirmasi Hapus')),
              ],
            ),
            content: Container(
              padding: const EdgeInsets.all(_smallSpacing),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(_microSpacing),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'Apakah Anda yakin ingin menghapus pengguna ini?\n\nTindakan ini tidak dapat dibatalkan.',
                style: TextStyle(fontSize: _bodyFontSize),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  size: _microIconSize + 2,
                ),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_microSpacing),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /// Show success message in a snackbar
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: _miniSpacing),
            Text(message),
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

  /// Show error message in a snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
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

  /// Get user-friendly display name for status values
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

  /// Format number as Indonesian currency
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

  /// Build the custom app bar at the top of the page
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
                  'Manajemen Pengguna',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Kelola data pengguna aplikasi',
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
            onPressed: _isLoading ? null : _loadUsers,
          ),
        ],
      ),
    );
  }

  /// Build app bar button with consistent styling
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

  /// Build loading indicator widget
  Widget _buildLoadingWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_midSpacing),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Colors.blue.shade600,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: _spacing),
            Text(
              'Memuat data pengguna...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: _bodyFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error message widget
  Widget _buildErrorWidget() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(_spacing + 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(_spacing),
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
              const SizedBox(height: _spacing),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: _subtitleFontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: _microSpacing),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: _smallFontSize,
                ),
              ),
              const SizedBox(height: _spacing + 8),
              ElevatedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: _spacing,
                    vertical: _microSpacing,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_microSpacing),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build main content area with stats, filters, and list
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Column(
        children: [
          _buildStatsSection(),
          _buildFiltersSection(),
          Expanded(child: _buildUsersList()),
          // Extra space at bottom for better scrolling experience
          const SizedBox(height: _midSpacing),
        ],
      ),
    );
  }

  /// Build statistics section with status cards
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(_spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.blue.shade700),
              const SizedBox(width: _miniSpacing),
              const Text(
                'Statistik Pengguna',
                style: TextStyle(
                  fontSize: _subtitleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _statusOptions
                      .skip(1) // Skip "All Status" option
                      .map(_buildStatCard)
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual statistics card
  Widget _buildStatCard(StatusOption status) {
    final count = _statusCounts[status.value] ?? 0;

    return Container(
      margin: const EdgeInsets.only(right: _microSpacing),
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status.color.withOpacity(0.1),
            status.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(_miniSpacing),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(_miniBorderRadius),
            ),
            child: Icon(status.icon, color: Colors.white, size: _smallIconSize),
          ),
          const SizedBox(height: _miniSpacing),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: _midSpacing,
              fontWeight: FontWeight.bold,
              color: status.color,
            ),
          ),
          Text(
            _getStatusDisplayName(status.value),
            style: TextStyle(
              fontSize: _captionFontSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build filters section with search and dropdowns
  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _spacing,
        vertical: _smallSpacing,
      ),
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
              const SizedBox(width: _miniSpacing),
              Text(
                'Filter & Pencarian',
                style: TextStyle(
                  fontSize: _bodyFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: _smallSpacing),

          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: _smallSpacing),

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
              const SizedBox(width: _smallSpacing),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Status',
                  value: _selectedStatusFilter,
                  items: _statusOptions.map((s) => s.value).toList(),
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

  /// Build search bar with consistent styling
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_microSpacing),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari nama atau email pengguna...',
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: _smallSpacing,
            vertical: _smallSpacing,
          ),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        onChanged: (value) {
          setState(() => _searchText = value);
          _filterUsers();
        },
      ),
    );
  }

  /// Build dropdown filter with consistent styling
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
          borderRadius: BorderRadius.circular(_microSpacing),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microSpacing),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _smallSpacing,
          vertical: _microSpacing,
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
                    style: const TextStyle(fontSize: _smallFontSize),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  /// Build users list with refresh indicator
  Widget _buildUsersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredUsers.isEmpty) {
      return _buildEmptyUsersMessage();
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          _smallSpacing,
          _smallSpacing,
          _smallSpacing,
          _spacing + 8,
        ),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  /// Build empty state message when no users match filters
  Widget _buildEmptyUsersMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_spacing + 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_spacing),
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
            const SizedBox(height: _spacing),
            Text(
              'Tidak ada pengguna',
              style: TextStyle(
                fontSize: _subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: _miniSpacing),
            Text(
              'Belum ada pengguna yang sesuai dengan filter yang dipilih',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: _smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual user card
  Widget _buildUserCard(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _microSpacing),
      child: AdminUserCardWidget(
        user: {
          'id': _safeGetString(user, 'id'),
          'nama_lengkap': _safeGetString(user, 'fullName'),
          'email': _safeGetString(user, 'email'),
          'lokasi': _safeGetString(user, 'location'),
          'penghasilan': _formatCurrency(_safeGetInt(user, 'monthlyIncome')),
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
  }
}

/// Status option data class for improved type safety
class StatusOption {
  final String value;
  final IconData icon;
  final Color color;

  const StatusOption(this.value, this.icon, this.color);
}
