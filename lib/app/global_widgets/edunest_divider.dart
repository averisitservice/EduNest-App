import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/core/utils/responsive.dart';

class EdunestDivider extends StatelessWidget {
  final Color dividerColor;
  final Color? color;
  final double thickness;
  final double height;
  final String? text;
  final bool isDashed;
  final double dashWidth;
  final double dashSpace;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const EdunestDivider({
    super.key,
    this.dividerColor = AppColors.borderGrey,
    this.color,
    this.thickness = 0.8,
    this.height = 10.0,
    this.text,
    this.isDashed = false,
    this.dashWidth = AppValues.margin5,
    this.dashSpace = AppValues.margin4,
    this.width,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? dividerColor;
    final double effectiveThickness = thickness;

    final Widget lineWidget = isDashed && dashSpace > 0
        ? CustomPaint(
            size: Size(width ?? double.infinity, effectiveThickness),
            painter: _DashedLinePainter(
              color: effectiveColor,
              thickness: effectiveThickness,
              dashWidth: dashWidth,
              dashSpace: dashSpace,
            ),
          )
        : Divider(
            color: effectiveColor,
            thickness: effectiveThickness,
            height: 1,
            endIndent: 0.0,
            indent: 0.0,
          );

    Widget dividerChild;
    final String? textVal = text;

    if (textVal != null && textVal.isNotEmpty) {
      dividerChild = Row(
        children: [
          Expanded(child: lineWidget),
          Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: context.rw(AppValues.paddingMedium)),
            child: Text(
              textVal,
              style: TextStyle(
                color: effectiveColor,
                fontSize: context.rf(AppValues.fontSizeSmall),
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(child: lineWidget),
        ],
      );
    } else {
      dividerChild = lineWidget;
    }

    Widget result = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (height > 0) SizedBox(height: context.rh(height)),
        dividerChild,
        if (height > 0) SizedBox(height: context.rh(height)),
      ],
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }

    return result;
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
