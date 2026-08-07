import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:edunest/app/core/utils/responsive.dart';

class SettingsDevicesPage extends StatefulWidget {
  const SettingsDevicesPage({super.key});

  @override
  State<SettingsDevicesPage> createState() => _SettingsDevicesPageState();
}

class _SettingsDevicesPageState extends State<SettingsDevicesPage> {
  String _appVersion = '-';
  String _deviceName = '-';
  String _osVersion = '-';
  String _deviceModel = '-';
  String _deviceId = '-';

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';

      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await deviceInfo.webBrowserInfo;
        _deviceName = web.browserName.name;
        _osVersion = web.platform ?? 'Web';
        _deviceModel = web.userAgent ?? 'Web Browser';
      } else if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        _deviceName = '${android.manufacturer} ${android.model}'.trim();
        _osVersion =
            'Android ${android.version.release} (SDK ${android.version.sdkInt})';
        _deviceModel = android.model;
        _deviceId = android.id;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        _deviceName = ios.name;
        _osVersion = '${ios.systemName} ${ios.systemVersion}';
        _deviceModel = ios.utsname.machine;
        _deviceId = ios.identifierForVendor ?? '-';
      }
    } catch (_) {}

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final resolution =
        '${(size.width * pixelRatio).toInt()} x ${(size.height * pixelRatio).toInt()}';

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
                          'Device Information',
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
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.colorWhite,
                          borderRadius: BorderRadius.circular(
                            context.rw(AppValues.radiusLarge),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.colorBlack.withValues(
                                alpha: 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.smartphone_rounded,
                              label: 'Device Name',
                              value: _deviceName,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.settings_applications_rounded,
                              label: 'OS Version',
                              value: _osVersion,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.verified_user_outlined,
                              label: 'App Version',
                              value: _appVersion,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.phone_iphone_rounded,
                              label: 'Device Model',
                              value: _deviceModel,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.aspect_ratio_rounded,
                              label: 'Screen Resolution',
                              value: resolution,
                            ),
                            _buildDivider(),
                            _buildInfoRow(
                              icon: Icons.fingerprint_rounded,
                              label: 'Device ID',
                              value: _deviceId,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.rh(40)),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rh(14.0), horizontal: context.rw(16.0)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(context.rw(AppValues.paddingSmall)),
            decoration: BoxDecoration(
              color: AppColors.blueBackground,
              borderRadius: BorderRadius.circular(context.rw(AppValues.radiusMedium)),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: context.rw(AppValues.iconSizeMedium),
            ),
          ),
          SizedBox(width: context.rw(14)),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.only(top: context.rh(AppValues.paddingSmall)),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: context.rf(15),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),
          SizedBox(width: context.rw(16)),
          Expanded(
            flex: 6,
            child: Padding(
              padding: EdgeInsets.only(top: context.rh(AppValues.paddingSmall)),
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: context.rf(14),
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: AppValues.dividerHeight,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: AppColors.borderGrey.withValues(alpha: 0.5),
    );
  }
}
