import 'package:flutter/material.dart';

/// Enum for tooltip position
enum TooltipPosition {
  top,
  bottom,
}

/// Configuration for a showcase item
class ShowcaseConfig {
  final GlobalKey key;
  final String? title;
  final String? description;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final EdgeInsets targetPadding;
  final BorderRadius? targetBorderRadius;
  final Color overlayColor;
  final double overlayOpacity;
  final VoidCallback? onTargetClick;
  final bool? disposeOnTap;
  final TooltipPosition? tooltipPosition;
  final Color tooltipBackgroundColor;
  final EdgeInsets tooltipPadding;
  final BorderRadius? tooltipBorderRadius;

  const ShowcaseConfig({
    required this.key,
    this.title,
    this.description,
    this.titleTextStyle,
    this.descTextStyle,
    this.targetPadding = EdgeInsets.zero,
    this.targetBorderRadius,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.onTargetClick,
    this.disposeOnTap,
    this.tooltipPosition,
    this.tooltipBackgroundColor = Colors.white,
    this.tooltipPadding = const EdgeInsets.all(16),
    this.tooltipBorderRadius,
  });
}
