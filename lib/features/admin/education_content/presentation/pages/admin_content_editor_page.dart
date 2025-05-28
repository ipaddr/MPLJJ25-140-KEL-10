import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_content_service.dart';
import '../../data/models/content_model.dart';

/// Halaman untuk membuat atau mengedit konten edukasi
///
/// Menyediakan form untuk mengedit properti konten seperti judul,
/// isi, gambar, status, jenis, dan kategori.
class AdminContentEditorPage extends StatefulWidget {
  final String? contentId;

  const AdminContentEditorPage({super.key, this.contentId});

  @override
  State<AdminContentEditorPage> createState() => _AdminContentEditorPageState();
}

class _AdminContentEditorPageState extends State<AdminContentEditorPage>
    with TickerProviderStateMixin {
  // Services & Controllers
  final AdminContentService _contentService = AdminContentService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // UI Constants
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 16.0;
  static const double _microBorderRadius = 12.0;
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 18.0;
  static const double _sectionPadding = 24.0;
  static const double _itemPadding = 16.0;
  static const double _smallPadding = 12.0;
  static const double _microPadding = 8.0;
  static const double _tinyPadding = 6.0;
  static const double _imageHeight = 200.0;
  static const double _headerFontSize = 24.0;
  static const double _subheaderFontSize = 18.0;
  static const double _labelFontSize = 16.0;
  static const double _bodyFontSize = 14.0;
  static const double _smallFontSize = 13.0;
  static const double _microFontSize = 12.0;

  // Animation Constants
  static const Duration _animationDuration = Duration(milliseconds: 1000);
  static const Duration _slideAnimationDuration = Duration(milliseconds: 800);

  // State variables
  String? _selectedStatus;
  String? _selectedType;
  String? _selectedCategory;
  File? _selectedImage;
  String? _existingImageUrl;
  ContentModel? _existingContent;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Content Options
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

  /// Flag untuk menentukan apakah sedang dalam mode edit atau buat baru
  bool get _isEditing => widget.contentId != null;

  @override
  void initState() {
    super.initState();
    _initDefaults();
    _initializeAnimations();

    if (_isEditing) {
      _loadContent();
    } else {
      // Start animations for new content
      _fadeController.forward();
      _slideController.forward();
    }
  }

  /// Inisialisasi nilai default untuk form
  void _initDefaults() {
    _selectedStatus = 'Draf';
    _selectedType = 'Artikel';
    _selectedCategory = 'Umum';
  }

  /// Inisialisasi animasi untuk halaman
  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: _slideAnimationDuration,
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

  /// Memuat konten yang akan diedit
  Future<void> _loadContent() async {
    if (!mounted) return;

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
          _selectedType = content.type;
          _selectedCategory = content.category;
          _existingImageUrl = content.imageUrl;
          _isLoading = false;
        });

        // Start animations after loading
        _fadeController.forward();
        _slideController.forward();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Konten tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat konten: ${e.toString()}';
          _isLoading = false;
        });
        debugPrint('Error loading content: $e');
      }
    }
  }

  /// Mengambil gambar dari galeri
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

  /// Menghapus gambar terpilih
  Future<void> _removeImage() async {
    if (!mounted) return;

    setState(() {
      _selectedImage = null;
      _existingImageUrl = null;
    });
  }

  /// Menyimpan konten baru atau update konten yang ada
  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final statusValue = AdminContentService.getStatusValue(_selectedStatus!);
      bool success;

      if (_isEditing) {
        success = await _updateExistingContent(statusValue);
      } else {
        success = await _createNewContent(statusValue);
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
        debugPrint('Error saving content: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Memperbarui konten yang sudah ada
  Future<bool> _updateExistingContent(String statusValue) async {
    return await _contentService.updateContent(
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
  }

  /// Membuat konten baru
  Future<bool> _createNewContent(String statusValue) async {
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
    return contentId != null;
  }

  /// Menampilkan dialog sukses setelah menyimpan konten
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(_itemPadding),
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
                const SizedBox(height: _itemPadding),
                Text(
                  _isEditing ? 'Konten Diperbarui!' : 'Konten Dibuat!',
                  style: const TextStyle(
                    fontSize: _subheaderFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _smallPadding),
                Text(
                  _isEditing
                      ? 'Perubahan konten telah disimpan dengan sukses.'
                      : 'Konten "${_titleController.text}" telah berhasil dibuat.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: _bodyFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _sectionPadding),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: _smallPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_microBorderRadius),
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

  /// Menampilkan snackbar error
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: _microPadding),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_microPadding),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return _buildMainScreen();
  }

  /// Membangun tampilan loading
  Widget _buildLoadingScreen() {
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
            padding: const EdgeInsets.all(_sectionPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: _itemPadding),
                Text(
                  'Memuat konten...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: _bodyFontSize,
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

  /// Membangun tampilan error
  Widget _buildErrorScreen() {
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
            margin: const EdgeInsets.all(_sectionPadding),
            padding: const EdgeInsets.all(_sectionPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(_itemPadding),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: _itemPadding),
                const Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _subheaderFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: _microPadding),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _bodyFontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _sectionPadding),
                ElevatedButton.icon(
                  onPressed: () => context.go(RouteNames.adminEducationContent),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Kembali'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_microBorderRadius),
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

  /// Membangun tampilan utama editor
  Widget _buildMainScreen() {
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

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_microBorderRadius),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.go(RouteNames.adminEducationContent),
            ),
          ),
          const SizedBox(width: _itemPadding),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Konten Edukasi' : 'Tambah Konten Baru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: _headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isEditing
                      ? 'Perbarui konten edukasi'
                      : 'Buat konten edukasi baru',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: _bodyFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Status Indicator (if editing)
          if (_isEditing && _existingContent != null) _buildStatusIndicator(),
        ],
      ),
    );
  }

  /// Membangun indikator status untuk mode edit
  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _smallPadding,
        vertical: _microPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_microBorderRadius),
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
          const SizedBox(width: _tinyPadding),
          Text(
            _selectedStatus ?? 'Draf',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: _microFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun area konten utama
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_sectionPadding),
          topRight: Radius.circular(_sectionPadding),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_sectionPadding),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card (if editing)
                if (_isEditing && _existingContent != null) ...[
                  _buildContentInfoCard(),
                  const SizedBox(height: _sectionPadding),
                ],

                // Form Sections
                _buildBasicInfoSection(),
                const SizedBox(height: _sectionPadding),
                _buildTypeAndCategorySection(),
                const SizedBox(height: _sectionPadding),
                _buildStatusSection(),
                const SizedBox(height: _sectionPadding),
                _buildContentSection(),
                const SizedBox(height: _sectionPadding),
                _buildImageSection(),
                const SizedBox(height: _sectionPadding + _microPadding),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: _sectionPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun kartu info konten untuk mode edit
  Widget _buildContentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(_smallPadding),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(_microBorderRadius),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.white,
                  size: _smallIconSize,
                ),
              ),
              const SizedBox(width: _itemPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Konten',
                      style: TextStyle(
                        fontSize: _subheaderFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      'Detail konten yang sedang diedit',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: _bodyFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _itemPadding),
          _buildInfoDetailsCard(),
        ],
      ),
    );
  }

  /// Membangun kartu detail info
  Widget _buildInfoDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(_microBorderRadius),
      ),
      child: Column(
        children: [
          _buildInfoRow('ID', _existingContent!.id),
          _buildInfoRow('Penulis', _existingContent!.authorName),
          _buildInfoRow('Dibuat', _formatDate(_existingContent!.createdAt)),
          _buildInfoRow('Diperbarui', _formatDate(_existingContent!.updatedAt)),
          _buildInfoRow('Dilihat', '${_existingContent!.viewCount} kali'),
        ],
      ),
    );
  }

  /// Membangun baris info
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
                fontSize: _microFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: _microFontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun section dengan judul dan ikon
  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(_microPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(_microPadding),
              ),
              child: Icon(
                icon,
                color: Colors.blue.shade700,
                size: _microIconSize,
              ),
            ),
            const SizedBox(width: _smallPadding),
            Text(
              title,
              style: const TextStyle(
                fontSize: _subheaderFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: _itemPadding),
        ...children,
      ],
    );
  }

  /// Membangun section informasi dasar
  Widget _buildBasicInfoSection() {
    return _buildSection('Informasi Dasar', Icons.info_rounded, [
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
      const SizedBox(height: _itemPadding),
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
    ]);
  }

  /// Membangun section jenis dan kategori
  Widget _buildTypeAndCategorySection() {
    return _buildSection('Jenis & Kategori', Icons.category_rounded, [
      _buildTypeSelector(),
      const SizedBox(height: _itemPadding),
      _buildCategorySelector(),
    ]);
  }

  /// Membangun section status
  Widget _buildStatusSection() {
    return _buildSection('Status Publikasi', Icons.publish_rounded, [
      _buildStatusSelector(),
    ]);
  }

  /// Membangun section konten
  Widget _buildContentSection() {
    return _buildSection('Isi Konten', Icons.article_rounded, [
      _buildContentEditor(),
    ]);
  }

  /// Membangun section gambar
  Widget _buildImageSection() {
    return _buildSection('Gambar Pendukung', Icons.image_rounded, [
      _buildImageUploadArea(),
    ]);
  }

  /// Membangun field input dengan styling
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
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: _bodyFontSize,
        ),
      ),
      validator: validator,
    );
  }

  /// Membangun selector tipe konten
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Konten',
          style: TextStyle(
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _smallPadding),
        Wrap(
          spacing: _smallPadding,
          runSpacing: _smallPadding,
          children:
              _contentTypes.map((type) {
                final isSelected = _selectedType == type['value'];
                return _buildTypeItem(type, isSelected);
              }).toList(),
        ),
      ],
    );
  }

  /// Membangun item tipe konten
  Widget _buildTypeItem(Map<String, dynamic> type, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _itemPadding,
          vertical: _smallPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected ? type['color'].withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_microBorderRadius),
          border: Border.all(
            color: isSelected ? type['color'] : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type['icon'],
              color: isSelected ? type['color'] : Colors.grey.shade600,
              size: _microIconSize,
            ),
            const SizedBox(width: _microPadding),
            Text(
              type['value'],
              style: TextStyle(
                color: isSelected ? type['color'] : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: _bodyFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun selector kategori
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Konten',
          style: TextStyle(
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _smallPadding),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: _smallPadding,
            mainAxisSpacing: _smallPadding,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category['value'];
            return _buildCategoryItem(category, isSelected);
          },
        ),
      ],
    );
  }

  /// Membangun item kategori
  Widget _buildCategoryItem(Map<String, dynamic> category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _smallPadding,
          vertical: _microPadding,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? category['color'].withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_microBorderRadius),
          border: Border.all(
            color: isSelected ? category['color'] : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              category['icon'],
              color: isSelected ? category['color'] : Colors.grey.shade600,
              size: _microIconSize - 2,
            ),
            const SizedBox(width: _tinyPadding),
            Expanded(
              child: Text(
                category['value'],
                style: TextStyle(
                  color: isSelected ? category['color'] : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: _microFontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun selector status
  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Publikasi',
          style: TextStyle(
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _smallPadding),
        Row(
          children:
              _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                final statusColor = _getStatusColor(status);
                return Expanded(
                  child: _buildStatusItem(status, isSelected, statusColor),
                );
              }).toList(),
        ),
      ],
    );
  }

  /// Membangun item status
  Widget _buildStatusItem(String status, bool isSelected, Color statusColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: _microPadding),
        padding: const EdgeInsets.symmetric(vertical: _itemPadding),
        decoration: BoxDecoration(
          color:
              isSelected ? statusColor.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_microBorderRadius),
          border: Border.all(
            color: isSelected ? statusColor : Colors.grey.shade300,
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
                color: isSelected ? statusColor : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: _microPadding),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? statusColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: _smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun editor konten
  Widget _buildContentEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(_microBorderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditorHeader(),
          Padding(
            padding: const EdgeInsets.all(_itemPadding),
            child: TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText:
                    'Masukkan isi konten edukasi di sini...\n\nTips: Gunakan paragraf yang jelas dan bahasa yang mudah dipahami.',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: _bodyFontSize,
                ),
              ),
              maxLines: 15,
              style: const TextStyle(fontSize: _bodyFontSize, height: 1.6),
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

  /// Membangun header editor
  Widget _buildEditorHeader() {
    return Container(
      padding: const EdgeInsets.all(_itemPadding),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_microBorderRadius),
          topRight: Radius.circular(_microBorderRadius),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit_rounded,
            color: Colors.blue.shade700,
            size: _microIconSize,
          ),
          const SizedBox(width: _microPadding),
          Text(
            'Editor Konten',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: _bodyFontSize,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _microPadding,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(_microPadding),
            ),
            child: Text(
              'Rich Text',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: _microFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun area upload gambar
  Widget _buildImageUploadArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        border: Border.all(
          color:
              _selectedImage != null || _existingImageUrl != null
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_smallBorderRadius - 2),
        child:
            _hasSelectedImage()
                ? _buildImagePreview()
                : _buildImageUploadPrompt(),
      ),
    );
  }

  /// Memeriksa apakah ada gambar yang dipilih
  bool _hasSelectedImage() {
    return _selectedImage != null || _existingImageUrl != null;
  }

  /// Membangun preview gambar yang dipilih
  Widget _buildImagePreview() {
    return Stack(
      children: [
        SizedBox(
          height: _imageHeight,
          width: double.infinity,
          child:
              _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : _existingImageUrl != null
                  ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                  : const SizedBox.shrink(),
        ),
        Positioned(
          top: _smallPadding,
          right: _smallPadding,
          child: Row(
            children: [
              _buildImageActionButton(
                color: Colors.blue.shade600,
                icon: Icons.edit_rounded,
                onPressed: _pickImage,
                tooltip: 'Ganti Gambar',
              ),
              const SizedBox(width: _microPadding),
              _buildImageActionButton(
                color: Colors.red.shade600,
                icon: Icons.delete_rounded,
                onPressed: _removeImage,
                tooltip: 'Hapus Gambar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Membangun tombol aksi gambar
  Widget _buildImageActionButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_microPadding),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  /// Membangun prompt upload gambar
  Widget _buildImageUploadPrompt() {
    return InkWell(
      onTap: _pickImage,
      child: SizedBox(
        height: _imageHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_itemPadding),
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
            const SizedBox(height: _itemPadding),
            Text(
              'Tambah Gambar Konten',
              style: TextStyle(
                fontSize: _subheaderFontSize - 2,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: _microPadding),
            Text(
              'Tap untuk memilih gambar dari galeri',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: _bodyFontSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Format: JPG, PNG • Maksimal 5MB',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: _microFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tombol submit
  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
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
                          size: _iconSize,
                        ),
                        const SizedBox(width: _smallPadding),
                        Text(
                          _isEditing
                              ? 'Simpan Perubahan'
                              : 'Publikasikan Konten',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: _subheaderFontSize,
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

  /// Mendapatkan warna berdasarkan status
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

  /// Memformat tanggal untuk ditampilkan
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
