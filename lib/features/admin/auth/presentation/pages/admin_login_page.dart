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
                    // Logo with admin badge
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: Image.asset(
                            logoAssetPath,
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.admin_panel_settings,
                                size: 60,
                                color: Colors.blue.shade700,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),

                    // Title
                    Text(
                      'Admin Portal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Silahkan login untuk mengakses panel admin',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
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
                      child: const AdminLoginFormWidget(),
                    ),
                    const SizedBox(height: 24.0),

                    // Forgot Password Link
                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.adminForgotPassword);
                      },
                      child: Text(
                        'Lupa Kata Sandi Admin?',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Register Admin Link
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Colors.purple.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Belum punya akun admin? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(RouteNames.adminRegister);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.purple.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // User Login Link
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Login sebagai User? ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(RouteNames.login);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Klik Disini',
                              style: TextStyle(
                                color: Colors.green.shade800,
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
