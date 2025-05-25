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

class _AdminContentEditorPageState extends State<AdminContentEditorPage>
    with TickerProviderStateMixin {
  final AdminContentService _contentService = AdminContentService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedStatus;
  String? _selectedType;
  String? _selectedCategory;
  File? _selectedImage;
  String? _existingImageUrl;
  ContentModel? _existingContent;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _statuses = ['Draf', 'Dipublikasikan', 'Diarsip'];

  final List<Map<String, dynamic>> _contentTypes = [
    {'value': 'Artikel', 'icon': Icons.article_rounded, 'color': Colors.blue},
    {'value': 'Video', 'icon': Icons.play_circle_rounded, 'color': Colors.red},
    {'value': 'Infografis', 'icon': Icons.image_rounded, 'color': Colors.green},
    {'value': 'Panduan', 'icon': Icons.book_rounded, 'color': Colors.purple},
    {'value': 'Tips', 'icon': Icons.lightbulb_rounded, 'color': Colors.orange},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'value': 'Umum', 'icon': Icons.public_rounded, 'color': Colors.grey},
    {
      'value': 'Kesehatan',
      'icon': Icons.medical_services_rounded,
      'color': Colors.red,
    },
    {'value': 'Pendidikan', 'icon': Icons.school_rounded, 'color': Colors.blue},
    {
      'value': 'Ekonomi',
      'icon': Icons.attach_money_rounded,
      'color': Colors.green,
    },
    {'value': 'Hukum', 'icon': Icons.gavel_rounded, 'color': Colors.indigo},
    {
      'value': 'Teknologi',
      'icon': Icons.computer_rounded,
      'color': Colors.cyan,
    },
    {'value': 'Lingkungan', 'icon': Icons.eco_rounded, 'color': Colors.teal},
  ];

  bool get _isEditing => widget.contentId != null;

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'Draf';
    _selectedType = 'Artikel';
    _selectedCategory = 'Umum';

    _initializeAnimations();

    if (_isEditing) {
      _loadContent();
    } else {
      // Start animations for new content
      _fadeController.forward();
      _slideController.forward();
    }
  }

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
    _titleController.dispose();
    _contentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final content = await _contentService.getContentById(widget.contentId!);

      if (content != null && mounted) {
        setState(() {
          _existingContent = content;
          _titleController.text = content.title;
          _contentController.text = content.content;
          _descriptionController.text = content.description ?? '';
          _selectedStatus = AdminContentService.getStatusDisplayName(
            content.status,
          );
          _selectedType = content.type ?? 'Artikel';
          _selectedCategory = content.category ?? 'Umum';
          _existingImageUrl = content.imageUrl;
          _isLoading = false;
        });

        // Start animations after loading
        _fadeController.forward();
        _slideController.forward();
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

    if (pickedFile != null && mounted) {
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
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            status: statusValue,
            type: _selectedType!,
            category: _selectedCategory!,
            imageFile: _selectedImage,
            existingImageUrl: _existingImageUrl,
          );
        } else {
          final contentId = await _contentService.createContent(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            description:
                _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
            status: statusValue,
            type: _selectedType!,
            category: _selectedCategory!,
            imageFile: _selectedImage,
          );
          success = contentId != null;
        }

        if (mounted) {
          if (success) {
            _showSuccessDialog();
          } else {
            _showErrorSnackBar(
              _isEditing ? 'Gagal memperbarui konten' : 'Gagal membuat konten',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing ? 'Konten Diperbarui!' : 'Konten Dibuat!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing
                      ? 'Perubahan konten telah disimpan dengan sukses.'
                      : 'Konten "${_titleController.text}" telah berhasil dibuat.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.adminEducationContent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Lihat Daftar Konten'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat konten...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed:
                        () => context.go(RouteNames.adminEducationContent),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Kembali'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
                child: FadeTransition(
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
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go(RouteNames.adminEducationContent),
            ),
          ),
          const SizedBox(width: 16),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Konten Edukasi' : 'Tambah Konten Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Perbarui konten edukasi'
                      : 'Buat konten edukasi baru',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator (if editing)
          if (_isEditing && _existingContent != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(_selectedStatus ?? 'Draf'),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _selectedStatus ?? 'Draf',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card (if editing)
                if (_isEditing && _existingContent != null) ...[
                  _buildContentInfoCard(),
                  const SizedBox(height: 24),
                ],

                // Basic Information Section
                _buildSection('Informasi Dasar', Icons.info_rounded, [
                  _buildStyledTextField(
                    controller: _titleController,
                    label: 'Judul Konten',
                    icon: Icons.title_rounded,
                    hint: 'Masukkan judul konten yang menarik',
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
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi Singkat (Opsional)',
                    icon: Icons.description_outlined,
                    hint: 'Deskripsi singkat untuk preview konten',
                    maxLines: 3,
                    validator: (value) {
                      if (value != null &&
                          value.trim().isNotEmpty &&
                          value.trim().length < 10) {
                        return 'Deskripsi minimal 10 karakter';
                      }
                      return null;
                    },
                  ),
                ]),
                const SizedBox(height: 24),

                // Type and Category Section
                _buildSection('Jenis & Kategori', Icons.category_rounded, [
                  _buildTypeSelector(),
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                ]),
                const SizedBox(height: 24),

                // Status Section
                _buildSection('Status Publikasi', Icons.publish_rounded, [
                  _buildStatusSelector(),
                ]),
                const SizedBox(height: 24),

                // Content Section
                _buildSection('Isi Konten', Icons.article_rounded, [
                  _buildContentEditor(),
                ]),
                const SizedBox(height: 24),

                // Image Section
                _buildSection('Gambar Pendukung', Icons.image_rounded, [
                  _buildImageUploadArea(),
                ]),
                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Konten',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Detail konten yang sedang diedit',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildInfoRow('ID', _existingContent!.id),
                _buildInfoRow('Penulis', _existingContent!.authorName),
                _buildInfoRow(
                  'Dibuat',
                  _formatDate(_existingContent!.createdAt),
                ),
                _buildInfoRow(
                  'Diperbarui',
                  _formatDate(_existingContent!.updatedAt),
                ),
                _buildInfoRow('Dilihat', '${_existingContent!.viewCount} kali'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Konten',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _contentTypes.map((type) {
                final isSelected = _selectedType == type['value'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedType = type['value'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? type['color'].withValues(alpha: 0.1)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? type['color'] : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type['icon'],
                          color:
                              isSelected ? type['color'] : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type['value'],
                          style: TextStyle(
                            color:
                                isSelected
                                    ? type['color']
                                    : Colors.grey.shade700,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Konten',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['value'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['value'];
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? category['color'].withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? category['color'] : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category['icon'],
                      color:
                          isSelected ? category['color'] : Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category['value'],
                        style: TextStyle(
                          color:
                              isSelected
                                  ? category['color']
                                  : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Publikasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                final statusColor = _getStatusColor(status);

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? statusColor.withValues(alpha: 0.1)
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? statusColor : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected
                                      ? statusColor
                                      : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            status,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? statusColor
                                      : Colors.grey.shade700,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildContentEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Editor Konten',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Rich Text',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText:
                    'Masukkan isi konten edukasi di sini...\n\nTips: Gunakan paragraf yang jelas dan bahasa yang mudah dipahami.',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
              maxLines: 15,
              style: const TextStyle(fontSize: 14, height: 1.6),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi konten tidak boleh kosong';
                }
                if (value.trim().length < 50) {
                  return 'Isi konten minimal 50 karakter';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _selectedImage != null || _existingImageUrl != null
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child:
            _selectedImage != null || _existingImageUrl != null
                ? Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child:
                          _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : _existingImageUrl != null
                              ? Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                              )
                              : const SizedBox(),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                              tooltip: 'Ganti Gambar',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ),
                              onPressed: _removeImage,
                              tooltip: 'Hapus Gambar',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tambah Gambar Konten',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap untuk memilih gambar dari galeri',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Format: JPG, PNG • Maksimal 5MB',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isSaving ? null : _saveContent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child:
                _isSaving
                    ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.save_rounded
                              : Icons.publish_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isEditing
                              ? 'Simpan Perubahan'
                              : 'Publikasikan Konten',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Draf':
        return Colors.orange;
      case 'Dipublikasikan':
        return Colors.green;
      case 'Diarsip':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
