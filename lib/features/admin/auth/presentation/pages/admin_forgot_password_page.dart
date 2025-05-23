import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminForgotPasswordPage extends StatefulWidget {
  const AdminForgotPasswordPage({super.key});

  @override
  State<AdminForgotPasswordPage> createState() =>
      _AdminForgotPasswordPageState();
}

class _AdminForgotPasswordPageState extends State<AdminForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _adminId;
  String? _phoneNumber;

  Future<void> _requestPasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Find admin by email in Firestore
        final adminQuerySnapshot =
            await FirebaseFirestore.instance
                .collection('admins')
                .where('email', isEqualTo: _emailController.text.trim())
                .limit(1)
                .get();

        if (adminQuerySnapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No admin account found with that email.',
          );
        }

        // 2. Get admin data including phone number
        final adminDoc = adminQuerySnapshot.docs.first;
        _adminId = adminDoc.id;
        _phoneNumber = adminDoc.data()['phoneNumber'];

        if (_phoneNumber == null || _phoneNumber!.isEmpty) {
          throw Exception('Admin account does not have a phone number.');
        }

        // Format phone number to ensure it has international format
        if (!_phoneNumber!.startsWith('+')) {
          // If it starts with 0, replace with +62 (for Indonesia)
          if (_phoneNumber!.startsWith('0')) {
            _phoneNumber = '+62${_phoneNumber!.substring(1)}';
          } else {
            // Otherwise, just add +62
            _phoneNumber = '+62$_phoneNumber';
          }
        }

        // 3. Send SMS OTP using Firebase Phone Auth
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumber!,
          verificationCompleted: (PhoneAuthCredential credential) {
            // This won't be triggered for password reset - it's for Android auto-verification
          },
          verificationFailed: (FirebaseAuthException e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verifikasi gagal: ${e.message}')),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            // Navigate to OTP input screen with necessary data
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kode OTP telah dikirim ke nomor telepon Anda'),
                ),
              );

              context.go(
                RouteNames.adminOtp,
                extra: {
                  'email': _emailController.text.trim(),
                  'verificationId': verificationId,
                  'adminId': _adminId,
                  'phoneNumber': _phoneNumber,
                },
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            // Auto-retrieval timed out
          },
          timeout: const Duration(seconds: 60),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Terjadi kesalahan saat mengirim kode OTP.';

        if (e.code == 'user-not-found') {
          errorMessage = 'Email tidak terdaftar.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Format email tidak valid.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lupa Kata Sandi Admin'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminLogin);
          },
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Masukkan email terdaftar',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _requestPasswordReset,
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
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kirim Kode OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
