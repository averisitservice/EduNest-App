import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = packageInfo.version.split(RegExp(r'[+-]')).first;
    });
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
                          'About Us',
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.rw(24.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.rh(24)),
                      _buildInfoTile(
                        icon: Icons.smartphone_outlined,
                        title: 'Application Version',
                        subtitle: _version.isEmpty
                            ? 'Version'
                            : '$_version version',
                      ),
                      _buildInfoTile(
                        icon: Icons.phone_android_outlined,
                        title: 'Mobile Number',
                        subtitle: '7016661961',
                      ),
                      _buildInfoTile(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email Address',
                        subtitle: 'averisitservice@gmail.com',
                      ),
                      _buildInfoTile(
                        icon: Icons.language_rounded,
                        title: 'Website',
                        subtitle: 'https://averisitservices.in',
                      ),
                      const Spacer(),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Powered By',
                              style: TextStyle(
                                fontSize: context.rf(AppValues.fontSizeSmall),
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.rh(6)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.primary,
                                  size: context.rw(18),
                                ),
                                SizedBox(width: context.rw(8)),
                                Text(
                                  'EDUNEXT',
                                  style: TextStyle(
                                    fontSize: context.rf(AppValues.fontSizeDefault),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.9,
                                    ),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.rh(24)),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rh(16.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: context.rw(26)),
          SizedBox(width: context.rw(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.rf(15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: context.rh(4)),
                Text(
                  subtitle,
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
    );
  }
}
