import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_user_service.dart';
import 'package:intl/intl.dart';

class AdminEditUserPage extends StatefulWidget {
  final String userId;

  const AdminEditUserPage({super.key, required this.userId});

  @override
  State<AdminEditUserPage> createState() => _AdminEditUserPageState();
}

class _AdminEditUserPageState extends State<AdminEditUserPage> {
  final AdminUserService _userService = AdminUserService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _jobTypeController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  
  String? _selectedStatus;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _statuses = [
    'active',
    'pending_verification',
    'suspended',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _nikController.dispose();
    _jobTypeController.dispose();
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  // Safe parsing methods
  String _safeGetString(Map<String, dynamic>? data, String key) {
    if (data == null) return '';
    final value = data[key];
    if (value == null) return '';
    return value.toString();
  }

  int _safeGetInt(Map<String, dynamic>? data, String key) {
    if (data == null) return 0;
    final value = data[key];
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await _userService.getUserById(widget.userId);
      
      if (userData != null) {
        setState(() {
          _userData = userData;
          _fullNameController.text = _safeGetString(userData, 'fullName');
          _emailController.text = _safeGetString(userData, 'email');
          _phoneController.text = _safeGetString(userData, 'phoneNumber');
          _locationController.text = _safeGetString(userData, 'location');
          _nikController.text = _safeGetString(userData, 'nik');
          _jobTypeController.text = _safeGetString(userData, 'jobType');
          _monthlyIncomeController.text = _safeGetInt(userData, 'monthlyIncome').toString();
          
          // Safely set the status with validation
          final userStatus = _safeGetString(userData, 'accountStatus');
          if (userStatus.isEmpty || !_statuses.contains(userStatus)) {
            _selectedStatus = 'pending_verification'; // Default value
          } else {
            _selectedStatus = userStatus;
          }
          
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Pengguna tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data pengguna: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Parse monthly income safely
        final monthlyIncomeText = _monthlyIncomeController.text.trim();
        final monthlyIncome = int.tryParse(monthlyIncomeText) ?? 0;

        final success = await _userService.updateUser(
          userId: widget.userId,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          nik: _nikController.text.trim(),
          jobType: _jobTypeController.text.trim(),
          monthlyIncome: monthlyIncome,
          accountStatus: _selectedStatus!,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data pengguna berhasil diperbarui')),
          );
          context.go(RouteNames.adminUserList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui data pengguna')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isSaving = false;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Pengguna'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Pengguna'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.adminUserList),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${_safeGetString(_userData, 'fullName')}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.adminUserList),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Pengguna',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('ID: ${widget.userId}'),
                          Text('Terdaftar: ${_userData!['createdAt'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(_userData!['createdAt'].toDate()) : 'N/A'}'),
                          Text('Login Terakhir: ${_userData!['lastLogin'] != null ? DateFormat('dd MMM yyyy, HH:mm').format(_userData!['lastLogin'].toDate()) : 'Belum pernah login'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama lengkap tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@')) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Phone Number
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor telepon tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Lokasi',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lokasi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // NIK
                  TextFormField(
                    controller: _nikController,
                    decoration: const InputDecoration(
                      labelText: 'NIK',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'NIK tidak boleh kosong';
                      }
                      if (value.length != 16) {
                        return 'NIK harus 16 digit';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Job Type
                  TextFormField(
                    controller: _jobTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Pekerjaan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jenis pekerjaan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Monthly Income
                  TextFormField(
                    controller: _monthlyIncomeController,
                    decoration: const InputDecoration(
                      labelText: 'Penghasilan Bulanan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Penghasilan bulanan tidak boleh kosong';
                      }
                      final parsedValue = int.tryParse(value.trim());
                      if (parsedValue == null) {
                        return 'Masukkan angka yang valid';
                      }
                      if (parsedValue < 0) {
                        return 'Penghasilan tidak boleh negatif';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Account Status - Fixed dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status Akun',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedStatus,
                    items: _statuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(_getStatusDisplayName(status)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih status akun';
                      }
                      if (!_statuses.contains(value)) {
                        return 'Status tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Simpan Perubahan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}