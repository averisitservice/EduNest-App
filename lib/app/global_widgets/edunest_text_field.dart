import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';

class EdunestTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final void Function(String)? onChanged;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final int? maxLength;
  final String? counterText;
  final List<TextInputFormatter>? inputFormatters;

  const EdunestTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.width,
    this.height,
    this.borderRadius = AppValues.radiusDefault,
    this.margin,
    this.padding,
    this.maxLength,
    this.counterText,
    this.inputFormatters,
  });

  OutlineInputBorder _buildBorder(Color color, [double borderWidth = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: color, width: borderWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: AppValues.fontSizeBody,
        fontWeight: FontWeight.w500,
        color: AppColors.darkGrey,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: AppColors.colorBlack,
          fontSize: AppValues.fontSizeBody,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.borderGrey,
          fontSize: AppValues.fontSizeBody,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            padding ?? const EdgeInsets.all(AppValues.paddingDefault),
        filled: true,
        fillColor: AppColors.inputFill,
        enabledBorder: _buildBorder(AppColors.borderGrey),
        focusedBorder: _buildBorder(AppColors.borderGrey, 1.2),
        errorBorder: _buildBorder(AppColors.errorColor),
        focusedErrorBorder: _buildBorder(AppColors.errorColor, 1.5),
        counterText: counterText,
      ),
    );
    return child;
  }
}

