import 'package:flutter/material.dart';
import 'showcase_overlay.dart';
import 'canvas_showcase.dart';

/// Main controller widget for managing showcase tours
///
/// Wrap your app or screen with this widget to enable showcases.
/// Use ShowCaseWidget.of(context) to access the controller and start tours.
class ShowCaseWidget extends StatefulWidget {
  /// Builder function that returns the widget tree containing Showcase widgets
  final WidgetBuilder builder;

  /// Callback triggered when all showcases are completed
  final VoidCallback? onFinish;

  /// Callback triggered when a showcase is started
  final void Function(int? index, GlobalKey key)? onStart;

  /// Callback triggered when a showcase is completed
  final void Function(int? index, GlobalKey key)? onComplete;

  const ShowCaseWidget({
    super.key,
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
  });

  /// Access the ShowCaseWidget controller from the widget tree
  static ShowCaseWidgetState of(BuildContext context) {
    final state = context.findAncestorStateOfType<ShowCaseWidgetState>();
    if (state == null) {
      throw Exception(
        'ShowCaseWidget.of() called with a context that does not contain a ShowCaseWidget.\n'
        'Make sure your widget tree has a ShowCaseWidget ancestor.',
      );
    }
    return state;
  }

  @override
  State<ShowCaseWidget> createState() => ShowCaseWidgetState();
}

class ShowCaseWidgetState extends State<ShowCaseWidget> {
  List<GlobalKey>? _showcaseKeys;
  int? _currentIndex;
  OverlayEntry? _overlayEntry;

  /// Start a showcase tour with the given keys
  void startShowCase(List<GlobalKey> keys) {
    if (keys.isEmpty) return;

    setState(() {
      _showcaseKeys = keys;
      _currentIndex = 0;
    });

    _showCurrentShowcase();
  }

  /// Move to the next showcase
  void next() {
    if (_currentIndex == null || _showcaseKeys == null) return;

    final currentKey = _showcaseKeys![_currentIndex!];
    widget.onComplete?.call(_currentIndex, currentKey);

    final nextIndex = _currentIndex! + 1;

    if (nextIndex >= _showcaseKeys!.length) {
      // Tour complete
      dismiss();
      widget.onFinish?.call();
    } else {
      setState(() {
        _currentIndex = nextIndex;
      });
      _removeOverlay();
      _showCurrentShowcase();
    }
  }

  /// Move to the previous showcase
  void previous() {
    if (_currentIndex == null ||
        _showcaseKeys == null ||
        _currentIndex! <= 0) {
      return;
    }

    setState(() {
      _currentIndex = _currentIndex! - 1;
    });
    _removeOverlay();
    _showCurrentShowcase();
  }

  /// Dismiss the current showcase tour
  void dismiss() {
    _removeOverlay();
    setState(() {
      _showcaseKeys = null;
      _currentIndex = null;
    });
  }

  void _showCurrentShowcase() {
    if (_currentIndex == null || _showcaseKeys == null) return;

    final key = _showcaseKeys![_currentIndex!];

    widget.onStart?.call(_currentIndex, key);

    // Wait for next frame to ensure widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showOverlay(key);
    });
  }

  void _showOverlay(GlobalKey targetKey) {
    final targetContext = targetKey.currentContext;
    if (targetContext == null) {
      // Widget not found, skip to next
      debugPrint('Warning: Showcase target widget not found, skipping');
      next();
      return;
    }

    // Find the Showcase widget to get its configuration
    final showcaseWidget = _findShowcaseWidget(targetContext);
    if (showcaseWidget == null) {
      debugPrint('Warning: Could not find Showcase widget configuration');
      next();
      return;
    }

    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => ShowcaseOverlay(
        targetKey: targetKey,
        title: showcaseWidget.title,
        description: showcaseWidget.description,
        titleTextStyle: showcaseWidget.titleTextStyle,
        descTextStyle: showcaseWidget.descTextStyle,
        targetPadding: showcaseWidget.targetPadding,
        targetBorderRadius: showcaseWidget.targetBorderRadius,
        overlayColor: showcaseWidget.overlayColor,
        overlayOpacity: showcaseWidget.overlayOpacity,
        onTargetClick: () {
          if (showcaseWidget.onTargetClick != null) {
            showcaseWidget.onTargetClick!();
          }
          if (showcaseWidget.disposeOnTap == true) {
            dismiss();
          }
        },
        onDismiss: next,
        tooltipBackgroundColor: showcaseWidget.tooltipBackgroundColor,
        tooltipPadding: showcaseWidget.tooltipPadding,
        tooltipBorderRadius: showcaseWidget.tooltipBorderRadius,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Showcase? _findShowcaseWidget(BuildContext context) {
    // First check if the context itself is a Showcase widget
    final element = context as Element;
    if (element.widget is Showcase) {
      return element.widget as Showcase;
    }

    // If not, try to find the Showcase widget in ancestor elements
    Showcase? result;
    context.visitAncestorElements((element) {
      if (element.widget is Showcase) {
        result = element.widget as Showcase;
        return false; // Stop visiting
      }
      return true; // Continue visiting
    });
    return result;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: widget.builder);
  }
}
