import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminAddProgramPage extends StatefulWidget {
  const AdminAddProgramPage({super.key});

  @override
  State<AdminAddProgramPage> createState() => _AdminAddProgramPageState();
}

class _AdminAddProgramPageState extends State<AdminAddProgramPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController =
      TextEditingController();
  final TextEditingController _caraPendaftaranController =
      TextEditingController();
  String? _selectedCategory;

  // Placeholder categories for dropdown
  final List<String> _categories = [
    'Pendidikan',
    'Kesehatan',
    'Pemberdayaan',
    'Sosial',
  ];

  @override
  void dispose() {
    _namaProgramController.dispose();
    _deskripsiController.dispose();
    _syaratKetentuanController.dispose();
    _caraPendaftaranController.dispose();
    super.dispose();
  }

  void _addProgram() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement logic to add a new program
      print('Adding new program: ${_namaProgramController.text}');
      print('Category: $_selectedCategory');
      // Call API to create new program

      // After successful creation, navigate back to the program list
      // context.go(RouteNames.adminProgramList);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding program (placeholder)')),
      );
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
          // Back button to Program List Page
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminProgramList); // Navigate back
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
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama Program tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori Program',
                    ),
                    value: _selectedCategory,
                    items:
                        _categories.map((String category) {
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
                  // Description
                  TextFormField(
                    controller: _deskripsiController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi Program',
                    ),
                    maxLines: null, // Allow multiple lines
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
                    ),
                    maxLines: null, // Allow multiple lines
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Syarat & Ketentuan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // How to Register
                  TextFormField(
                    controller: _caraPendaftaranController,
                    decoration: const InputDecoration(
                      labelText: 'Cara Pendaftaran',
                    ),
                    maxLines: null, // Allow multiple lines
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cara Pendaftaran tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  // Add Program Button
                  ElevatedButton(
                    onPressed: _addProgram,
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
                    child: const Text('Tambah Program'),
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
