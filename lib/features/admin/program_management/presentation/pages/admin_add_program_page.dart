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

class _AdminAddProgramPageState extends State<AdminAddProgramPage>
    with TickerProviderStateMixin {
  final AdminProgramService _programService = AdminProgramService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaProgramController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _targetAudienceController =
      TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _syaratKetentuanController =
      TextEditingController();
  final TextEditingController _caraPendaftaranController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedStatus = 'active';
  File? _selectedImage;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'Kesehatan',
      'icon': Icons.medical_services_rounded,
      'color': Colors.red,
    },
    {'value': 'Pendidikan', 'icon': Icons.school_rounded, 'color': Colors.blue},
    {
      'value': 'Ekonomi', // ✅ FIXED: Changed from 'Modal Usaha'
      'icon': Icons.business_rounded,
      'color': Colors.green,
    },
    {
      'value': 'Bantuan Sosial', // ✅ FIXED: Changed from 'Makanan Pokok'
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
                  'Program Berhasil Ditambahkan!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Program "${_namaProgramController.text}" telah berhasil ditambahkan ke sistem.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  String _getStatusDisplayName(String status) {
    final statusData = _statuses.firstWhere((s) => s['value'] == status);
    return statusData['label'];
  }

  Color _getStatusColor(String status) {
    final statusData = _statuses.firstWhere((s) => s['value'] == status);
    return statusData['color'];
  }

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
              onPressed: () => context.go(RouteNames.adminProgramList),
            ),
          ),
          const SizedBox(width: 16),

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
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Form',
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_box_rounded,
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
                  'Form Tambah Program',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
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
        if (_selectedCategory == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Pilih kategori program',
              style: TextStyle(color: Colors.red.shade600, fontSize: 12),
            ),
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
                                ? status['color'].withValues(alpha: 0.1)
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _selectedImage != null
                  ? Colors.blue.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child:
            _selectedImage != null
                ? Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
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
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
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
                        SizedBox(width: 12),
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
