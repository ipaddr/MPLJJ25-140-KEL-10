import 'package:flutter/material.dart';
import 'package:socio_care/features/admin/core_admin/presentation/widgets/admin_navigation_drawer.dart';
import 'package:socio_care/features/admin/profile/presentation/widgets/edit_admin_profile_form_widget.dart';

/// Halaman untuk mengedit data profil admin
///
/// Menyediakan antarmuka untuk mengubah informasi profil administrator
class AdminEditProfilePage extends StatefulWidget {
  const AdminEditProfilePage({super.key});

  @override
  State<AdminEditProfilePage> createState() => _AdminEditProfilePageState();
}

class _AdminEditProfilePageState extends State<AdminEditProfilePage> {
  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // UI Constants
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _microSpacing = 8.0;
  static const double _tinySpacing = 6.0;
  static const double _nanoSpacing = 4.0;
  static const double _femtoSpacing = 2.0;
  
  static const double _borderRadius = 16.0;
  static const double _smallBorderRadius = 12.0;
  static const double _microBorderRadius = 8.0;
  static const double _tinyBorderRadius = 6.0;
  
  static const double _iconSize = 24.0;
  static const double _smallIconSize = 20.0;
  static const double _microIconSize = 16.0;
  
  static const double _largeText = 22.0;
  static const double _mediumText = 18.0;
  static const double _normalText = 16.0;
  static const double _smallText = 14.0;
  static const double _microText = 13.0;
  static const double _tinyText = 11.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _buildMainContent(),
      drawer: const AdminNavigationDrawer(),
    );
  }

  /// Membangun konten utama halaman
  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.blue.shade700,
            Colors.blue.shade500,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(),
            Expanded(
              child: _buildContentArea(),
            ),
          ],
        ),
      ),
    );
  }

  /// Membangun area konten form edit
  Widget _buildContentArea() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: const AdminEditProfileFormWidget(),
    );
  }

  /// Membangun app bar kustom
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildMenuButton(),
          const SizedBox(width: _spacing),
          _buildAppBarTitle(),
          _buildHelpButton(),
        ],
      ),
    );
  }

  /// Membangun tombol menu
  Widget _buildMenuButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.menu_rounded,
          color: Colors.white,
          size: _iconSize,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
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
            'Edit Profil Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: _largeText,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Perbarui informasi profil admin',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: _smallText,
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun tombol bantuan
  Widget _buildHelpButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.help_outline_rounded,
          color: Colors.white,
          size: _iconSize,
        ),
        onPressed: _showHelpDialog,
        tooltip: 'Bantuan',
      ),
    );
  }

  /// Menampilkan dialog bantuan
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        title: Row(
          children: [
            _buildHelpTitleIcon(),
            const SizedBox(width: _smallSpacing),
            const Text(
              'Bantuan Edit Profil',
              style: TextStyle(
                fontSize: _mediumText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpHeader(),
              const SizedBox(height: _spacing),
              ..._buildHelpItems(),
              const SizedBox(height: _spacing),
              _buildHelpInfoBox(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Mengerti',
              style: TextStyle(
                color: Colors.blue.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Membangun ikon judul dialog bantuan
  Widget _buildHelpTitleIcon() {
    return Container(
      padding: const EdgeInsets.all(_microSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(_microSpacing),
      ),
      child: Icon(
        Icons.help_rounded,
        color: Colors.blue.shade600,
        size: _iconSize,
      ),
    );
  }
  
  /// Membangun header dialog bantuan
  Widget _buildHelpHeader() {
    return Text(
      'Panduan mengubah data admin:',
      style: TextStyle(
        fontSize: _normalText,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }
  
  /// Membangun daftar item bantuan
  List<Widget> _buildHelpItems() {
    return [
      _buildHelpItem(
        Icons.person_rounded,
        'Nama Lengkap',
        'Minimal 2 karakter, gunakan nama asli',
      ),
      _buildHelpItem(
        Icons.phone_rounded,
        'Nomor Telepon',
        'Minimal 10 digit, gunakan format +62 atau 08',
      ),
      _buildHelpItem(
        Icons.email_rounded,
        'Email',
        'Tidak dapat diubah demi keamanan akun',
      ),
      _buildHelpItem(
        Icons.work_rounded,
        'Jabatan',
        'Posisi atau jabatan dalam organisasi',
      ),
      _buildHelpItem(
        Icons.camera_alt_rounded,
        'Foto Profil',
        'Opsional, maksimal 512x512 px, format JPG/PNG',
      ),
    ];
  }
  
  /// Membangun kotak info bantuan
  Widget _buildHelpInfoBox() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_microSpacing),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: Colors.blue.shade600,
            size: _smallIconSize,
          ),
          const SizedBox(width: _microSpacing),
          Expanded(
            child: Text(
              'Pastikan semua data yang dimasukkan benar dan sesuai.',
              style: TextStyle(
                fontSize: _tinyText,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun item bantuan
  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHelpItemIcon(icon),
          const SizedBox(width: _smallSpacing),
          _buildHelpItemContent(title, description),
        ],
      ),
    );
  }
  
  /// Membangun ikon item bantuan
  Widget _buildHelpItemIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(_nanoSpacing),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(_tinyBorderRadius),
      ),
      child: Icon(
        icon,
        size: _microIconSize,
        color: Colors.grey.shade600,
      ),
    );
  }
  
  /// Membangun konten item bantuan
  Widget _buildHelpItemContent(String title, String description) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: _microText,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: _femtoSpacing),
          Text(
            description,
            style: TextStyle(
              fontSize: _tinyText,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}