import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../widgets/admin_login_form_widget.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});
  // Placeholder asset path for the logo
  final String logoAssetPath = 'assets/images/socio_care_logo1.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      'Selamat Datang Admin',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Silahkan login sebagai admin untuk melanjutkan',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 32.0),
                    // Login Form
                    const AdminLoginFormWidget(),
                    const SizedBox(height: 16.0),
                    // Forgot Password Link
                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.adminForgotPassword);
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // Register Link (for admin registration, though often admins are created differently)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Belum punya akun admin? '),
                        TextButton(
                          onPressed: () {
                            context.go(
                              RouteNames.adminRegister,
                            ); // Navigate to Admin Register
                          },
                          child: Text(
                            'Registrasi Admin',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Option to login as User
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Masuk sebagai Pengguna? '),
                        TextButton(
                          onPressed: () {
                            context.go(
                              RouteNames.login,
                            ); // Navigate to User Login
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
