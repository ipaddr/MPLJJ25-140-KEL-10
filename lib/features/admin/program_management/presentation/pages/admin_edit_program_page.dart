import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../data/admin_program_service.dart';

class AdminEditProgramPage extends StatefulWidget {
  final String programId;

  const AdminEditProgramPage({super.key, required this.programId});

  @override
  State<AdminEditProgramPage> createState() => _AdminEditProgramPageState();
}

class _AdminEditProgramPageState extends State<AdminEditProgramPage>
    with TickerProviderStateMixin {
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();

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

  // Options
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
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

  Future<void> _updateProgram() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      _showErrorMessage('Pilih kategori program');
      return;
    }

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

      if (success && mounted) {
        _showSuccessDialog();
      } else {
        _showErrorMessage('Gagal memperbarui program');
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
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
                const Text(
                  'Program Berhasil Diperbarui!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Program "${_namaProgramController.text}" telah berhasil diperbarui.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
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
                    const SizedBox(width: 12),
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
                ),
              ],
            ),
          ),
    );
  }

  void _showErrorMessage(String message) {
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
              colors: [Colors.blue.shade900, Colors.blue.shade600],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
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

    if (_errorMessage != null) {
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
                Icon(Icons.error_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back Button - ✅ FIXED: Navigate to program list instead of detail
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed:
                  () => context.go(
                    RouteNames.adminProgramList,
                  ), // ✅ Changed from detail to list
            ),
          ),
          const SizedBox(width: 16),

          // Title Section
          Expanded(
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
          ),

          // Save Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
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
                // Header Info Card
                _buildHeaderCard(),
                const SizedBox(height: 24),

                // Basic Information Section
                _buildSection('Informasi Dasar', Icons.info_rounded, [
                  _buildStyledTextField(
                    controller: _namaProgramController,
                    label: 'Nama Program',
                    icon: Icons.title_rounded,
                    hint: 'Masukkan nama program bantuan',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _organizerController,
                    label: 'Penyelenggara',
                    icon: Icons.business_rounded,
                    hint: 'Nama lembaga/instansi penyelenggara',
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _targetAudienceController,
                    label: 'Target Penerima',
                    icon: Icons.group_rounded,
                    hint: 'Siapa yang bisa mendaftar program ini',
                  ),
                ]),
                const SizedBox(height: 24),

                // Category and Status Section
                _buildSection('Kategori & Status', Icons.settings_rounded, [
                  _buildCategoryGrid(),
                  const SizedBox(height: 16),
                  _buildStatusSelector(),
                ]),
                const SizedBox(height: 24),

                // Content Section
                _buildSection('Detail Program', Icons.description_rounded, [
                  _buildStyledTextField(
                    controller: _deskripsiController,
                    label: 'Deskripsi Program',
                    icon: Icons.description_rounded,
                    hint: 'Jelaskan tujuan dan manfaat program',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _syaratKetentuanController,
                    label: 'Syarat & Ketentuan',
                    icon: Icons.checklist_rounded,
                    hint: 'Persyaratan untuk mendaftar program',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  _buildStyledTextField(
                    controller: _caraPendaftaranController,
                    label: 'Panduan Pendaftaran',
                    icon: Icons.list_alt_rounded,
                    hint: 'Langkah-langkah mendaftar program',
                    maxLines: 4,
                  ),
                ]),
                const SizedBox(height: 24),

                // Image Upload Section
                _buildSection('Gambar Program', Icons.image_rounded, [
                  _buildImageUploadArea(),
                ]),
                const SizedBox(height: 32),

                // Update Button
                _buildUpdateButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.edit_rounded,
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
                  'Form Edit Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
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
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.orange.shade700, size: 20),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
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
                          ? category['color'].withOpacity(0.1)
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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
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
                          fontSize: 13,
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
          'Status Program',
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
                final isSelected = _selectedStatus == status['value'];

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status['value'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? status['color'].withOpacity(0.1)
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? status['color']
                                  : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            status['icon'],
                            color:
                                isSelected
                                    ? status['color']
                                    : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status['label'],
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? status['color']
                                      : Colors.grey.shade700,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              fontSize: 12,
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

  Widget _buildImageUploadArea() {
    final hasImage =
        _selectedImage != null ||
        (_existingImageUrl != null && _existingImageUrl!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? Colors.orange.shade300 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child:
            hasImage
                ? Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child:
                          _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Image.network(
                                _existingImageUrl!,
                                fit: BoxFit.cover,
                              ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
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
                                  color: Colors.black.withOpacity(0.2),
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
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _existingImageUrl = null;
                                });
                              },
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
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tambah Gambar Program',
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
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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
                        SizedBox(width: 12),
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
