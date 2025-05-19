import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/user_login_form_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  // Placeholder asset path for the logo
  final String logoAssetPath = 'assets/images/socio_care_logo1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(logoAssetPath, width: 120, height: 120),
                    const SizedBox(height: 32.0),
                    // Title
                    const Text(
                      'Selamat Datang',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Silahkan login untuk melanjutkan',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 32.0),
                    // Login Form
                    const LoginFormWidget(),
                    const SizedBox(height: 16.0),
                    // Forgot Password Link
                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.forgotPassword);
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Tidak Punya Akun? '),
                        TextButton(
                          onPressed: () {
                            context.go(RouteNames.register);
                          },
                          child: Text(
                            'Registrasi',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Admin Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Masuk sebagai Admin? '),
                        TextButton(
                          onPressed: () {
                            context.go(RouteNames.adminLogin);
                          },
                          child: Text(
                            'Klik Disini',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
