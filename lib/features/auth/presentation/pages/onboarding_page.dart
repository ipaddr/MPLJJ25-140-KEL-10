import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/auth/presentation/widgets/onboarding_slider_widget.dart';
import 'package:socio_care/features/auth/data/models/onboarding_data.dart';

/// Halaman onboarding yang menampilkan fitur utama aplikasi
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  // Controllers
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  
  // Animations
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  // State
  int _currentPage = 0;

  // Constants
  static const _animationDuration = Duration(milliseconds: 600);
  static const _pageSwitchDuration = Duration(milliseconds: 300);
  
  // Onboarding data
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      icon: Icons.handshake_rounded,
      title: "Program Bantuan Sosial",
      subtitle: "Akses Mudah ke Berbagai Program",
      description:
          "Dapatkan akses ke berbagai program bantuan sosial dan usaha mikro yang sesuai dengan kebutuhan Anda.",
      color: Colors.blue,
      gradient: [Colors.blue.shade400, Colors.blue.shade600],
    ),
    OnboardingData(
      icon: Icons.smart_toy_rounded,
      title: "Chatbot AI Pintar",
      subtitle: "Konsultasi 24/7",
      description:
          "Konsultasikan kebutuhan dan pertanyaan Anda dengan chatbot AI yang siap membantu kapan saja.",
      color: Colors.green,
      gradient: [Colors.green.shade400, Colors.green.shade600],
    ),
    OnboardingData(
      icon: Icons.trending_up_rounded,
      title: "Kesejahteraan Bersama",
      subtitle: "Capai Impian Anda",
      description:
          "Bersama SocioCare, wujudkan kesejahteraan dan capai impian yang Anda dambakan untuk masa depan.",
      color: Colors.purple,
      gradient: [Colors.purple.shade400, Colors.purple.shade600],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  /// Inisialisasi animasi
  void _initAnimations() {
    _animationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Berpindah ke halaman berikutnya
  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _animationController.reset();
      _pageController.nextPage(
        duration: _pageSwitchDuration,
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    } else {
      _navigateToLogin();
    }
  }

  /// Berpindah ke halaman sebelumnya
  void _previousPage() {
    if (_currentPage > 0) {
      _animationController.reset();
      _pageController.previousPage(
        duration: _pageSwitchDuration,
        curve: Curves.easeInOut,
      );
      _animationController.forward();
    }
  }

  /// Melewati onboarding
  void _skipPages() => _navigateToLogin();

  /// Navigasi ke halaman login
  void _navigateToLogin() {
    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  /// Pergi ke halaman tertentu
  void _goToPage(int index) {
    _animationController.reset();
    _pageController.animateToPage(
      index,
      duration: _pageSwitchDuration,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _onboardingData[_currentPage].gradient[0].withValues(alpha: 0.1),
              _onboardingData[_currentPage].gradient[1].withValues(alpha: 0.2),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(isSmallScreen),
              _buildPageIndicator(),
              _buildPageView(size),
              _buildBottomNavigation(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget bar bagian atas dengan logo dan tombol lewati
  Widget _buildTopBar(bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: isSmallScreen ? 8.0 : 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(isSmallScreen),
          if (_currentPage < _onboardingData.length - 1)
            _buildSkipButton(isSmallScreen),
        ],
      ),
    );
  }

  /// Widget logo dan nama aplikasi
  Widget _buildLogo(bool isSmallScreen) {
    return GestureDetector(
      onTap: () => _goToPage(_onboardingData.length - 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.blue.shade600,
              size: isSmallScreen ? 18 : 22,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SocioCare',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  /// Widget tombol lewati
  Widget _buildSkipButton(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: TextButton(
        onPressed: _skipPages,
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 4 : 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Lewati',
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// Widget indikator halaman
  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _onboardingData.length,
          (index) => GestureDetector(
            onTap: () => _goToPage(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 24 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentPage == index
                    ? _onboardingData[_currentPage].color
                    : Colors.grey.shade300,
                boxShadow: _currentPage == index
                    ? [
                        BoxShadow(
                          color: _onboardingData[_currentPage].color
                              .withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget konten halaman
  Widget _buildPageView(Size size) {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
          _animationController.reset();
          _animationController.forward();
        },
        itemCount: _onboardingData.length,
        itemBuilder: (context, index) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: OnboardingSliderWidget(
                data: _onboardingData[index],
                screenSize: size,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget navigasi bawah
  Widget _buildBottomNavigation(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPreviousButton(isSmallScreen),
          _buildProgressText(isSmallScreen),
          _buildNextButton(isSmallScreen),
        ],
      ),
    );
  }

  /// Widget tombol sebelumnya
  Widget _buildPreviousButton(bool isSmallScreen) {
    return AnimatedOpacity(
      opacity: _currentPage > 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: isSmallScreen ? 44 : 48,
        height: isSmallScreen ? 44 : 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            isSmallScreen ? 22 : 24,
          ),
          border: Border.all(
            color: _onboardingData[_currentPage].color
                .withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _currentPage > 0 ? _previousPage : null,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: _onboardingData[_currentPage].color,
            size: isSmallScreen ? 18 : 20,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Widget teks progres
  Widget _buildProgressText(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: _onboardingData[_currentPage].color.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _onboardingData[_currentPage].color.withValues(
            alpha: 0.2,
          ),
          width: 1,
        ),
      ),
      child: Text(
        '${_currentPage + 1}/${_onboardingData.length}',
        style: TextStyle(
          fontSize: isSmallScreen ? 10 : 12,
          fontWeight: FontWeight.w600,
          color: _onboardingData[_currentPage].color,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  /// Widget tombol berikutnya
  Widget _buildNextButton(bool isSmallScreen) {
    final isLastPage = _currentPage == _onboardingData.length - 1;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          isSmallScreen ? 22 : 24,
        ),
        gradient: LinearGradient(
          colors: _onboardingData[_currentPage].gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: _onboardingData[_currentPage].color
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _nextPage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 20 : 28,
            vertical: isSmallScreen ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              isSmallScreen ? 22 : 24,
            ),
          ),
          elevation: 0,
        ),
        icon: Icon(
          isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
          color: Colors.white,
          size: isSmallScreen ? 16 : 18,
        ),
        label: Text(
          isLastPage ? 'Mulai' : 'Lanjut',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}