import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/repository/auth_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsChangePasswordPage extends StatefulWidget {
  const SettingsChangePasswordPage({super.key});

  @override
  State<SettingsChangePasswordPage> createState() =>
      _SettingsChangePasswordPageState();
}

class _SettingsChangePasswordPageState
    extends State<SettingsChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthRepo _authRepo = AuthRepo();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    bool hasError = false;

    if (currentPassword.isEmpty) {
      _currentPasswordError = 'Please enter your current password';
      hasError = true;
    }

    if (newPassword.isEmpty) {
      _newPasswordError = 'Please enter your new password';
      hasError = true;
    } else if (newPassword.length < 6) {
      _newPasswordError = 'Password must be at least 6 characters';
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordError = 'Please confirm your new password';
      hasError = true;
    } else if (newPassword != confirmPassword) {
      _confirmPasswordError = 'Passwords do not match';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String message = await _authRepo.changePassword(
        currentPassword,
        newPassword,
      );

      if (!mounted) return;

      Get.snackbar(
        'Success',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: AppColors.colorWhite,
        margin: const EdgeInsets.all(AppValues.paddingDefault),
        borderRadius: AppValues.radiusDefault,
      );

      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      setState(() {
        if (msg.contains('current')) {
          _currentPasswordError = e.message;
        } else if (msg.contains('new')) {
          _newPasswordError = e.message;
        } else {
          _currentPasswordError = e.message;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
            image: AssetImage('assets/images/ChangePassword.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primary,
                        size: AppValues.appBarIconSize,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              EdunestTextField(
                                controller: _currentPasswordController,
                                labelText: 'Current Password',
                                hintText: 'Enter current password',
                                obscureText: _obscureCurrent,
                                suffixIcon: IconButton(
                                  iconSize: AppValues.iconSize20,
                                  icon: Icon(
                                    _obscureCurrent
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.primaryDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureCurrent = !_obscureCurrent;
                                    });
                                  },
                                ),
                                onChanged: (val) {
                                  if (_currentPasswordError != null &&
                                      val.trim().isNotEmpty) {
                                    setState(
                                      () => _currentPasswordError = null,
                                    );
                                  }
                                },
                              ),
                              if (_currentPasswordError != null) ...[
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    _currentPasswordError!,
                                    style: const TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: AppValues.fontSizeSmall,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ] else
                                const SizedBox(height: 16),
                              EdunestTextField(
                                controller: _newPasswordController,
                                labelText: 'New Password',
                                hintText: 'Enter new password',
                                obscureText: _obscureNew,
                                suffixIcon: IconButton(
                                  iconSize: AppValues.iconSize20,
                                  icon: Icon(
                                    _obscureNew
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.primaryDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureNew = !_obscureNew;
                                    });
                                  },
                                ),
                                onChanged: (val) {
                                  if (_newPasswordError != null &&
                                      val.trim().isNotEmpty) {
                                    setState(() => _newPasswordError = null);
                                  }
                                },
                              ),
                              if (_newPasswordError != null) ...[
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    _newPasswordError!,
                                    style: const TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: AppValues.fontSizeSmall,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ] else
                                const SizedBox(height: 16),
                              EdunestTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                hintText: 'Confirm new password',
                                obscureText: _obscureConfirm,
                                suffixIcon: IconButton(
                                  iconSize: AppValues.iconSize20,
                                  icon: Icon(
                                    _obscureConfirm
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.primaryDark,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirm = !_obscureConfirm;
                                    });
                                  },
                                ),
                                onChanged: (val) {
                                  if (_confirmPasswordError != null &&
                                      val.trim().isNotEmpty) {
                                    setState(
                                      () => _confirmPasswordError = null,
                                    );
                                  }
                                },
                              ),
                              if (_confirmPasswordError != null) ...[
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    _confirmPasswordError!,
                                    style: const TextStyle(
                                      color: AppColors.errorColor,
                                      fontSize: AppValues.fontSizeSmall,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ] else
                                const SizedBox(height: 24),
                              EdunestButton(
                                title: 'Save Password',
                                onPressed: _validateAndSubmit,
                                radius: AppValues.radius12,
                                gradientColors: const [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
