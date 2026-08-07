import 'package:edunest/app/UI/profile/settings_change_password_page.dart';
import 'package:edunest/app/UI/profile/settings_devices_page.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rw(8.0),
                  vertical: context.rh(8.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primary,
                        size: context.rw(AppValues.appBarIconSize),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: context.rf(22),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.rw(48)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rw(20.0),
                    vertical: context.rh(16.0),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsCard(
                        context,
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'You can change your password',
                        onTap: () =>
                            Get.to(() => const SettingsChangePasswordPage()),
                      ),
                      _buildSettingsCard(
                        context,
                        icon: Icons.smartphone_rounded,
                        title: 'Devices',
                        subtitle: 'Your current / active devices',
                        onTap: () => Get.to(() => const SettingsDevicesPage()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.rh(AppValues.paddingDefault)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.rw(16.0),
              vertical: context.rh(20.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.rw(AppValues.paddingMedium)),
                  decoration: BoxDecoration(
                    color: AppColors.blueBackground,
                    borderRadius: BorderRadius.circular(
                      context.rw(AppValues.radiusDefault),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: context.rw(AppValues.iconDefaultSize),
                  ),
                ),
                SizedBox(width: context.rw(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: context.rf(16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: context.rh(4)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.rf(12),
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.darkText,
                  size: context.rw(28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
