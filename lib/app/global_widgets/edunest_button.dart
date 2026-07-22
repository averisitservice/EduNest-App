import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';

class EdunestButton extends StatelessWidget {
  final String title;
  final String? text;
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
    this.text,
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
    this.radius = AppValues.radius_20,
    this.width,
    this.height,
    this.icon,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutlined = borderColor != null;
    final String buttonTitle = text ?? title;

    final List<Color> defaultGradient = [
      disabled ? AppColors.colorGrey : (backgroundColor ?? AppColors.primary),
      disabled
          ? AppColors.colorGrey
          : (gradientEndColor ?? AppColors.secondary),
    ];

    Widget buttonContent = Container(
      width: width ?? double.infinity,
      height: height ?? AppValues.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: (!isOutlined && useGradient)
            ? LinearGradient(
                colors: gradientColors ?? defaultGradient,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isOutlined
            ? Colors.transparent
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
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: isOutlined
                ? BorderSide(color: borderColor!, width: borderWidth)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: fontSize,
                width: fontSize,
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
                    const SizedBox(width: AppValues.paddingSmall),
                  ],
                  Text(
                    buttonTitle,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: disabled ? AppColors.colorWhite : textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
    return buttonContent;
  }
}
