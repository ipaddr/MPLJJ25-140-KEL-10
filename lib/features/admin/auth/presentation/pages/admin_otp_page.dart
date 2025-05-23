import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminOtpPage extends StatefulWidget {
  final Map<String, dynamic> resetData;
  
  const AdminOtpPage({
    super.key, 
    required this.resetData,
  });

  @override
  State<AdminOtpPage> createState() => _AdminOtpPageState();
}

class _AdminOtpPageState extends State<AdminOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  late String _verificationId;
  late String _email;
  late String _adminId;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.resetData['verificationId'] as String;
    _email = widget.resetData['email'] as String;
    _adminId = widget.resetData['adminId'] as String;
    _phoneNumber = widget.resetData['phoneNumber'] as String;
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifying = true;
      });
      
      try {
        // Create a credential with the verification ID and user-entered OTP
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _otpController.text.trim(),
        );
        
        // Sign in with the credential (to verify the OTP)
        await FirebaseAuth.instance.signInWithCredential(credential);
        
        // OTP is verified, now navigate to reset password screen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verifikasi OTP berhasil')),
          );
          
          context.go(
            RouteNames.adminNewPassword,
            extra: {
              'email': _email,
              'adminId': _adminId,
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Terjadi kesalahan saat verifikasi OTP.';
        
        if (e.code == 'invalid-verification-code') {
          errorMessage = 'Kode OTP tidak valid.';
        } else if (e.code == 'invalid-verification-id') {
          errorMessage = 'Sesi verifikasi telah kedaluwarsa.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isVerifying = true;
    });
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim ulang OTP: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Update verification ID
          _verificationId = verificationId;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kode OTP baru telah dikirim')),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminForgotPassword);
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
                Text(
                  'Kode OTP telah dikirim ke nomor ponsel yang terkait dengan email $_email',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'Kode OTP',
                    hintText: 'Masukkan 6 digit kode OTP',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode OTP tidak boleh kosong';
                    }
                    if (value.length != 6) {
                      return 'Kode OTP harus 6 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOtp,
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
                  child: _isVerifying 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Verifikasi OTP'),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: _isVerifying ? null : _resendOtp,
                  child: const Text('Kirim Ulang Kode OTP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}