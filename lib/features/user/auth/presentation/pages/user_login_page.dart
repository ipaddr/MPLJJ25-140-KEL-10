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
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: Image.asset(
                        logoAssetPath,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue.shade700,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    
                    // Title
                    Text(
                      'Selamat Datang!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Silahkan login untuk melanjutkan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    
                    // Login Form
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const LoginFormWidget(),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Forgot Password Link
                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.forgotPassword);
                      },
                      child: Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Register Link
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(RouteNames.register);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Admin Login Link
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Login sebagai Admin? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(RouteNames.adminLogin);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Klik Disini',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
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