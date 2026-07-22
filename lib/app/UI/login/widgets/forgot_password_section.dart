import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:flutter/material.dart';

class ForgotPasswordSection extends StatelessWidget {
  final TextEditingController mobileController;
  final String? mobileError;
  final VoidCallback onClose;
  final VoidCallback onGetOtp;
  final ValueChanged<String>? onChanged;

  const ForgotPasswordSection({
    super.key,
    required this.mobileController,
    this.mobileError,
    required this.onClose,
    required this.onGetOtp,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppValues.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppValues.radius_12),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'To change your password, kindly share your registered mobile number',
            style: TextStyle(
              fontSize: AppValues.fontSizeSmall,
              color: AppColors.darkGrey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          EdunestTextField(
            controller: mobileController,
            labelText: 'Mobile Number',
            hintText: 'Enter mobile number',
            keyboardType: TextInputType.number,
            maxLength: 10,
            onChanged: onChanged,
          ),
          if (mobileError != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                mobileError!,
                style: const TextStyle(
                  color: AppColors.errorColor,
                  fontSize: AppValues.fontSizeSmall,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          EdunestButton(title: 'Get OTP', onPressed: onGetOtp),
        ],
      ),
    );
  }
}
