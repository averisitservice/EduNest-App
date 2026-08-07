import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/core/utils/responsive.dart';

class EdunestButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? gradientEndColor;
  final List<Color>? gradientColors;
  final bool useGradient;
  final Color textColor;
  final Color? borderColor;
  final double borderWidth;
  final double fontSize;
  final double verticalPadding;
  final double radius;
  final double? width;
  final double? height;
  final Widget? icon;
  final EdgeInsetsGeometry? margin;

  const EdunestButton({
    super.key,
    this.title = '',
    this.onPressed,
    this.disabled = false,
    this.isLoading = false,
    this.backgroundColor,
    this.gradientEndColor,
    this.gradientColors,
    this.useGradient = true,
    this.textColor = AppColors.colorWhite,
    this.borderColor,
    this.borderWidth = 1,
    this.fontSize = AppValues.fontSizeDefault,
    this.verticalPadding = AppValues.paddingMedium,
    this.radius = AppValues.radius20,
    this.width,
    this.height,
    this.icon,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutlined = borderColor != null;
    final double scaledFontSize = context.rf(fontSize);
    final double scaledVerticalPadding = context.rh(verticalPadding);
    final double scaledRadius = context.rw(radius);
    final double scaledHeight = context.rh(height ?? AppValues.buttonHeight);

    final List<Color> defaultGradient = [
      disabled ? AppColors.colorGrey : (backgroundColor ?? AppColors.primary),
      disabled
          ? AppColors.colorGrey
          : (gradientEndColor ?? AppColors.secondary),
    ];

    Widget buttonContent = Container(
      width: width ?? double.infinity,
      height: scaledHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scaledRadius),
        gradient: (!isOutlined && useGradient)
            ? LinearGradient(
                colors: gradientColors ?? defaultGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isOutlined
            ? AppColors.transparent
            : (!useGradient
                  ? (disabled
                        ? AppColors.colorGrey
                        : backgroundColor ?? AppColors.primary)
                  : null),
        boxShadow: (!isOutlined && !disabled)
            ? [
                BoxShadow(
                  color: (backgroundColor ?? AppColors.primary).withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (disabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          shadowColor: AppColors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: scaledVerticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scaledRadius),
            side: isOutlined
                ? BorderSide(color: borderColor!, width: borderWidth)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: scaledFontSize,
                width: scaledFontSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: context.rw(AppValues.paddingSmall)),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: scaledFontSize,
                        color: disabled ? AppColors.colorWhite : textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
    return buttonContent;
  }
}
