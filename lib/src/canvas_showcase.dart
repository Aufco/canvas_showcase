import 'package:flutter/material.dart';

/// A widget that marks a child widget to be showcased
///
/// Wrap any widget you want to highlight with this Showcase widget.
/// The showcase will be triggered when you call startShowCase on the
/// ShowCaseWidget controller.
class Showcase extends StatelessWidget {
  /// Global key to identify this showcase
  final GlobalKey key;

  /// The widget to be highlighted
  final Widget child;

  /// Title text for the tooltip
  final String? title;

  /// Description text for the tooltip
  final String? description;

  /// Text style for the title
  final TextStyle? titleTextStyle;

  /// Text style for the description
  final TextStyle? descTextStyle;

  /// Padding around the target widget
  final EdgeInsets targetPadding;

  /// Border radius for the highlight cutout
  final BorderRadius? targetBorderRadius;

  /// Overlay color
  final Color overlayColor;

  /// Overlay opacity (0.0 to 1.0)
  final double overlayOpacity;

  /// Callback when target is tapped
  final VoidCallback? onTargetClick;

  /// Whether to dismiss the showcase when tapped
  final bool? disposeOnTap;

  /// Background color for the tooltip
  final Color tooltipBackgroundColor;

  /// Padding inside the tooltip
  final EdgeInsets tooltipPadding;

  /// Border radius for the tooltip
  final BorderRadius? tooltipBorderRadius;

  const Showcase({
    required GlobalKey key,
    required this.child,
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
    this.tooltipBackgroundColor = Colors.white,
    this.tooltipPadding = const EdgeInsets.all(16),
    this.tooltipBorderRadius,
  })  : key = key,
        assert(
          title != null || description != null,
          'Either title or description must be provided',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simply return the child
    // The ShowCaseWidget will handle rendering the overlay
    return child;
  }
}
