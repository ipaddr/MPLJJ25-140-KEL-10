import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class UserNewPasswordPage extends StatelessWidget {
  const UserNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Kata Sandi Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.userOtp);
          },
        ),
        elevation: 0, // Remove shadow
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Kata Sandi Baru',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Konfirmasi Kata Sandi Baru',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement save new password logic
                  context.go(RouteNames.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 20.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                child: const Text('Simpan Kata Sandi Baru'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
