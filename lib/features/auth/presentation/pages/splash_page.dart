import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';

/// Halaman splash screen yang ditampilkan saat aplikasi pertama kali dibuka
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _progressController;

  // Animations
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _progressAnimation;

  // Constants
  static const _logoAnimationDuration = Duration(milliseconds: 1200);
  static const _textAnimationDuration = Duration(milliseconds: 800);
  static const _progressAnimationDuration = Duration(milliseconds: 2000);
  static const _splashDuration = Duration(seconds: 3);
  static const _textStartDelay = Duration(milliseconds: 400);
  static const _progressStartDelay = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _startAnimations();
    _scheduleNavigation();
  }

  /// Inisialisasi controller animasi
  void _initControllers() {
    _logoController = AnimationController(
      duration: _logoAnimationDuration,
      vsync: this,
    );

    _textController = AnimationController(
      duration: _textAnimationDuration,
      vsync: this,
    );

    _progressController = AnimationController(
      duration: _progressAnimationDuration,
      vsync: this,
    );
  }

  /// Inisialisasi animasi
  void _initAnimations() {
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  /// Memulai sekuens animasi
  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation after delay
    await Future.delayed(_textStartDelay);
    if (mounted) {
      _textController.forward();
    }

    // Start progress animation after delay
    await Future.delayed(_progressStartDelay);
    if (mounted) {
      _progressController.forward();
    }
  }

  /// Menjadwalkan navigasi ke halaman berikutnya
  void _scheduleNavigation() {
    Timer(_splashDuration, () {
      if (mounted) {
        context.go(RouteNames.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundDecoration(),
              _buildFloatingElements(size),
              _buildCenterContent(),
              _buildBottomSection(size),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget dekorasi background
  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  /// Widget elemen mengambang sebagai dekorasi
  Widget _buildFloatingElements(Size size) {
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.1,
          right: size.width * 0.1,
          child: _buildFloatingCircle(
            60,
            Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Positioned(
          top: size.height * 0.7,
          left: size.width * 0.1,
          child: _buildFloatingCircle(
            40,
            Colors.white.withValues(alpha: 0.08),
          ),
        ),
        Positioned(
          top: size.height * 0.3,
          left: size.width * 0.85,
          child: _buildFloatingCircle(
            25,
            Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  /// Widget konten utama di tengah
  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedLogo(),
          const SizedBox(height: 32),
          _buildAnimatedText(),
        ],
      ),
    );
  }

  /// Widget logo dengan animasi
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _logoFadeAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.blue.shade300.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/socio_care_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget teks aplikasi dengan animasi
  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _textSlideAnimation,
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          children: [
            Text(
              'SocioCare',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildTagline(),
          ],
        ),
      ),
    );
  }

  /// Widget tagline aplikasi
  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Akses Mudah, Hidup Sejahtera',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Poppins',
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget bagian bawah dengan progress dan versi
  Widget _buildBottomSection(Size size) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Column(
        children: [
          _buildProgressBar(size),
          const SizedBox(height: 16),
          _buildLoadingText(),
          const SizedBox(height: 24),
          _buildVersionInfo(),
        ],
      ),
    );
  }

  /// Widget progress bar dengan animasi
  Widget _buildProgressBar(Size size) {
    final progressWidth = size.width * 0.6;
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: progressWidth,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: progressWidth * _progressAnimation.value,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Widget teks loading
  Widget _buildLoadingText() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Text(
        'Mempersiapkan aplikasi...',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.8),
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Widget informasi versi
  Widget _buildVersionInfo() {
    return FadeTransition(
      opacity: _textFadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Membuat lingkaran mengambang untuk dekorasi
  Widget _buildFloatingCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}