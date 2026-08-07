import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/core/utils/responsive.dart';

class EdunestConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const EdunestConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EdunestConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
      ),
      backgroundColor: AppColors.colorWhite,
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.isFoldableOrTablet ? 480 : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.all(context.rw(AppValues.paddingLarge)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isDestructive
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline_rounded,
                    color: isDestructive ? AppColors.errorColor : AppColors.primary,
                    size: context.rw(24),
                  ),
                  SizedBox(width: context.rw(10)),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: context.rf(AppValues.fontSizeSubTitle),
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.rh(16)),
              Text(
                message,
                style: TextStyle(
                  fontSize: context.rf(AppValues.fontSizeBody),
                  color: AppColors.darkGrey,
                  height: 1.4,
                ),
              ),
              SizedBox(height: context.rh(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rw(AppValues.paddingDefault),
                        vertical: context.rh(AppValues.paddingMedium),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(context.rw(AppValues.radiusDefault)),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: context.rf(14),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  SizedBox(
                    width: context.rw(100),
                    height: context.rh(40),
                    child: EdunestButton(
                      title: confirmText,
                      onPressed: () => Navigator.pop(context, true),
                      useGradient: !isDestructive,
                      backgroundColor:
                          isDestructive ? AppColors.errorColor : AppColors.primary,
                      gradientEndColor:
                          isDestructive ? AppColors.errorColor : AppColors.secondary,
                      fontSize: 14,
                      radius: AppValues.radiusDefault,
                      verticalPadding: 0,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
