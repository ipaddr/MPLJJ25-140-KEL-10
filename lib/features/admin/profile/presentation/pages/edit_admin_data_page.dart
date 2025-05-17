import 'package:flutter/material.dart';
import 'package:socio_care/features/admin/profile/presentation/widgets/edit_admin_profile_form_widget.dart';

class AdminEditProfilePage extends StatelessWidget {
  const AdminEditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Data Admin'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: AdminEditProfileFormWidget(),
      ),
    );
  }
}
