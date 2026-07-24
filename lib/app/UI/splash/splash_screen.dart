import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/home/home_page.dart';
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

  TenantModel? _tenant;
  bool _showBanner = false;

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

    _startTimer();
  }

  Future<void> _startTimer() async {
    TenantModel? tenant;
    String? sessionToken;
    try {
      tenant = await CommonService.getTenant();
      sessionToken = await CommonService.getSessionToken();
    } catch (_) {
      tenant = null;
      sessionToken = null;
    }

    if (!mounted) return;
    setState(() {
      _tenant = tenant;
      if (tenant != null && tenant.schoolBannerUrl.isNotEmpty) {
        _showBanner = true;
      }
    });

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    Widget nextScreen;
    if (tenant != null) {
      if (sessionToken != null && sessionToken.isNotEmpty) {
        nextScreen = const HomePage();
      } else {
        nextScreen = const LoginPage();
      }
    } else {
      nextScreen = const TenantPage();
    }

    Get.off(
      () => nextScreen,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 600),
    );
  }

  Widget _buildDefaultSplashBody(double screenWidth) {
    return Stack(
      children: [
        Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _defaultLogo(screenWidth),
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
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultLogo(double screenWidth) {
    return Image.asset(
      'assets/images/full-icon.png',
      width: screenWidth * 0.75,
      fit: BoxFit.contain,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final String bannerUrl = _tenant?.schoolBannerUrl ?? '';

    if (_showBanner && bannerUrl.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppColors.colorWhite,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: CachedNetworkImage(
                imageUrl: bannerUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
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
                errorWidget: (context, url, error) => Center(
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
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: SafeArea(child: _buildDefaultSplashBody(screenWidth)),
    );
  }
}
