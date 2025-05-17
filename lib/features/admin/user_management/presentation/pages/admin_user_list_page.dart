import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Assuming go_router
import 'package:socio_care/core/navigation/route_names.dart'; // Adjust if needed
import '../widgets/admin_user_card_widget.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  // Placeholder data - replace with actual data fetching logic
  final List<Map<String, dynamic>> _allUsers = [
    {
      'id': 'user_001',
      'nama_lengkap': 'Budi Santoso',
      'email': 'budi.santoso@example.com',
      'lokasi': 'Jakarta',
      'penghasilan': 'Rp 5.000.000',
      'status': 'Terverifikasi',
    },
    {
      'id': 'user_002',
      'nama_lengkap': 'Siti Aminah',
      'email': 'siti.aminah@example.com',
      'lokasi': 'Bandung',
      'penghasilan': 'Rp 3.500.000',
      'status': 'Menunggu Verifikasi',
    },
    {
      'id': 'user_003',
      'nama_lengkap': 'Agus Dharmawan',
      'email': 'agus.d@example.com',
      'lokasi': 'Surabaya',
      'penghasilan': 'Rp 6.000.000',
      'status': 'Terverifikasi',
    },
    {
      'id': 'user_004',
      'nama_lengkap': 'Dewi Lestari',
      'email': 'dewi.l@example.com',
      'lokasi': 'Yogyakarta',
      'penghasilan': 'Rp 4.200.000',
      'status': 'Diblokir',
    },
    // Add more placeholder users
  ];

  List<Map<String, dynamic>> _filteredUsers = [];
  String _searchText = '';
  String? _selectedLocationFilter;
  String? _selectedStatusFilter;

  // Placeholder filter options
  final List<String> _locations = [
    'Semua Lokasi',
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Yogyakarta',
  ];
  final List<String> _statuses = [
    'Semua Status',
    'Terverifikasi',
    'Menunggu Verifikasi',
    'Diblokir',
  ];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
    _selectedLocationFilter = _locations.first;
    _selectedStatusFilter = _statuses.first;
  }

  void _filterUsers() {
    List<Map<String, dynamic>> users =
        _allUsers.where((user) {
          final nameLower = user['nama_lengkap'].toLowerCase();
          final emailLower = user['email'].toLowerCase();
          final searchTextLower = _searchText.toLowerCase();

          // Search filter
          final searchMatch =
              nameLower.contains(searchTextLower) ||
              emailLower.contains(searchTextLower);

          // Location filter
          final locationMatch =
              _selectedLocationFilter == _locations.first ||
              user['lokasi'] == _selectedLocationFilter;

          // Status filter
          final statusMatch =
              _selectedStatusFilter == _statuses.first ||
              user['status'] == _selectedStatusFilter;

          return searchMatch && locationMatch && statusMatch;
        }).toList();

    setState(() {
      _filteredUsers = users;
    });
  }

  void _editUser(String userId) {
    // TODO: Navigate to Edit User Page, passing the user ID
    context.go(
      '${RouteNames.adminEditUser}/$userId',
    ); // Example using go_router with parameter
  }

  void _deleteUser(String userId) {
    // TODO: Implement delete user logic (show confirmation dialog, call API)
    print('Attempting to delete user with ID: $userId');
    // Example: Remove from local list (for demonstration)
    setState(() {
      _allUsers.removeWhere((user) => user['id'] == userId);
      _filterUsers(); // Re-filter after deletion
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User $userId deleted (placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pengguna'),
        backgroundColor: Colors.blue.shade700, // Consistent color
        foregroundColor: Colors.white,
        leading: IconButton(
          // Back button to Admin Dashboard
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminDashboard); // Navigate back to dashboard
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade200,
            ], // Consistent gradient
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
                          items:
                              _locations.map((String location) {
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(location),
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
                          items:
                              _statuses.map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
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
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return AdminUserCardWidget(
                    user: user,
                    onEdit: () => _editUser(user['id']),
                    onDelete: () => _deleteUser(user['id']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
