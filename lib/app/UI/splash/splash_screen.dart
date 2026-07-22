import 'package:edunest/app/UI/login/login_page.dart';
import 'package:edunest/app/UI/login/tenant_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/tenant_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const int _splashMs = 3000;

  TenantModel? _tenant;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    TenantModel? tenant;
    try {
      tenant = await CommonService.getTenant();
    } catch (_) {
      tenant = null;
    }

    setState(() => _tenant = tenant);

    final Duration delay = Duration(
      milliseconds: tenant != null ? _splashMs ~/ 2 : _splashMs,
    );
    await Future.delayed(delay);
    Get.off(
      () => tenant != null ? const LoginPage() : const TenantPage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLogo(double screenWidth) {
    final tenant = _tenant;
    if (tenant != null) {
      final String bannerUrl = tenant.schoolBannerUrl;
      if (bannerUrl.isNotEmpty) {
        return Image.network(
          bannerUrl,
          width: screenWidth * 0.75,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              _defaultLogo(screenWidth),
        );
      }
    }
    return _defaultLogo(screenWidth);
  }

  Widget _defaultLogo(double screenWidth) {
    return Image.asset(
      'assets/images/full-icon.png',
      width: screenWidth * 0.75,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildLogo(screenWidth),
                ),
              ),
            ),
            Positioned(
              bottom: 40.0,
              left: 0.0,
              right: 0.0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SizedBox(
                    width: AppValues.iconSizeDefault,
                    height: AppValues.iconSizeDefault,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
