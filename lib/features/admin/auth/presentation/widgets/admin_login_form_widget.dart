import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

class AdminLoginFormWidget extends StatefulWidget {
  const AdminLoginFormWidget({super.key});

  @override
  _AdminLoginFormWidgetState createState() => _AdminLoginFormWidgetState();
}

class _AdminLoginFormWidgetState extends State<AdminLoginFormWidget> {
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Processing Admin Login')));
      context.go(RouteNames.adminDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email),
              hintText: 'Email',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              isDense: true,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              // Add basic email format validation if needed
              if (!value.contains('@')) {
                return 'Masukkan email yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              hintText: 'Password',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              isDense: true,
            ),
            obscureText: !_isPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata Sandi tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 15.0,
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
            child: const Text('Masuk Admin'),
          ),
        ],
      ),
    );
  }
}
