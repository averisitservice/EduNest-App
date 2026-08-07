import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class ForgotPasswordSection extends StatelessWidget {
  final TextEditingController emailController;
  final String? emailError;
  final bool isLoading;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onChanged;

  const ForgotPasswordSection({
    super.key,
    required this.emailController,
    this.emailError,
    this.isLoading = false,
    required this.onClose,
    required this.onSubmit,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rw(AppValues.paddingMedium)),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radius12)),
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
              Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: context.rf(AppValues.fontSizeBody),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.textMuted,
                  size: context.rw(22),
                ),
              ),
            ],
          ),
          SizedBox(height: context.rh(8)),
          Text(
            'To reset your password, kindly share your registered email address',
            style: TextStyle(
              fontSize: context.rf(AppValues.fontSizeSmall),
              color: AppColors.darkGrey,
              height: 1.3,
            ),
          ),
          SizedBox(height: context.rh(16)),
          EdunestTextField(
            controller: emailController,
            labelText: 'Email Address',
            hintText: 'Enter registered email',
            keyboardType: TextInputType.emailAddress,
            onChanged: onChanged,
          ),
          if (emailError != null) ...[
            SizedBox(height: context.rh(6)),
            Padding(
              padding: EdgeInsets.only(left: context.rw(4)),
              child: Text(
                emailError!,
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontSize: context.rf(AppValues.fontSizeSmall),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: context.rh(16)),
          EdunestButton(
            title: 'Send New Password',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
