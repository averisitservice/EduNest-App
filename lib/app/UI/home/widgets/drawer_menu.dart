import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/login/login_page.dart';
import 'package:edunest/app/UI/profile/profile_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  StudentModel? _student;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final student = await CommonService.getStudent();
    if (!mounted) return;
    setState(() {
      _student = student;
    });
  }

  final List<Map<String, dynamic>> _menuItems = const [
    {'title': 'My Profile', 'icon': Icons.person_outline_rounded},
    {'title': 'School Contacts', 'icon': Icons.headset_mic_outlined},
    {'title': 'Settings', 'icon': Icons.settings_outlined},
    {'title': 'FAQ', 'icon': Icons.settings_outlined},
    {'title': 'About Us', 'icon': Icons.error_outline_rounded},
    {'title': 'Rate Us', 'icon': Icons.star_outline_rounded},
  ];

  void _onMenuItemTap(String title) {
    Navigator.pop(context); // Close drawer first

    switch (title) {
      case 'My Profile':
      case 'Profile':
        Get.to(() => const ProfilePage());
        break;
      case 'School Contacts':
        // Get.to(() => const SchoolContactsPage());
        break;
      case 'Settings':
        // Get.to(() => const SettingsPage());
        break;
      case 'FAQ':
        // Get.to(() => const FAQPage());
        break;
      case 'About Us':
        // Get.to(() => const AboutUsPage());
        break;
      case 'Rate Us':
        // Get.to(() => const RateUsPage());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.90;

    return SizedBox(
      width: drawerWidth < 310 ? drawerWidth : 310,
      child: Drawer(
        backgroundColor: AppColors.colorWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          AppValues.radius_16,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppValues.radius_16,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppValues.paddingMedium,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blueBackground,
                              borderRadius: BorderRadius.circular(
                                AppValues.radius_16,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.2),
                                  backgroundImage:
                                      _student?.photoUrl.isNotEmpty == true
                                      ? CachedNetworkImageProvider(
                                          _student!.photoUrl,
                                        )
                                      : null,
                                  child: _student?.photoUrl.isNotEmpty == true
                                      ? null
                                      : const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: 28,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _student?.studentName ?? 'Loading...',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        _student?.email ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.darkGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final String title = item['title'] as String;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => _onMenuItemTap(title),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        size: 25,
                                        color: AppColors.darkGrey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        size: AppValues.iconSizeMedium,
                                        color: AppColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            CommonService.clearSharedPreferences();
                            Get.offAll(() => const LoginPage());
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),

                            child: Row(
                              children: const [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 25,
                                  color: AppColors.errorColor,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.errorColor,
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
