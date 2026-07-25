import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    // Compute Screen Resolution dynamically
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
              // Custom Header Row
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
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Device Information',
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
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
                      const SizedBox(height: 40),
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
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 14,
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
      height: 1,
      thickness: 0.5,
      indent: 16,
      endIndent: 16,
      color: AppColors.borderGrey.withValues(alpha: 0.5),
    );
  }
}
