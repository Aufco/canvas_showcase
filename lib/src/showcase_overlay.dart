import 'package:flutter/material.dart';
import 'scale_calculator.dart';
import 'dart:math' as math;

/// Overlay that renders the showcase highlight and tooltip
class ShowcaseOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final String? title;
  final String? description;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final EdgeInsets targetPadding;
  final BorderRadius? targetBorderRadius;
  final Color overlayColor;
  final double overlayOpacity;
  final VoidCallback? onTargetClick;
  final VoidCallback onDismiss;
  final Color tooltipBackgroundColor;
  final EdgeInsets tooltipPadding;
  final BorderRadius? tooltipBorderRadius;

  const ShowcaseOverlay({
    super.key,
    required this.targetKey,
    required this.onDismiss,
    this.title,
    this.description,
    this.titleTextStyle,
    this.descTextStyle,
    this.targetPadding = EdgeInsets.zero,
    this.targetBorderRadius,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.onTargetClick,
    this.tooltipBackgroundColor = Colors.white,
    this.tooltipPadding = const EdgeInsets.all(16),
    this.tooltipBorderRadius,
  });

  @override
  State<ShowcaseOverlay> createState() => _ShowcaseOverlayState();
}

class _ShowcaseOverlayState extends State<ShowcaseOverlay>
    with SingleTickerProviderStateMixin {
  Rect? _targetRect;
  double _scaleFactor = 1.0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTargetRect();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateTargetRect() {
    final targetContext = widget.targetKey.currentContext;
    if (targetContext == null) return;

    final renderBox = targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    // Get the transformation matrix
    final transform = renderBox.getTransformTo(null);
    _scaleFactor = transform.getMaxScaleOnAxis();

    // Get all four corners in local coordinates
    final localSize = renderBox.size;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final bottomRight = renderBox.localToGlobal(Offset(localSize.width, localSize.height));

    // Calculate screen size from transformed corners
    final screenWidth = (bottomRight.dx - topLeft.dx).abs();
    final screenHeight = (bottomRight.dy - topLeft.dy).abs();

    // Apply scaled padding
    final scaledPadding =
        ScaleCalculator.scaleEdgeInsets(widget.targetPadding, _scaleFactor);

    // DEBUG LOGGING
    debugPrint('🔍 SHOWCASE DEBUG:');
    debugPrint('  Local size: ${localSize.width} x ${localSize.height}');
    debugPrint('  Top-left: (${topLeft.dx}, ${topLeft.dy})');
    debugPrint('  Bottom-right: (${bottomRight.dx}, ${bottomRight.dy})');
    debugPrint('  Screen size (from corners): $screenWidth x $screenHeight');
    debugPrint('  Scale factor: $_scaleFactor');
    debugPrint('  Padding: ${widget.targetPadding}');

    setState(() {
      _targetRect = Rect.fromLTWH(
        topLeft.dx - scaledPadding.left,
        topLeft.dy - scaledPadding.top,
        screenWidth + scaledPadding.left + scaledPadding.right,
        screenHeight + scaledPadding.top + scaledPadding.bottom,
      );
      debugPrint('  Final rect: $_targetRect');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          // Overlay with cutout
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: CustomPaint(
                painter: _ShowcasePainter(
                  targetRect: _targetRect!,
                  overlayColor:
                      widget.overlayColor.withOpacity(widget.overlayOpacity),
                  borderRadius: widget.targetBorderRadius != null
                      ? ScaleCalculator.scaleBorderRadius(
                          widget.targetBorderRadius!,
                          _scaleFactor,
                        )
                      : BorderRadius.circular(8 * _scaleFactor),
                ),
              ),
            ),
          ),

          // Target click area - clicking anywhere advances the tour
          Positioned(
            left: _targetRect!.left,
            top: _targetRect!.top,
            width: _targetRect!.width,
            height: _targetRect!.height,
            child: GestureDetector(
              onTap: () {
                // Call custom handler if provided
                if (widget.onTargetClick != null) {
                  widget.onTargetClick!();
                }
                // Always advance to next tip
                widget.onDismiss();
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // Tooltip
          _buildTooltip(screenSize),
        ],
      ),
    );
  }

  Widget _buildTooltip(Size screenSize) {
    final tooltipContent = Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: widget.tooltipPadding,
      decoration: BoxDecoration(
        color: widget.tooltipBackgroundColor,
        borderRadius: widget.tooltipBorderRadius ?? BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
          decorationColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(
                widget.title!,
                style: widget.titleTextStyle ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                    ),
              ),
              const SizedBox(height: 8),
            ],
            if (widget.description != null)
              Text(
                widget.description!,
                style: widget.descTextStyle ??
                    const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      decoration: TextDecoration.none,
                      decorationColor: Colors.transparent,
                    ),
              ),
          ],
        ),
      ),
    );

    // Position tooltip above or below target
    final targetCenter = _targetRect!.center.dy;
    final spaceAbove = _targetRect!.top;
    final spaceBelow = screenSize.height - _targetRect!.bottom;

    final showAbove = spaceAbove > spaceBelow;
    final gap = 10.0 * _scaleFactor;

    if (showAbove) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: screenSize.height - _targetRect!.top + gap,
        child: tooltipContent,
      );
    } else {
      return Positioned(
        left: 0,
        right: 0,
        top: _targetRect!.bottom + gap,
        child: tooltipContent,
      );
    }
  }
}

/// Custom painter for the showcase overlay with cutout
class _ShowcasePainter extends CustomPainter {
  final Rect targetRect;
  final Color overlayColor;
  final BorderRadius borderRadius;

  _ShowcasePainter({
    required this.targetRect,
    required this.overlayColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final innerPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          targetRect,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ),
      );

    final combinedPath = Path.combine(
      PathOperation.difference,
      outerPath,
      innerPath,
    );

    canvas.drawPath(combinedPath, paint);

    // Draw a subtle border around the target
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        targetRect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShowcasePainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
