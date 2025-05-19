import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/admin_register_form_widget.dart';

class AdminRegisterPage extends StatelessWidget {
  const AdminRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regitrasi Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Admin Login
            context.go(RouteNames.adminLogin);
          },
        ),
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
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: AdminRegisterFormWidget(),
        ),
      ),
    );
  }
}
