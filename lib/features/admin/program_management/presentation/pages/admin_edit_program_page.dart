import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';

/// Halaman untuk mengedit program yang sudah ada
///
/// Menampilkan form dengan data program yang sudah terisi
/// dan memungkinkan admin untuk mengubah informasi program
class AdminEditProgramPage extends StatefulWidget {
  final String programId;

  const AdminEditProgramPage({super.key, required this.programId});

  @override
  State<AdminEditProgramPage> createState() => _AdminEditProgramPageState();
}

class _AdminEditProgramPageState extends State<AdminEditProgramPage>
    with TickerProviderStateMixin {
  // Constants
  static const double _borderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _miniSpacing = 4.0;

  // Services
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Controllers
  final _namaProgramController = TextEditingController();
  final _organizerController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _syaratKetentuanController = TextEditingController();
  final _caraPendaftaranController = TextEditingController();

  // State
  String? _selectedCategory;
  String? _selectedStatus;
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Options for categories and statuses
  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'Kesehatan',
      'icon': Icons.medical_services_rounded,
      'color': Colors.red,
    },
    {'value': 'Pendidikan', 'icon': Icons.school_rounded, 'color': Colors.blue},
    {'value': 'Ekonomi', 'icon': Icons.business_rounded, 'color': Colors.green},
    {
      'value': 'Bantuan Sosial',
      'icon': Icons.favorite_rounded,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _statuses = [
    {
      'value': 'active',
      'label': 'Aktif',
      'color': Colors.green,
      'icon': Icons.play_circle_rounded,
    },
    {
      'value': 'inactive',
      'label': 'Tidak Aktif',
      'color': Colors.grey,
      'icon': Icons.pause_circle_rounded,
    },
    {
      'value': 'upcoming',
      'label': 'Akan Datang',
      'color': Colors.blue,
      'icon': Icons.schedule_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProgramData();
  }

  /// Inisialisasi animasi yang digunakan di halaman
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _namaProgramController.dispose();
    _organizerController.dispose();
    _targetAudienceController.dispose();
    _deskripsiController.dispose();
    _syaratKetentuanController.dispose();
    _caraPendaftaranController.dispose();
    super.dispose();
  }

  /// Memuat data program dari service berdasarkan ID
  Future<void> _loadProgramData() async {
    try {
      final programData = await _programService.getProgramById(
        widget.programId,
      );

      if (programData != null && mounted) {
        setState(() {
          _namaProgramController.text = programData['programName'] ?? '';
          _organizerController.text = programData['organizer'] ?? '';
          _targetAudienceController.text = programData['targetAudience'] ?? '';
          _deskripsiController.text = programData['description'] ?? '';
          _syaratKetentuanController.text =
              programData['termsAndConditions'] ?? '';
          _caraPendaftaranController.text =
              programData['registrationGuide'] ?? '';
          _selectedCategory = programData['category'];
          _selectedStatus = programData['status'];
          _existingImageUrl = programData['imageUrl'];
          _isLoading = false;
        });

        _animationController.forward();
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Program tidak ditemukan';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data program: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Memilih gambar dari galeri perangkat
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Memperbarui data program dengan nilai-nilai baru
  Future<void> _updateProgram() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showErrorMessage('Pilih kategori program');
      return;
    }

    if (_selectedStatus == null) {
      _showErrorMessage('Pilih status program');
      return;
    }

    setState(() => _isSaving = true);

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

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorMessage('Gagal memperbarui program');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Menampilkan dialog sukses setelah program berhasil diperbarui
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
                  padding: const EdgeInsets.all(_borderRadius),
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
                const SizedBox(height: _midSpacing),
                const Text(
                  'Program Berhasil Diperbarui!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _microSpacing),
                Text(
                  'Program "${_namaProgramController.text}" telah berhasil diperbarui.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _spacing),
                _buildSuccessDialogActions(),
              ],
            ),
          ),
    );
  }

  /// Membangun tombol aksi pada dialog sukses
  Widget _buildSuccessDialogActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(
                '${RouteNames.adminProgramDetail}/${widget.programId}',
              );
            },
            child: const Text('Lihat Detail'),
          ),
        ),
        const SizedBox(width: _microSpacing),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteNames.adminProgramList);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Daftar Program'),
          ),
        ),
      ],
    );
  }

  /// Menampilkan pesan error dalam bentuk snackbar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: _tinySpacing),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_tinySpacing),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade700,
              Colors.orange.shade500,
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

  /// Membangun tampilan loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: _smallSpacing),
              Text(
                'Memuat data program...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun tampilan error screen
  Widget _buildErrorScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.shade900, Colors.red.shade600],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.white),
              const SizedBox(height: _smallSpacing),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: _spacing),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.adminProgramList),
                child: const Text('Kembali ke Daftar Program'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(_midSpacing),
      child: Row(
        children: [
          _buildBackButton(),
          const SizedBox(width: _smallSpacing),
          _buildAppBarTitle(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  /// Membangun tombol kembali di app bar
  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.go(RouteNames.adminProgramList),
      ),
    );
  }

  /// Membangun judul app bar
  Widget _buildAppBarTitle() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Program',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Perbarui informasi program',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol simpan di app bar
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon:
            _isSaving
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : const Icon(Icons.save_rounded, color: Colors.white),
        onPressed: _isSaving ? null : _updateProgram,
        tooltip: 'Simpan Perubahan',
      ),
    );
  }

  /// Membangun area konten utama
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_spacing),
          topRight: Radius.circular(_spacing),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_spacing),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: _spacing),
                _buildBasicInfoSection(),
                const SizedBox(height: _spacing),
                _buildCategoryStatusSection(),
                const SizedBox(height: _spacing),
                _buildDetailSection(),
                const SizedBox(height: _spacing),
                _buildImageSection(),
                const SizedBox(height: 32),
                _buildUpdateButton(),
                const SizedBox(height: _spacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Membangun kartu header
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(_midSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(_smallSpacing),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_microSpacing),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(_microSpacing),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: _smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Edit Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: _miniSpacing),
                Text(
                  'Perbarui informasi program yang sudah ada.',
                  style: TextStyle(color: Colors.orange.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun section informasi dasar
  Widget _buildBasicInfoSection() {
    return _buildSection('Informasi Dasar', Icons.info_rounded, [
      _buildStyledTextField(
        controller: _namaProgramController,
        label: 'Nama Program',
        icon: Icons.title_rounded,
        hint: 'Masukkan nama program bantuan',
      ),
      const SizedBox(height: _smallSpacing),
      _buildStyledTextField(
        controller: _organizerController,
        label: 'Penyelenggara',
        icon: Icons.business_rounded,
        hint: 'Nama lembaga/instansi penyelenggara',
      ),
      const SizedBox(height: _smallSpacing),
      _buildStyledTextField(
        controller: _targetAudienceController,
        label: 'Target Penerima',
        icon: Icons.group_rounded,
        hint: 'Siapa yang bisa mendaftar program ini',
      ),
    ]);
  }

  /// Membangun section kategori dan status
  Widget _buildCategoryStatusSection() {
    return _buildSection('Kategori & Status', Icons.settings_rounded, [
      _buildCategoryGrid(),
      const SizedBox(height: _smallSpacing),
      _buildStatusSelector(),
    ]);
  }

  /// Membangun section detail program
  Widget _buildDetailSection() {
    return _buildSection('Detail Program', Icons.description_rounded, [
      _buildStyledTextField(
        controller: _deskripsiController,
        label: 'Deskripsi Program',
        icon: Icons.description_rounded,
        hint: 'Jelaskan tujuan dan manfaat program',
        maxLines: 4,
      ),
      const SizedBox(height: _smallSpacing),
      _buildStyledTextField(
        controller: _syaratKetentuanController,
        label: 'Syarat & Ketentuan',
        icon: Icons.checklist_rounded,
        hint: 'Persyaratan untuk mendaftar program',
        maxLines: 4,
      ),
      const SizedBox(height: _smallSpacing),
      _buildStyledTextField(
        controller: _caraPendaftaranController,
        label: 'Panduan Pendaftaran',
        icon: Icons.list_alt_rounded,
        hint: 'Langkah-langkah mendaftar program',
        maxLines: 4,
      ),
    ]);
  }

  /// Membangun section upload gambar
  Widget _buildImageSection() {
    return _buildSection('Gambar Program', Icons.image_rounded, [
      _buildImageUploadArea(),
    ]);
  }

  /// Template untuk membangun judul section dengan ikon
  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(_tinySpacing),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(_tinySpacing),
              ),
              child: Icon(icon, color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: _microSpacing),
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
        const SizedBox(height: _smallSpacing),
        ...children,
      ],
    );
  }

  /// Membangun textfield dengan styling yang konsisten
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microSpacing),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microSpacing),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_microSpacing),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  /// Membangun grid pilihan kategori
  Widget _buildCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Kategori Program',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _microSpacing),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: _microSpacing,
            mainAxisSpacing: _microSpacing,
          ),
          itemCount: _categories.length,
          itemBuilder:
              (context, index) => _buildCategoryItem(_categories[index]),
        ),
      ],
    );
  }

  /// Membangun item kategori
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final isSelected = _selectedCategory == category['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _microSpacing,
          vertical: _tinySpacing,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? category['color'].withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_microSpacing),
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
              size: 20,
            ),
            const SizedBox(width: _tinySpacing),
            Expanded(
              child: Text(
                category['value'],
                style: TextStyle(
                  color: isSelected ? category['color'] : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun pemilih status program
  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Program',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: _microSpacing),
        Row(
          children:
              _statuses.map((status) => _buildStatusItem(status)).toList(),
        ),
      ],
    );
  }

  /// Membangun item status
  Widget _buildStatusItem(Map<String, dynamic> status) {
    final isSelected = _selectedStatus == status['value'];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStatus = status['value'];
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: _tinySpacing),
          padding: const EdgeInsets.symmetric(vertical: _microSpacing),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? status['color'].withOpacity(0.1)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(_microSpacing),
            border: Border.all(
              color: isSelected ? status['color'] : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                status['icon'],
                color: isSelected ? status['color'] : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: _miniSpacing),
              Text(
                status['label'],
                style: TextStyle(
                  color: isSelected ? status['color'] : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membangun area upload gambar
  Widget _buildImageUploadArea() {
    final hasImage =
        _selectedImage != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_smallSpacing),
        border: Border.all(
          color: hasImage ? Colors.orange.shade300 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child:
            hasImage
                ? _buildSelectedImageView()
                : _buildImagePickerPlaceholder(),
      ),
    );
  }

  /// Membangun tampilan gambar terpilih
  Widget _buildSelectedImageView() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child:
              _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : Image.network(_existingImageUrl!, fit: BoxFit.cover),
        ),
        Positioned(
          top: _microSpacing,
          right: _microSpacing,
          child: Row(
            children: [
              _buildImageActionButton(
                color: Colors.orange.shade600,
                icon: Icons.edit_rounded,
                onPressed: _pickImage,
                tooltip: 'Ganti Gambar',
              ),
              const SizedBox(width: _tinySpacing),
              _buildImageActionButton(
                color: Colors.red.shade600,
                icon: Icons.delete_rounded,
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _existingImageUrl = null;
                  });
                },
                tooltip: 'Hapus Gambar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Membangun tombol aksi untuk gambar
  Widget _buildImageActionButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_tinySpacing),
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

  /// Membangun placeholder untuk pemilih gambar
  Widget _buildImagePickerPlaceholder() {
    return InkWell(
      onTap: _pickImage,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_midSpacing),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                size: 48,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: _smallSpacing),
            Text(
              'Tambah Gambar Program',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: _tinySpacing),
            Text(
              'Tap untuk memilih gambar dari galeri',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun tombol update
  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(_smallSpacing),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_smallSpacing),
          onTap: _isSaving ? null : _updateProgram,
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
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_rounded, color: Colors.white, size: 24),
                        SizedBox(width: _microSpacing),
                        Text(
                          'Simpan Perubahan',
                          style: TextStyle(
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
}
