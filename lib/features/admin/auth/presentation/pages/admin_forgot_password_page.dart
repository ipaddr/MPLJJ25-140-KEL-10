import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminForgotPasswordPage extends StatelessWidget {
  const AdminForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Kata Sandi Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Admin Login
            context.go(RouteNames.adminLogin);
          },
        ),
        elevation: 0, // Remove shadow
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF64B5F6), // Light blue
              Color(0xFF2196F3), // Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Masukkan Email atau Nomor Telepon yang terdaftar untuk mereset kata sandi admin Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0, color: Colors.white70),
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Nomor Telepon atau Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.text, // Can be email or phone
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon atau Email tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement admin password reset logic
                },
                child: const Text('Reset Kata Sandi Admin'), // Button text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
