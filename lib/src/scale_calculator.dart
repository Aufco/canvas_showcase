import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Calculates the scale factor applied by FittedBox or other transformations
class ScaleCalculator {
  /// Calculates the scale factor for a given context
  ///
  /// This method detects if the widget is inside a FittedBox or other
  /// transformation and returns the scale factor being applied.
  static double calculateScale(BuildContext context) {
    try {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        return 1.0;
      }

      // Get the transformation matrix from this widget to the root
      final transform = renderBox.getTransformTo(null);

      // Extract the scale from the transformation matrix
      // The transformation matrix contains scale, rotation, and translation
      // For uniform scaling (which FittedBox does), we can extract the scale
      // from the matrix by checking how a unit vector transforms
      final scaleX = transform.getMaxScaleOnAxis();

      return scaleX;
    } catch (e) {
      // If we can't calculate scale, return 1.0 (no scaling)
      debugPrint('Error calculating scale: $e');
      return 1.0;
    }
  }

  /// Calculates the inverse scale (1/scale) for converting screen to canvas coords
  static double calculateInverseScale(BuildContext context) {
    final scale = calculateScale(context);
    return scale > 0 ? 1.0 / scale : 1.0;
  }

  /// Applies scale to a size
  static Size scaleSize(Size size, double scale) {
    return Size(size.width * scale, size.height * scale);
  }

  /// Applies scale to an offset
  static Offset scaleOffset(Offset offset, double scale) {
    return Offset(offset.dx * scale, offset.dy * scale);
  }

  /// Applies scale to EdgeInsets
  static EdgeInsets scaleEdgeInsets(EdgeInsets insets, double scale) {
    return EdgeInsets.only(
      left: insets.left * scale,
      top: insets.top * scale,
      right: insets.right * scale,
      bottom: insets.bottom * scale,
    );
  }

  /// Applies scale to a Radius
  static Radius scaleRadius(Radius radius, double scale) {
    return Radius.circular(radius.x * scale);
  }

  /// Applies scale to BorderRadius
  static BorderRadius scaleBorderRadius(BorderRadius radius, double scale) {
    return BorderRadius.only(
      topLeft: scaleRadius(radius.topLeft, scale),
      topRight: scaleRadius(radius.topRight, scale),
      bottomLeft: scaleRadius(radius.bottomLeft, scale),
      bottomRight: scaleRadius(radius.bottomRight, scale),
    );
  }
}
