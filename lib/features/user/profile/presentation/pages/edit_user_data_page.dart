import 'package:flutter/material.dart';
import 'package:socio_care/features/user/profile/presentation/widgets/edit_user_profile_form_widget.dart';

/// Halaman untuk mengedit data profil pengguna
class EditUserDataPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  
  // UI constants
  static const double _iconSize = 24.0;
  static const double _borderRadius = 16.0;
  static const double _spacing = 16.0;
  static const double _smallSpacing = 12.0;
  static const double _iconPadding = 8.0;
  
  const EditUserDataPage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }
  
  /// Membangun AppBar dengan judul dan tombol bantuan
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        "Edit Profil Pengguna",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Bantuan',
        ),
      ],
    );
  }
  
  /// Membangun body halaman dengan widget form
  Widget _buildBody() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: EditUserProfileFormWidget(initialData: userData),
    );
  }

  /// Menampilkan dialog bantuan untuk edit profil
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        title: _buildHelpTitle(),
        content: _buildHelpContent(),
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
  
  /// Membangun judul dialog bantuan
  Widget _buildHelpTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(_iconPadding),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(_iconPadding),
          ),
          child: Icon(
            Icons.help_rounded,
            color: Colors.blue.shade600,
            size: _iconSize,
          ),
        ),
        const SizedBox(width: _smallSpacing),
        const Text(
          'Bantuan Edit Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
  
  /// Membangun konten dialog bantuan
  Widget _buildHelpContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Panduan mengubah data pengguna:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: _spacing),
          _buildHelpItem(
            Icons.person_rounded,
            'Nama Lengkap',
            'Minimal 3 karakter, gunakan nama asli',
          ),
          _buildHelpItem(
            Icons.phone_rounded,
            'Nomor Telepon',
            'Format: 08xxxxxxxxx, minimal 10 digit',
          ),
          _buildHelpItem(
            Icons.email_rounded,
            'Email',
            'Format email yang valid, verifikasi diperlukan jika diubah',
          ),
          _buildHelpItem(
            Icons.work_rounded,
            'Jenis Pekerjaan',
            'Contoh: Karyawan, Wiraswasta, Mahasiswa',
          ),
          _buildHelpItem(
            Icons.location_on_rounded,
            'Lokasi',
            'Kota/Kabupaten tempat tinggal',
          ),
          _buildHelpItem(
            Icons.attach_money_rounded,
            'Pendapatan',
            'Pendapatan bulanan dalam Rupiah',
          ),
          _buildHelpItem(
            Icons.lock_rounded,
            'Password',
            'Gunakan tombol "Ubah Password" untuk keamanan',
          ),
          const SizedBox(height: _spacing),
          _buildHelpFooter(),
        ],
      ),
    );
  }
  
  /// Membangun footer konten bantuan
  Widget _buildHelpFooter() {
    return Container(
      padding: const EdgeInsets.all(_smallSpacing),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(_iconPadding),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_rounded,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: _iconPadding),
          Expanded(
            child: Text(
              'Data yang akurat membantu mendapatkan rekomendasi program yang tepat.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Membangun item bantuan dengan ikon, judul, dan deskripsi
  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: _smallSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}