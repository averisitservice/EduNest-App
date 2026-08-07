import 'package:flutter/material.dart';

/// Width breakpoints (logical pixels) used to classify device sizes.
/// Kept as documented constants so the thresholds aren't magic numbers
/// scattered across the codebase.
class Breakpoints {
  Breakpoints._();

  /// Below this width: small phones (e.g. iPhone SE).
  static const double smallPhone = 360;

  /// Below this width (and >= [smallPhone]): medium phones.
  static const double mediumPhone = 400;

  /// Below this width (and >= [mediumPhone]): large phones.
  static const double largePhone = 600;

  /// At or above this width: unfolded foldables / small tablets.
  static const double foldableOrTablet = 600;

  /// Reference design width (logical px) that [ResponsiveContext.rw] and
  /// [ResponsiveContext.rf] scale against.
  static const double referenceWidth = 375;

  /// Reference design height (logical px) that [ResponsiveContext.rh]
  /// scales against.
  static const double referenceHeight = 812;

  /// Minimum/maximum allowed scale factor for width/height scaling, so
  /// values never shrink or grow to an absurd degree on extreme screens.
  static const double minScale = 0.85;
  static const double maxScale = 1.35;

  /// Minimum/maximum allowed multiplier applied on top of width-scaling
  /// for the OS text-scale factor, when computing responsive font sizes.
  static const double minTextScale = 0.9;
  static const double maxTextScale = 1.3;

  /// Absolute floor/ceiling for any responsive font size, regardless of
  /// scaling, to preserve readability.
  static const double minFontSize = 10;
  static const double maxFontSize = 40;
}

/// A [BuildContext] extension exposing pure, dependency-free helpers for
/// building responsive layouts using only [MediaQuery] data.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  Orientation get _orientation => MediaQuery.orientationOf(this);

  bool get isPortrait => _orientation == Orientation.portrait;

  bool get isLandscape => _orientation == Orientation.landscape;

  bool get isSmallPhone => screenWidth < Breakpoints.smallPhone;

  bool get isMediumPhone =>
      screenWidth >= Breakpoints.smallPhone && screenWidth < Breakpoints.mediumPhone;

  bool get isLargePhone =>
      screenWidth >= Breakpoints.mediumPhone && screenWidth < Breakpoints.largePhone;

  bool get isFoldableOrTablet => screenWidth >= Breakpoints.foldableOrTablet;

  /// Scales [value] proportionally against a 375-logical-px reference
  /// width, clamped to a sane scale-factor range.
  double rw(double value) {
    final scale = (screenWidth / Breakpoints.referenceWidth)
        .clamp(Breakpoints.minScale, Breakpoints.maxScale);
    return value * scale;
  }

  /// Scales [value] proportionally against an 812-logical-px reference
  /// height, clamped to a sane scale-factor range.
  double rh(double value) {
    final scale = (screenHeight / Breakpoints.referenceHeight)
        .clamp(Breakpoints.minScale, Breakpoints.maxScale);
    return value * scale;
  }

  /// Responsive font size: scales [value] by screen width (like [rw]) and
  /// additionally by the OS text-scale factor (clamped), then clamps the
  /// final result to a readable min/max.
  double rf(double value) {
    final widthScale = (screenWidth / Breakpoints.referenceWidth)
        .clamp(Breakpoints.minScale, Breakpoints.maxScale);
    final textScale = MediaQuery.textScalerOf(this)
        .scale(1.0)
        .clamp(Breakpoints.minTextScale, Breakpoints.maxTextScale);
    final result = value * widthScale * textScale;
    return result.clamp(Breakpoints.minFontSize, Breakpoints.maxFontSize);
  }
}
