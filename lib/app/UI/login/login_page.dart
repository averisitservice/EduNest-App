import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/home/home_page.dart';
import 'package:edunest/app/UI/login/widgets/forgot_password_section.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/login_response_model.dart';
import 'package:edunest/app/data/model/tenant_model.dart';
import 'package:edunest/app/data/repository/auth_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_divider.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  final AuthRepo _authRepo = AuthRepo();

  bool _showPassword = true;
  bool _showForgotPassword = false;
  bool isLoading = false;

  String? userIdError;
  String? passwordError;
  String? mobileError;

  String version = '';

  TenantModel? _tenant;

  @override
  void initState() {
    super.initState();
    getAppVersion();
    _loadTenant();
  }

  Future<void> _loadTenant() async {
    TenantModel? tenant;
    try {
      tenant = await CommonService.getTenant();
    } catch (_) {
      tenant = null;
    }
    if (!mounted) return;
    setState(() => _tenant = tenant);
  }

  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version.split(RegExp(r'[+-]')).first;
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Widget _buildSchoolLogo() {
    final String logoUrl = _tenant?.mobileLogoUrl.isNotEmpty == true
        ? _tenant!.mobileLogoUrl
        : (_tenant?.logoUrl ?? '');
    if (logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 70,
        height: 70,
        fit: BoxFit.contain,
        placeholder: (context, url) => _defaultLogo(),
        errorWidget: (context, url, error) => _defaultLogo(),
      );
    }
    return _defaultLogo();
  }

  Widget _defaultLogo() {
    return Image.asset(
      'assets/images/full-icon.png',
      width: 70,
      height: 70,
      fit: BoxFit.contain,
    );
  }

  Future<void> _handleLogin() async {
    final username = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      userIdError = username.isEmpty ? 'Please enter User ID' : null;
      passwordError = password.isEmpty ? 'Please enter password' : null;
    });

    if (username.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final LoginResponseModel result = await _authRepo.login(
        username,
        password,
      );

      await CommonService.setSessionToken(result.session);
      await CommonService.setRefreshToken(result.refresh);
      await CommonService.setStudent(result.student);
      await CommonService.setTenant(result.tenant);

      if (!mounted) return;

      Get.off(
        () => const HomePage(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 400),
      );
    } on ApiException catch (e) {
      setState(() => passwordError = e.message);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _handleGetOtp() {
    final mobile = _mobileController.text.trim();

    setState(() {
      mobileError = mobile.isEmpty ? 'Please enter mobile number' : null;
    });

    if (mobile.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('OTP sent to $mobile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.blueBackground,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 220,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: const [
                Icon(Icons.chevron_left, color: AppColors.darkText, size: 24),
                SizedBox(width: 4),
                Text(
                  'Change School Code',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppValues.paddingLarge,
              vertical: AppValues.paddingDefault,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F366F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: _buildSchoolLogo()),
                ),
                const SizedBox(height: 12),
                Text(
                  _tenant?.tenantName.isNotEmpty == true
                      ? _tenant!.tenantName
                      : 'Loading school...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppValues.fontSizeBody,
                    color: AppColors.colorBlack,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppValues.paddingXLarge,
                    vertical: 28,
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
                      const Text(
                        'Kindly sign in to continue',
                        style: TextStyle(
                          fontSize: AppValues.fontSizeDefault,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      EdunestTextField(
                        controller: _userIdController,
                        labelText: 'User ID',
                        hintText: 'Enter user ID',
                        onChanged: (val) {
                          if (userIdError != null && val.trim().isNotEmpty) {
                            setState(() => userIdError = null);
                          }
                        },
                      ),
                      if (userIdError != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              userIdError!,
                              style: const TextStyle(
                                color: AppColors.errorColor,
                                fontSize: AppValues.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      EdunestTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Enter password',
                        obscureText: _showPassword,
                        suffixIcon: IconButton(
                          iconSize: 20,
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.primaryDark,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        onChanged: (val) {
                          if (passwordError != null && val.trim().isNotEmpty) {
                            setState(() => passwordError = null);
                          }
                        },
                      ),
                      if (passwordError != null) ...[
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              passwordError!,
                              style: const TextStyle(
                                color: AppColors.errorColor,
                                fontSize: AppValues.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      if (_showForgotPassword) ...[
                        ForgotPasswordSection(
                          mobileController: _mobileController,
                          mobileError: mobileError,
                          onClose: () {
                            setState(() {
                              _showForgotPassword = false;
                              mobileError = null;
                            });
                          },
                          onGetOtp: _handleGetOtp,
                          onChanged: (val) {
                            if (mobileError != null && val.trim().isNotEmpty) {
                              setState(() => mobileError = null);
                            }
                          },
                        ),
                      ] else ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showForgotPassword = true;
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: AppValues.fontSizeSmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        EdunestButton(
                          title: 'Login',
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        ),
                      ],

                      const SizedBox(height: 20),

                      const EdunestDivider(
                        color: AppColors.borderGrey,
                        isDashed: true,
                        height: 0,
                      ),

                      const SizedBox(height: 20),

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
                const SizedBox(height: 50),
                const Text(
                  'Powered By',
                  style: TextStyle(
                    fontSize: AppValues.fontSizeSmall,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.school_rounded,
                      color: AppColors.primaryDark,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'EDUNEST',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  version.isEmpty ? 'Version' : 'Version $version',
                  style: const TextStyle(
                    fontSize: AppValues.fontSizeSmall,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
