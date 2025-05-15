import 'package:flutter/material.dart';
import 'package:socio_care/features/user/profile/presentation/widgets/edit_user_profile_form_widget.dart';

class EditUserDataPage extends StatelessWidget {
  const EditUserDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Data Pengguna')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: EditUserProfileFormWidget(),
      ),
    );
  }
}
