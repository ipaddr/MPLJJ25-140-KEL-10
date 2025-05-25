import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

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
  bool _isResending = false;
  late String _verificationId;
  late String _email;
  late String _adminId;
  late String _phoneNumber;
  
  // Timer for resend cooldown
  Timer? _timer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.resetData['verificationId'] as String;
    _email = widget.resetData['email'] as String;
    _adminId = widget.resetData['adminId'] as String;
    _phoneNumber = widget.resetData['phoneNumber'] as String;
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    setState(() {
      _resendCooldown = 60; // 60 seconds cooldown
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });
      
      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
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
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Verifikasi OTP berhasil'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
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
    if (_resendCooldown > 0) return;
    
    setState(() {
      _isResending = true;
    });
    
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Gagal mengirim ulang OTP: ${e.message}')),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Update verification ID
          _verificationId = verificationId;
          _startResendCooldown();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Kode OTP baru telah dikirim'),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Format +6281234567890 to +62 812-3456-7890
    if (phoneNumber.startsWith('+62') && phoneNumber.length >= 10) {
      final countryCode = phoneNumber.substring(0, 3);
      final number = phoneNumber.substring(3);
      if (number.length >= 9) {
        return '$countryCode ${number.substring(0, 3)}-${number.substring(3, 7)}-${number.substring(7)}';
      }
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi OTP',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(RouteNames.adminForgotPassword);
          },
        ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header Section
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
                  child: Column(
                    children: [
                      // OTP Icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.sms_rounded,
                          size: 50,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Title
                      Text(
                        'Verifikasi OTP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Kode OTP telah dikirim ke nomor:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        _formatPhoneNumber(_phoneNumber),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Form Section
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Info Box
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                color: Colors.green.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Masukkan 6 digit kode OTP yang diterima untuk verifikasi identitas admin.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Field
                        TextFormField(
                          controller: _otpController,
                          decoration: InputDecoration(
                            labelText: 'Kode OTP',
                            hintText: 'Masukkan 6 digit kode OTP',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.vpn_key_rounded,
                              color: Colors.grey.shade600,
                            ),
                            counterText: '', // Hide character counter
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                          enabled: !_isVerifying,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kode OTP tidak boleh kosong';
                            }
                            if (value.length != 6) {
                              return 'Kode OTP harus 6 digit';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Kode OTP hanya boleh berisi angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),

                        // Verify Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            icon: _isVerifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.verified_user_rounded),
                            label: Text(_isVerifying ? 'Memverifikasi...' : 'Verifikasi OTP'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066CC),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 20.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Resend OTP Button
                        OutlinedButton.icon(
                          onPressed: (_isResending || _resendCooldown > 0) ? null : _resendOtp,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                          label: Text(
                            _resendCooldown > 0
                                ? 'Kirim Ulang dalam ${_resendCooldown}s'
                                : _isResending
                                    ? 'Mengirim...'
                                    : 'Kirim Ulang Kode OTP',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Back to Email Link
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Email salah? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(RouteNames.adminForgotPassword);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Ubah Email',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}