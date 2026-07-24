import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/login/login_page.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/tenant_model.dart';
import 'package:edunest/app/data/repository/tenant_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_divider.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TenantPage extends StatefulWidget {
  const TenantPage({super.key});

  @override
  State<TenantPage> createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantPage> {
  final TextEditingController _schoolCodeController = TextEditingController();
  final TenantRepo _tenantRepo = TenantRepo();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _schoolCodeController.dispose();
    super.dispose();
  }

  void _warmImageCache(TenantModel tenant) {
    for (final url in [
      tenant.schoolBannerUrl,
      tenant.mobileLogoUrl,
      tenant.logoUrl,
    ]) {
      if (url.isNotEmpty) {
        CachedNetworkImageProvider(url).resolve(const ImageConfiguration());
      }
    }
  }

  Future<void> _handleProceed() async {
    final code = _schoolCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'Please enter school code';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final TenantModel tenant = await _tenantRepo.getTenantBySchoolCode(code);
      await CommonService.setTenant(tenant);
      _warmImageCache(tenant);

      if (!mounted) return;

      Get.to(
        () => const LoginPage(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 400),
      );
    } on ApiException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BackGroud.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppValues.paddingLarge,
                vertical: AppValues.paddingXLarge,
              ),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppValues.paddingXLarge,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: AppColors.colorWhite,
                  borderRadius: BorderRadius.circular(AppValues.radius_20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: AppValues.largeElevation,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/full-icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    EdunestTextField(
                      controller: _schoolCodeController,
                      labelText: 'School Code',
                      hintText: 'Enter school code',
                      onChanged: (value) {
                        if (errorMessage != null && value.trim().isNotEmpty) {
                          setState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorColor,
                              fontSize: AppValues.fontSizeSmall,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: errorMessage != null ? 18 : 24),

                    EdunestButton(
                      title: 'Proceed',
                      isLoading: isLoading,
                      onPressed: _handleProceed,
                    ),

                    const SizedBox(height: 10),

                    const EdunestDivider(
                      color: AppColors.borderGrey,
                      isDashed: true,
                    ),

                    const SizedBox(height: 10),

                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(
                        AppValues.smallRadius,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppValues.paddingSmall,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primary,
                              size: AppValues.margin_18,
                            ),
                            SizedBox(width: AppValues.paddingSmall),
                            Text(
                              'Login Guide',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: AppValues.fontSizeBody,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
