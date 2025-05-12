import 'package:flutter/material.dart';
import '../widgets/login_form_widget.dart';
import 'register_page.dart';
import 'forgot_password_page.dart'; // Pastikan file ini sudah dibuat

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  // Placeholder asset path for the logo
  final String logoAssetPath = 'assets/images/socio_care_logo1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC), // Light blue
              Color(0xFFE1F5FE), // Very light blue
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  logoAssetPath,
                  height: 100, // Adjust size as needed
                ),
                const SizedBox(height: 40.0),
                const LoginFormWidget(),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    // Navigasi ke Forgot Password Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default padding
                  ),
                  child: const Text(
                    'Lupa Kata Sandi',
                    style: TextStyle(
                      fontSize: 12.0, // Smaller font size
                      color: Colors.blue, // Blue color
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextButton(
                  onPressed: () {
                    // Navigasi ke Register Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Remove default padding
                  ),
                  child: const Text(
                    'Tidak Punya Akun? Registrasi',
                    style: TextStyle(
                      fontSize: 12.0, // Smaller font size
                      color: Colors.blue, // Blue color
                    ),
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
