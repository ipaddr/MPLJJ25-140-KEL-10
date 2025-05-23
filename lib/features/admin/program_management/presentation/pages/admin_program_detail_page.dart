import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';
import 'dart:io';

class AdminProgramDetailPage extends StatefulWidget {
  final String programId;

  const AdminProgramDetailPage({super.key, required this.programId});

  @override
  State<AdminProgramDetailPage> createState() => _AdminProgramDetailPageState();
}

class _AdminProgramDetailPageState extends State<AdminProgramDetailPage> {
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController = TextEditingController();
  final TextEditingController _caraPendaftaranController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedStatus;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _programData;

  final List<String> _categories = [
    'Kesehatan',
    'Pendidikan',
    'Modal Usaha',
    'Makanan Pokok',
  ];

  final List<String> _statuses = [
    'active',
    'inactive',
    'closed',
    'upcoming',
  ];

  @override
  void initState() {
    super.initState();
    _loadProgramData();
  }

  @override
  void dispose() {
    _namaProgramController.dispose();
    _organizerController.dispose();
    _targetAudienceController.dispose();
    _deskripsiController.dispose();
    _syaratKetentuanController.dispose();
    _caraPendaftaranController.dispose();
    super.dispose();
  }

  Future<void> _loadProgramData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final programData = await _programService.getProgramById(widget.programId);
      
      if (programData != null) {
        // Debug print to see what we get from Firebase
        print('Program data from Firebase: $programData');
        
        setState(() {
          _programData = programData;
          _namaProgramController.text = programData['programName'] ?? '';
          _organizerController.text = programData['organizer'] ?? '';
          _targetAudienceController.text = programData['targetAudience'] ?? '';
          _deskripsiController.text = programData['description'] ?? '';
          _syaratKetentuanController.text = programData['termsAndConditions'] ?? '';
          _caraPendaftaranController.text = programData['registrationGuide'] ?? '';
          
          // Safely set category and status with validation
          final categoryFromFirebase = programData['category']?.toString() ?? '';
          if (_categories.contains(categoryFromFirebase)) {
            _selectedCategory = categoryFromFirebase;
          } else {
            print('Warning: Category "$categoryFromFirebase" not found in available categories');
            _selectedCategory = _categories.first; // Set to first category as default
          }
          
          final statusFromFirebase = programData['status']?.toString() ?? '';
          if (_statuses.contains(statusFromFirebase)) {
            _selectedStatus = statusFromFirebase;
          } else {
            print('Warning: Status "$statusFromFirebase" not found in available statuses');
            _selectedStatus = _statuses.first; // Set to first status as default
          }
          
          _existingImageUrl = programData['imageUrl']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program tidak ditemukan')),
        );
        context.go(RouteNames.adminProgramList);
      }
    } catch (e) {
      print('Error loading program data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      context.go(RouteNames.adminProgramList);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await _programService.updateProgram(
          programId: widget.programId,
          programName: _namaProgramController.text.trim(),
          organizer: _organizerController.text.trim(),
          targetAudience: _targetAudienceController.text.trim(),
          category: _selectedCategory!,
          description: _deskripsiController.text.trim(),
          termsAndConditions: _syaratKetentuanController.text.trim(),
          registrationGuide: _caraPendaftaranController.text.trim(),
          status: _selectedStatus!,
          imageFile: _selectedImage,
          existingImageUrl: _existingImageUrl,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program berhasil diperbarui')),
          );
          context.go(RouteNames.adminProgramList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memperbarui program')),
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
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'closed':
        return 'Ditutup';
      case 'upcoming':
        return 'Akan Datang';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Program'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Program: ${_programData?['programName'] ?? ''}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.adminProgramList),
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
                  // Statistics Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Statistik Program',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '${_programData?['totalApplications'] ?? 0}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                  const Text('Total Pengajuan'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    _getStatusDisplayName(_selectedStatus ?? ''),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedStatus == 'active' ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                  const Text('Status'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Program Name
                  TextFormField(
                    controller: _namaProgramController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Program',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Program tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Organizer
                  TextFormField(
                    controller: _organizerController,
                    decoration: const InputDecoration(
                      labelText: 'Penyelenggara',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Penyelenggara tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Target Audience
                  TextFormField(
                    controller: _targetAudienceController,
                    decoration: const InputDecoration(
                      labelText: 'Target Penerima',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Target Penerima tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Category and Status Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedCategory,
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategory = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Pilih Kategori';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Status',
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Description
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Program',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Deskripsi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Terms and Conditions
                  TextFormField(
                    controller: _syaratKetentuanController,
                    decoration: const InputDecoration(
                      labelText: 'Syarat & Ketentuan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Syarat & Ketentuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Registration Guide
                  TextFormField(
                    controller: _caraPendaftaranController,
                    decoration: const InputDecoration(
                      labelText: 'Panduan Pendaftaran',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Panduan Pendaftaran tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Image Upload/Display
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(Icons.error, size: 50, color: Colors.grey),
                                    );
                                  },
                                ),
                              )
                            : InkWell(
                                onTap: _pickImage,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('Tambah Gambar Program', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImage != null
                              ? 'Gambar baru dipilih: ${_selectedImage!.path.split('/').last}'
                              : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                                  ? 'Gambar saat ini tersedia'
                                  : 'Belum ada gambar',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickImage,
                        child: Text(_selectedImage != null || (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) 
                            ? 'Ganti' : 'Pilih'),
                      ),
                    ],
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