import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/login/tenant_page.dart';
import 'package:edunest/app/UI/profile/about_us_page.dart';
import 'package:edunest/app/UI/profile/faq_page.dart';
import 'package:edunest/app/UI/profile/profile_page.dart';
import 'package:edunest/app/UI/profile/school_contacts_page.dart';
import 'package:edunest/app/UI/profile/settings_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student/student_model.dart';
import 'package:edunest/app/core/utils/responsive.dart';
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
    Navigator.pop(context);

    switch (title) {
      case 'My Profile':
      case 'Profile':
        Get.to(() => const ProfilePage());
        break;
      case 'School Contacts':
        Get.to(() => const SchoolContactsPage());
        break;
      case 'Settings':
        Get.to(() => const SettingsPage());
        break;
      case 'FAQ':
        Get.to(() => const FAQPage());
        break;
      case 'About Us':
        Get.to(() => const AboutUsPage());
        break;
      case 'Rate Us':
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double drawerWidth = MediaQuery.of(context).size.width * 0.90;
    final double maxDrawerWidth = context.isFoldableOrTablet ? 360 : 310;
    final student = _student;

    return SizedBox(
      width: drawerWidth < maxDrawerWidth ? drawerWidth : maxDrawerWidth,
      child: Drawer(
        backgroundColor: AppColors.colorWhite,
        surfaceTintColor: AppColors.transparent,
        elevation: 16,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rw(14),
                    vertical: context.rh(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radius16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            context.rw(AppValues.radius16),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(
                              context.rw(AppValues.paddingMedium),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.blueBackground,
                              borderRadius: BorderRadius.circular(
                                context.rw(AppValues.radius16),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: context.rw(24),
                                  backgroundColor: AppColors.secondary
                                      .withValues(alpha: 0.2),
                                  backgroundImage:
                                      (student != null && student.photoUrl.isNotEmpty)
                                      ? CachedNetworkImageProvider(
                                          student.photoUrl,
                                        )
                                      : null,
                                  child: (student != null && student.photoUrl.isNotEmpty)
                                      ? null
                                      : Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                          size: context.rw(28),
                                        ),
                                ),
                                SizedBox(width: context.rw(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student != null ? student.studentName : 'Loading...',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: context.rf(18),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                      SizedBox(height: context.rh(3)),
                                      Text(
                                        student != null ? student.email : '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: context.rf(13),
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
                      SizedBox(height: context.rh(14)),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          final String title = item['title'] as String;

                          return Padding(
                            padding: EdgeInsets.only(bottom: context.rh(8)),
                            child: Material(
                              color: AppColors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => _onMenuItemTap(title),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.rw(10),
                                    vertical: context.rh(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item['icon'] as IconData,
                                        size: context.rw(25),
                                        color: AppColors.darkGrey,
                                      ),
                                      SizedBox(width: context.rw(12)),
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            fontSize: context.rf(17),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: context.rw(AppValues.iconSizeMedium),
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
                      SizedBox(height: context.rh(10)),
                      Material(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            CommonService.clearSharedPreferences();
                            Get.offAll(() => const TenantPage());
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.rw(10),
                              vertical: context.rh(8),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: context.rw(25),
                                  color: AppColors.errorColor,
                                ),
                                SizedBox(width: context.rw(12)),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: context.rf(17),
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
