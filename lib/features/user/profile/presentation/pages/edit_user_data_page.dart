import 'package:flutter/material.dart';
import 'package:socio_care/features/user/profile/presentation/widgets/edit_user_profile_form_widget.dart';

class EditUserDataPage extends StatelessWidget {
  const EditUserDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ubah Data Pengguna",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const EditUserProfileFormWidget(),
        ),
      ),
    );
  }
}
