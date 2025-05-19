import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart'; // For image upload (add dependency)
import 'dart:io';

import 'package:socio_care/core/navigation/route_names.dart'; // For File

class AdminContentEditorPage extends StatefulWidget {
  final String? contentId; // Null for new content, ID for editing

  const AdminContentEditorPage({super.key, this.contentId});

  @override
  State<AdminContentEditorPage> createState() => _AdminContentEditorPageState();
}

class _AdminContentEditorPageState extends State<AdminContentEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController =
      TextEditingController(); // Simple text editor
  String? _selectedStatus;
  File? _selectedImage; // For image upload

  // Placeholder statuses for dropdown
  final List<String> _statuses = ['Draf', 'Dipublikasikan', 'Diarsip'];

  bool get _isEditing => widget.contentId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // TODO: Fetch content data based on widget.contentId
      // Placeholder fetching logic:
      final Map<String, dynamic> fetchedContent = {
        'id': widget.contentId,
        'title': 'Judul Konten ${widget.contentId}',
        'content':
            'Ini adalah isi konten ${widget.contentId}.\n\nParagraf kedua.',
        'status': 'Dipublikasikan', // Example fetched status
        // 'image_url': 'some_image_url.jpg', // Example if you have image URLs
      };

      _titleController.text = fetchedContent['title'] ?? '';
      _contentController.text = fetchedContent['content'] ?? '';
      _selectedStatus = fetchedContent['status'];
      // TODO: Handle fetching existing image if applicable
    } else {
      // Default for new content
      _selectedStatus = 'Draf';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveContent() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement logic to save or update content
      print('Saving content...');
      print('Title: ${_titleController.text}');
      print('Content: ${_contentController.text}');
      print('Status: $_selectedStatus');

      // TODO: Handle image upload (_selectedImage)
      if (_selectedImage != null) {
        print('Image selected: ${_selectedImage!.path}');
        // Upload image to storage and get URL
      }

      if (_isEditing) {
        // Call API to update existing content (use widget.contentId)
        print('Updating content with ID: ${widget.contentId}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Updating content (placeholder)')),
        );
      } else {
        // Call API to create new content
        print('Creating new content');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating new content (placeholder)')),
        );
      }

      // After successful save, navigate back to the content list
      // context.go(RouteNames.adminContentManagement); // Adjust route name
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Konten Edukasi' : 'Tambah Konten Baru'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          // Back button to Content List Page
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // TODO: Consider showing a confirmation dialog if there are unsaved changes
            context.go(RouteNames.adminEducationContent); // Navigate back
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
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Konten',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status Konten',
                    ),
                    value: _selectedStatus,
                    items:
                        _statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih Status Konten';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Content Editor (Simple TextFormField for now)
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Konten',
                      hintText:
                          'Masukkan isi artikel atau konten edukasi di sini...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10, // Allow multiple lines and height
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Isi Konten tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Image Upload
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gambar Pendukung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child:
                              _selectedImage != null
                                  ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          size: 40,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Unggah Gambar',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Gambar terpilih: ${_selectedImage!.path.split('/').last}',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveContent,
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
                    child: Text(
                      _isEditing ? 'Simpan Perubahan' : 'Publikasikan Konten',
                    ), // Button text changes based on mode
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
