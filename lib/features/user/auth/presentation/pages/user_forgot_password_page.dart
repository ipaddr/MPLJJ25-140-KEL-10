import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Kata Sandi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to Login
            context.go(RouteNames.login);
          },
        ),
        elevation: 0, // Remove shadow
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.blue.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(RouteNames.userOtp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Reset Kata Sandi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
