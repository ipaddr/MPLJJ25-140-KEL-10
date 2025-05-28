import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import '../../services/admin_auth_service.dart';
import '../widgets/admin_login_form_widget.dart';

/// Halaman login admin
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // Placeholder asset path for the logo
  final String logoAssetPath = 'assets/images/socio_care_logo1.png';
  final AdminAuthService _authService = AdminAuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in
    _checkLoginStatus();
  }

  /// Checks if the admin is already logged in and redirects if necessary
  Future<void> _checkLoginStatus() async {
    try {
      final bool isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn && mounted) {
        // User is already logged in, navigate to admin dashboard
        context.go(RouteNames.adminDashboard);
      }
    } catch (e) {
      // Handle error if needed
      debugPrint('Error checking login status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Image.asset(
                    logoAssetPath,
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.admin_panel_settings,
                        size: 50,
                        color: Colors.blue.shade700,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Memeriksa status login...',
                  style: TextStyle(fontSize: 16, color: Colors.blue.shade800),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                    _buildLogoSection(),
                    const SizedBox(height: 32.0),
                    _buildTitleSection(),
                    const SizedBox(height: 40.0),
                    _buildLoginFormSection(),
                    const SizedBox(height: 24.0),
                    _buildForgotPasswordLink(context),
                    const SizedBox(height: 16.0),
                    _buildRegisterLink(context),
                    const SizedBox(height: 16.0),
                    _buildUserLoginLink(context),
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

  /// Widget logo dengan badge admin
  Widget _buildLogoSection() {
    return Stack(
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
    );
  }

  /// Widget judul halaman
  Widget _buildTitleSection() {
    return Column(
      children: [
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
      ],
    );
  }

  /// Widget form login
  Widget _buildLoginFormSection() {
    return Container(
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
    );
  }

  /// Widget link lupa kata sandi
  Widget _buildForgotPasswordLink(BuildContext context) {
    return TextButton(
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
    );
  }

  /// Widget link register admin
  Widget _buildRegisterLink(BuildContext context) {
    return Container(
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
    );
  }

  /// Widget link login user
  Widget _buildUserLoginLink(BuildContext context) {
    return Container(
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
    );
  }
}