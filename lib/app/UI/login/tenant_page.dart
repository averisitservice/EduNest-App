import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/login/login_page.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/auth/tenant_model.dart';
import 'package:edunest/app/data/repository/tenant_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_divider.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:edunest/app/core/utils/responsive.dart';
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
              padding: EdgeInsets.symmetric(
                horizontal: context.rw(AppValues.paddingLarge),
                vertical: context.rh(AppValues.paddingXLarge),
              ),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxWidth: context.isFoldableOrTablet ? 480 : 440,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: context.rw(AppValues.paddingXLarge),
                  vertical: context.rh(36),
                ),
                decoration: BoxDecoration(
                  color: AppColors.colorWhite,
                  borderRadius: BorderRadius.circular(context.rw(AppValues.radius20)),
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
                      width: context.rw(200),
                      height: context.rh(150),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/full-icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: context.rh(24)),

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
                      SizedBox(height: context.rh(6)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: context.rw(4)),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: AppColors.errorColor,
                              fontSize: context.rf(AppValues.fontSizeSmall),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: context.rh(errorMessage != null ? 18 : 24)),

                    EdunestButton(
                      title: 'Proceed',
                      isLoading: isLoading,
                      onPressed: _handleProceed,
                    ),

                    SizedBox(height: context.rh(10)),

                    const EdunestDivider(
                      color: AppColors.borderGrey,
                      isDashed: true,
                    ),

                    SizedBox(height: context.rh(10)),

                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(
                        context.rw(AppValues.smallRadius),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rw(AppValues.paddingSmall),
                          vertical: context.rh(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primary,
                              size: context.rw(AppValues.margin18),
                            ),
                            SizedBox(width: context.rw(AppValues.paddingSmall)),
                            Text(
                              'Login Guide',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: context.rf(AppValues.fontSizeBody),
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
