import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_content_service.dart';
import '../../data/models/content_model.dart';

class AdminContentEditorPage extends StatefulWidget {
  final String? contentId;

  const AdminContentEditorPage({super.key, this.contentId});

  @override
  State<AdminContentEditorPage> createState() => _AdminContentEditorPageState();
}

class _AdminContentEditorPageState extends State<AdminContentEditorPage> {
  final AdminContentService _contentService = AdminContentService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String? _selectedStatus;
  File? _selectedImage;
  String? _existingImageUrl;
  ContentModel? _existingContent;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _statuses = ['Draf', 'Dipublikasikan', 'Diarsip'];

  bool get _isEditing => widget.contentId != null;

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'Draf';
    if (_isEditing) {
      _loadContent();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await _contentService.getContentById(widget.contentId!);

      if (content != null) {
        setState(() {
          _existingContent = content;
          _titleController.text = content.title;
          _contentController.text = content.content;
          _selectedStatus = AdminContentService.getStatusDisplayName(
            content.status,
          );
          _existingImageUrl = content.imageUrl;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Konten tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat konten: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _saveContent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final statusValue = AdminContentService.getStatusValue(
          _selectedStatus!,
        );
        bool success;

        if (_isEditing) {
          success = await _contentService.updateContent(
            contentId: widget.contentId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            status: statusValue,
            imageFile: _selectedImage,
            existingImageUrl: _existingImageUrl,
          );
        } else {
          final contentId = await _contentService.createContent(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            status: statusValue,
            imageFile: _selectedImage,
          );
          success = contentId != null;
        }

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Konten berhasil diperbarui'
                    : 'Konten berhasil dibuat',
              ),
            ),
          );
          context.go(RouteNames.adminEducationContent);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Gagal memperbarui konten'
                    : 'Gagal membuat konten',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Memuat Konten...'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
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
                onPressed: () => context.go(RouteNames.adminEducationContent),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Konten Edukasi' : 'Tambah Konten Baru'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminEducationContent);
          },
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
                  // Content Info Card (if editing)
                  if (_isEditing && _existingContent != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Konten',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('ID: ${_existingContent!.id}'),
                            Text('Penulis: ${_existingContent!.authorName}'),
                            Text('Dibuat: ${_existingContent!.createdAt}'),
                            Text('Diperbarui: ${_existingContent!.updatedAt}'),
                            Text(
                              'Dilihat: ${_existingContent!.viewCount} kali',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],

                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Konten',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      if (value.trim().length < 5) {
                        return 'Judul minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status Konten',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
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

                  // Content Editor
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Konten',
                      hintText:
                          'Masukkan isi artikel atau konten edukasi di sini...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 12,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Isi Konten tidak boleh kosong';
                      }
                      if (value.trim().length < 50) {
                        return 'Isi konten minimal 50 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Image Upload Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
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

                          // Current image display
                          if (_selectedImage != null ||
                              _existingImageUrl != null) ...[
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    _selectedImage != null
                                        ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                        : _existingImageUrl != null
                                        ? Image.network(
                                          _existingImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                        : const SizedBox(),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Ganti Gambar'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _removeImage,
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Hapus Gambar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            // Upload area
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 48,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap untuk menambah gambar',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Save Button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveContent,
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
                    child:
                        _isSaving
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : Text(
                              _isEditing
                                  ? 'Simpan Perubahan'
                                  : 'Publikasikan Konten',
                            ),
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
