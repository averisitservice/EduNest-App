import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:flutter/material.dart';

class CustomPermissionDialog extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const CustomPermissionDialog({
    super.key,
    required this.icon,
    required this.message,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      ),
      backgroundColor: AppColors.colorWhite,
      clipBehavior: Clip.antiAlias, // Ensures the ink splash respects the border radius
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            // Centered icon
            Center(
              child: Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Centered prompt text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppValues.fontSizeDefault,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkText,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // First Divider before Allow button
            const Divider(
              height: AppValues.dividerHeight,
              thickness: AppValues.dividerThickness,
              color: AppColors.borderGrey,
            ),
            // Allow button
            InkWell(
              onTap: onAllow,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const Text(
                  'Allow',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppValues.fontSizeDefault,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Second Divider before Deny button
            const Divider(
              height: AppValues.dividerHeight,
              thickness: AppValues.dividerThickness,
              color: AppColors.borderGrey,
            ),
            // Deny button
            InkWell(
              onTap: onDeny,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: const Text(
                  'Deny',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppValues.fontSizeDefault,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
