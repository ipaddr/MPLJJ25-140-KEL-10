import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';
import 'dart:io';

/// Halaman untuk menambahkan program baru oleh admin
///
/// Menampilkan form dengan berbagai input untuk membuat program bantuan baru
/// seperti nama program, kategori, deskripsi, dll.
class AdminAddProgramPage extends StatefulWidget {
  const AdminAddProgramPage({super.key});

  @override
  State<AdminAddProgramPage> createState() => _AdminAddProgramPageState();
}

class _AdminAddProgramPageState extends State<AdminAddProgramPage>
    with TickerProviderStateMixin {
  // Services
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Controllers
  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _targetAudienceController =
      TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController =
      TextEditingController();
  final TextEditingController _caraPendaftaranController =
      TextEditingController();

  // State variables
  String? _selectedCategory;
  String _selectedStatus = 'active';
  File? _selectedImage;
  bool _isLoading = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // UI Constants
  static const double _spacing = 24.0;
  static const double _midSpacing = 20.0;
  static const double _smallSpacing = 16.0;
  static const double _microSpacing = 12.0;
  static const double _tinySpacing = 8.0;
  static const double _miniSpacing = 4.0;

  static const double _borderRadius = 16.0;
  static const double _midBorderRadius = 14.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;

  // Category options
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

  // Status options
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
  }

  /// Menyiapkan animasi untuk halaman
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disposeControllers();
    super.dispose();
  }

  /// Membuang controllers untuk mencegah memory leak
  void _disposeControllers() {
    _namaProgramController.dispose();
    _organizerController.dispose();
    _targetAudienceController.dispose();
    _deskripsiController.dispose();
    _syaratKetentuanController.dispose();
    _caraPendaftaranController.dispose();
  }

  /// Memilih gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  /// Menambahkan program baru ke database
  Future<void> _addProgram() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        _showErrorMessage('Pilih kategori program');
        return;
      }

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
          status: _selectedStatus,
          imageFile: _selectedImage,
        );

        if (programId != null) {
          _showSuccessDialog();
        } else {
          _showErrorMessage('Gagal menambahkan program');
        }
      } catch (e) {
        _showErrorMessage('Error: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menampilkan dialog sukses setelah program berhasil ditambahkan
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
                const SizedBox(height: _borderRadius),
                const Text(
                  'Program Berhasil Ditambahkan!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _microSpacing),
                Text(
                  'Program "${_namaProgramController.text}" telah berhasil ditambahkan ke sistem.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _spacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(RouteNames.adminProgramList);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: _microSpacing,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_smallBorderRadius),
                      ),
                    ),
                    child: const Text('Lihat Daftar Program'),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  /// Menampilkan pesan error
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
          borderRadius: BorderRadius.circular(_microBorderRadius),
        ),
      ),
    );
  }

  /// Mendapatkan nama tampilan untuk status tertentu
  String _getStatusDisplayName(String status) {
    final statusData = _statuses.firstWhere((s) => s['value'] == status);
    return statusData['label'];
  }

  /// Mendapatkan warna untuk status tertentu
  Color _getStatusColor(String status) {
    final statusData = _statuses.firstWhere((s) => s['value'] == status);
    return statusData['color'];
  }

  /// Mendapatkan ikon untuk status tertentu
  IconData _getStatusIcon(String status) {
    final statusData = _statuses.firstWhere((s) => s['value'] == status);
    return statusData['icon'];
  }

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(_borderRadius),
      child: Row(
        children: [
          // Back Button
          _buildAppBarButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(RouteNames.adminProgramList),
          ),
          const SizedBox(width: _smallSpacing),

          // Title Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Program Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Buat program bantuan sosial baru',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: _microSpacing,
              vertical: _tinySpacing,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Form',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
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

  /// Membangun tombol pada app bar
  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
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
                _buildSubmitButton(),
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
      padding: const EdgeInsets.all(_borderRadius),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_microSpacing),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(_smallBorderRadius),
            ),
            child: const Icon(
              Icons.add_box_rounded,
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
                  'Form Tambah Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: _miniSpacing),
                Text(
                  'Lengkapi semua informasi yang diperlukan untuk membuat program bantuan sosial baru.',
                  style: TextStyle(color: Colors.blue.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun bagian informasi dasar
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

  /// Membangun bagian kategori dan status
  Widget _buildCategoryStatusSection() {
    return _buildSection('Kategori & Status', Icons.settings_rounded, [
      _buildCategoryGrid(),
      const SizedBox(height: _smallSpacing),
      _buildStatusSelector(),
    ]);
  }

  /// Membangun bagian detail program
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

  /// Membangun bagian upload gambar
  Widget _buildImageSection() {
    return _buildSection('Gambar Program', Icons.image_rounded, [
      _buildImageUploadArea(),
    ]);
  }

  /// Membangun struktur bagian
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
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                ),
                borderRadius: BorderRadius.circular(_microBorderRadius),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 20),
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

  /// Membangun field input teks dengan style seragam
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
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_smallBorderRadius),
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
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: _tinySpacing),
            child: Text(
              'Pilih kategori program',
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
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
          borderRadius: BorderRadius.circular(_smallBorderRadius),
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
              _statuses
                  .map(
                    (status) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: _tinySpacing),
                        child: _buildStatusItem(status),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  /// Membangun item status
  Widget _buildStatusItem(Map<String, dynamic> status) {
    final isSelected = _selectedStatus == status['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status['value'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: _microSpacing),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? status['color'].withOpacity(0.1)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(_smallBorderRadius),
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
    );
  }

  /// Membangun area upload gambar
  Widget _buildImageUploadArea() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(
          color:
              _selectedImage != null
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_midBorderRadius),
        child:
            _selectedImage != null
                ? _buildSelectedImagePreview()
                : _buildImagePickerPrompt(),
      ),
    );
  }

  /// Membangun preview gambar yang dipilih
  Widget _buildSelectedImagePreview() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: Image.file(_selectedImage!, fit: BoxFit.cover),
        ),
        Positioned(
          top: _microSpacing,
          right: _microSpacing,
          child: Row(
            children: [
              _buildImageActionButton(
                color: Colors.blue.shade600,
                icon: Icons.edit_rounded,
                onPressed: _pickImage,
                tooltip: 'Ganti Gambar',
              ),
              const SizedBox(width: _tinySpacing),
              _buildImageActionButton(
                color: Colors.red.shade600,
                icon: Icons.delete_rounded,
                onPressed: () => setState(() => _selectedImage = null),
                tooltip: 'Hapus Gambar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Membangun tombol aksi gambar (edit/hapus)
  Widget _buildImageActionButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_microBorderRadius),
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

  /// Membangun prompt untuk memilih gambar
  Widget _buildImagePickerPrompt() {
    return InkWell(
      onTap: _pickImage,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(_borderRadius),
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
            const SizedBox(height: _miniSpacing),
            Text(
              'Format: JPG, PNG • Maksimal 5MB',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
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
        borderRadius: BorderRadius.circular(_borderRadius),
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
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: _isLoading ? null : _addProgram,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child:
                _isLoading
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
                        Icon(
                          Icons.add_circle_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: _microSpacing),
                        Text(
                          'Tambah Program',
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
