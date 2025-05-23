import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';
import 'dart:io';

class AdminAddProgramPage extends StatefulWidget {
  const AdminAddProgramPage({super.key});

  @override
  State<AdminAddProgramPage> createState() => _AdminAddProgramPageState();
}

class _AdminAddProgramPageState extends State<AdminAddProgramPage> {
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController = TextEditingController();
  final TextEditingController _caraPendaftaranController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedStatus = 'active';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _categories = [
    'Kesehatan',
    'Pendidikan',
    'Modal Usaha',
    'Makanan Pokok',
  ];

  final List<String> _statuses = [
    'active',
    'inactive',
    'upcoming',
  ];

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _addProgram() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final programId = await _programService.createProgram(
          programName: _namaProgramController.text.trim(),
          organizer: _organizerController.text.trim(),
          targetAudience: _targetAudienceController.text.trim(),
          category: _selectedCategory!,
          description: _deskripsiController.text.trim(),
          termsAndConditions: _syaratKetentuanController.text.trim(),
          registrationGuide: _caraPendaftaranController.text.trim(),
          status: _selectedStatus!,
          imageFile: _selectedImage,
        );

        if (programId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Program berhasil ditambahkan')),
          );
          context.go(RouteNames.adminProgramList);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menambahkan program')),
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
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'upcoming':
        return 'Akan Datang';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Program Baru'),
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
                  
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori Program',
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
                        return 'Pilih Kategori Program';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status Program',
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
                  
                  // Image Upload
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
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Gambar dipilih: ${_selectedImage!.path.split('/').last}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: _pickImage,
                            child: const Text('Ganti'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24.0),
                  
                  // Add Program Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _addProgram,
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
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Tambah Program'),
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