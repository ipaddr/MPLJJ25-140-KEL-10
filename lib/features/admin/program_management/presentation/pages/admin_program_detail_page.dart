import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminProgramDetailPage extends StatefulWidget {
  final String programId; // To receive the program ID

  const AdminProgramDetailPage({super.key, required this.programId});

  @override
  State<AdminProgramDetailPage> createState() => _AdminProgramDetailPageState();
}

class _AdminProgramDetailPageState extends State<AdminProgramDetailPage> {
  // Placeholder data - replace with actual data fetching logic
  late Map<String, dynamic> _programData;
  bool _isActive = false; // To manage the toggle switch state

  // Controllers for form fields
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController =
      TextEditingController();
  final TextEditingController _caraPendaftaranController =
      TextEditingController();
  String? _selectedCategory; // For dropdown
  String? _selectedStatus; // For dropdown (optional if using toggle)

  // Placeholder categories and statuses for dropdowns
  final List<String> _categories = [
    'Pendidikan',
    'Kesehatan',
    'Pemberdayaan',
    'Sosial',
  ];
  final List<String> _statuses = [
    'Aktif',
    'Selesai',
    'Ditutup',
  ]; // If using status dropdown instead of toggle

  @override
  void initState() {
    super.initState();
    // TODO: Fetch program data based on widget.programId
    // Placeholder fetching logic:
    _programData = {
      'id': widget.programId,
      'nama_program': 'Nama Program ${widget.programId}',
      'deskripsi': 'Deskripsi lengkap untuk program ${widget.programId}.',
      'syarat_ketentuan':
          'Syarat & Ketentuan untuk program ${widget.programId}.',
      'cara_pendaftaran': 'Cara Pendaftaran untuk program ${widget.programId}.',
      'kategori': 'Pendidikan', // Example default/fetched value
      'status': 'Aktif', // Example default/fetched value
      'jumlah_pengajuan': 100, // Example
    };

    // Initialize controllers and state with fetched data
    _namaProgramController.text = _programData['nama_program'] ?? '';
    _deskripsiController.text = _programData['deskripsi'] ?? '';
    _syaratKetentuanController.text = _programData['syarat_ketentuan'] ?? '';
    _caraPendaftaranController.text = _programData['cara_pendaftaran'] ?? '';
    _selectedCategory = _programData['kategori'];
    _isActive = _programData['status'] == 'Aktif'; // Initialize toggle state
  }

  @override
  void dispose() {
    _namaProgramController.dispose();
    _deskripsiController.dispose();
    _syaratKetentuanController.dispose();
    _caraPendaftaranController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: Implement logic to save changes to the program
    print('Saving changes for program: ${widget.programId}');
    // Access updated data from controllers and state:
    print('Nama Program: ${_namaProgramController.text}');
    print('Deskripsi: ${_deskripsiController.text}');
    print('Syarat & Ketentuan: ${_syaratKetentuanController.text}');
    print('Cara Pendaftaran: ${_caraPendaftaranController.text}');
    print('Kategori: ${_selectedCategory}');
    print('Status Aktif: ${_isActive}'); // Get state from toggle

    // Call API to update program data
    // After successful save, maybe navigate back to program list
    // context.go(RouteNames.adminProgramList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved (placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Program: ${_programData['nama_program']}'),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Program Name
                TextFormField(
                  controller: _namaProgramController,
                  decoration: const InputDecoration(labelText: 'Nama Program'),
                  // TODO: Add validation
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
                  // TODO: Add validation
                ),
                const SizedBox(height: 16.0),
                // Program Status Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Aktif', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isActive,
                      onChanged: (newValue) {
                        setState(() {
                          _isActive = newValue;
                          // You might want to update the status string here based on the toggle
                          _programData['status'] =
                              _isActive ? 'Aktif' : 'Ditutup';
                        });
                      },
                      activeColor: Colors.green,
                      inactiveThumbColor: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Total Submissions (Display only)
                Text(
                  'Jumlah Pengajuan: ${_programData['jumlah_pengajuan'] ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                // Description
                TextFormField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Program',
                  ),
                  maxLines: null, // Allow multiple lines
                  // TODO: Add validation
                ),
                const SizedBox(height: 16.0),
                // Terms and Conditions
                TextFormField(
                  controller: _syaratKetentuanController,
                  decoration: const InputDecoration(
                    labelText: 'Syarat & Ketentuan',
                  ),
                  maxLines: null, // Allow multiple lines
                  // TODO: Add validation
                ),
                const SizedBox(height: 16.0),
                // How to Register
                TextFormField(
                  controller: _caraPendaftaranController,
                  decoration: const InputDecoration(
                    labelText: 'Cara Pendaftaran',
                  ),
                  maxLines: null, // Allow multiple lines
                  // TODO: Add validation
                ),
                const SizedBox(height: 24.0),
                // Save Button
                ElevatedButton(
                  onPressed: _saveChanges,
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
                  child: const Text('Simpan Perubahan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
