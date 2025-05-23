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

class _AdminUserListPageState extends State<AdminUserListPage> {
  final AdminUserService _userService = AdminUserService();
  
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<String> _locations = ['Semua Lokasi'];
  String _searchText = '';
  String? _selectedLocationFilter;
  String? _selectedStatusFilter;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _statuses = [
    'Semua Status',
    'active',
    'pending_verification',
    'suspended',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocationFilter = _locations.first;
    _selectedStatusFilter = _statuses.first;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load users and locations concurrently
      final results = await Future.wait([
        _userService.getAllUsers(),
        _userService.getUserLocations(),
      ]);

      final users = results[0] as List<Map<String, dynamic>>;
      final locations = results[1] as List<String>;

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _locations = locations;
        if (!_locations.contains(_selectedLocationFilter)) {
          _selectedLocationFilter = _locations.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    List<Map<String, dynamic>> users = _allUsers.where((user) {
      final nameLower = _safeGetString(user, 'fullName').toLowerCase();
      final emailLower = _safeGetString(user, 'email').toLowerCase();
      final searchTextLower = _searchText.toLowerCase();

      // Search filter
      final searchMatch = nameLower.contains(searchTextLower) || emailLower.contains(searchTextLower);

      // Location filter
      final locationMatch = _selectedLocationFilter == _locations.first ||
          _safeGetString(user, 'location') == _selectedLocationFilter;

      // Status filter
      final statusMatch = _selectedStatusFilter == _statuses.first ||
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
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini?\n\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _userService.deleteUser(userId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengguna berhasil dihapus')),
          );
          await _loadUsers(); // Reload users
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus pengguna')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadUsers,
          ),
        ],
      ),
      drawer: const AdminNavigationDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari Nama atau Email Pengguna',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                      _filterUsers();
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Filters (Location and Status)
                  Row(
                    children: [
                      // Location Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Lokasi',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          value: _selectedLocationFilter,
                          items: _locations.map((String location) {
                            return DropdownMenuItem<String>(
                              value: location,
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedLocationFilter = newValue;
                            });
                            _filterUsers();
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // Status Filter
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Status Akun',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                          ),
                          value: _selectedStatusFilter,
                          items: _statuses.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status == 'Semua Status' 
                                  ? status 
                                  : _getStatusDisplayName(status)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedStatusFilter = newValue;
                            });
                            _filterUsers();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // User List
            Expanded(
              child: _isLoading
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
                                onPressed: _loadUsers,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada pengguna yang ditemukan',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadUsers,
                              child: ListView.builder(
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return AdminUserCardWidget(
                                    user: {
                                      'id': _safeGetString(user, 'id'),
                                      'nama_lengkap': _safeGetString(user, 'fullName'),
                                      'email': _safeGetString(user, 'email'),
                                      'lokasi': _safeGetString(user, 'location'),
                                      'penghasilan': _formatCurrency(_safeGetInt(user, 'monthlyIncome')),
                                      'status': _getStatusDisplayName(_safeGetString(user, 'accountStatus')),
                                      'phone_number': _safeGetString(user, 'phoneNumber'),
                                      'nik': _safeGetString(user, 'nik'),
                                      'job_type': _safeGetString(user, 'jobType'),
                                      'created_at': user['createdAt'],
                                      'last_login': user['lastLogin'],
                                    },
                                    onEdit: () => _editUser(_safeGetString(user, 'id')),
                                    onDelete: () => _deleteUser(_safeGetString(user, 'id')),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}