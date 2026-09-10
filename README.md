# Canvas Showcase

A Flutter package for creating showcase/tutorial overlays that correctly handles canvas scaling via `FittedBox`. Inspired by the popular `showcaseview` package but specifically designed to work correctly when your UI is scaled using Flutter's `FittedBox` widget.

## The Problem

The standard `showcaseview` package uses Flutter's root `Overlay` system, which renders outside the canvas scaling context. This causes highlight boxes to be incorrectly sized:

- On smaller screens (e.g., iPhone): Highlights appear oversized
- On larger screens (e.g., iPad): Highlights may appear correct due to minimal scaling

The root cause is that while position calculations use `localToGlobal()` (which correctly transforms coordinates), size calculations use `RenderBox.size` (which returns canvas size, not scaled screen size).

## The Solution

`canvas_showcase` solves this by:

1. **Detecting the scale factor** applied by `FittedBox` using transform matrix analysis
2. **Applying the scale to highlight sizes** while keeping position calculations unchanged
3. **Rendering within the widget tree** with proper scaling applied

## Features

- ✅ Correctly sizes highlights on any screen size
- ✅ Works with `FittedBox` and other transformations
- ✅ Handles orientation changes (landscape ↔ portrait)
- ✅ Simple, drop-in API similar to showcaseview
- ✅ Automatic scale detection
- ✅ Customizable tooltips and overlays
- ✅ Sequential showcase tours
- ✅ Lightweight and performant

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  canvas_showcase:
    git:
      url: https://github.com/Aufco/canvas_showcase.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:canvas_showcase/canvas_showcase.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        onFinish: () => print('Tour complete!'),
        builder: (context) {
          return Center(
            child: Showcase(
              key: _buttonKey,
              title: 'My Button',
              description: 'Tap here to do something awesome!',
              targetPadding: EdgeInsets.all(8),
              targetBorderRadius: BorderRadius.circular(12),
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Click Me'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ShowCaseWidget.of(context).startShowCase([_buttonKey]);
        },
        child: Icon(Icons.help),
      ),
    );
  }
}
```

### With DesignCanvas4x3 (Scaled Canvas)

This is the main use case - when you have a fixed-size canvas that scales to fit the screen:

```dart
import 'package:flutter/material.dart';
import 'package:canvas_showcase/canvas_showcase.dart';

// Your fixed-ratio canvas widget
class DesignCanvas4x3 extends StatelessWidget {
  static const double landscapeWidth = 1024.0;
  static const double landscapeHeight = 768.0;

  final Widget child;
  final Color backgroundColor;

  const DesignCanvas4x3({
    required this.child,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: landscapeWidth,
            height: landscapeHeight,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Your app screen with showcase
class MyCanvasScreen extends StatefulWidget {
  @override
  State<MyCanvasScreen> createState() => _MyCanvasScreenState();
}

class _MyCanvasScreenState extends State<MyCanvasScreen> {
  final GlobalKey _key1 = GlobalKey();
  final GlobalKey _key2 = GlobalKey();

  void _startTour() {
    ShowCaseWidget.of(context).startShowCase([_key1, _key2]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowCaseWidget(
        onFinish: () => print('Tour finished!'),
        onStart: (index, key) => print('Started showcase $index'),
        onComplete: (index, key) => print('Completed showcase $index'),
        builder: (context) {
          return DesignCanvas4x3(
            child: Stack(
              children: [
                // Your canvas content here
                Positioned(
                  left: 100,
                  top: 100,
                  child: Showcase(
                    key: _key1,
                    title: 'Feature 1',
                    description: 'This highlight scales correctly!',
                    targetBorderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Positioned(
                  right: 100,
                  bottom: 100,
                  child: Showcase(
                    key: _key2,
                    title: 'Feature 2',
                    description: 'So does this one!',
                    targetBorderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startTour,
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
```

## API Reference

### ShowCaseWidget

The main controller widget that manages showcase tours.

**Properties:**

- `builder` (required) - Builder function returning the widget tree with `Showcase` widgets
- `onFinish` - Callback when all showcases complete
- `onStart` - Callback when each showcase starts: `void Function(int? index, GlobalKey key)`
- `onComplete` - Callback when each showcase completes: `void Function(int? index, GlobalKey key)`

**Methods:**

Access via `ShowCaseWidget.of(context)`:

- `startShowCase(List<GlobalKey> keys)` - Start a tour with the given showcase keys
- `next()` - Skip to the next showcase
- `previous()` - Go back to the previous showcase
- `dismiss()` - Dismiss the current tour

### Showcase

Widget wrapper that marks a child widget to be showcased.

**Properties:**

- `key` (required) - GlobalKey to identify this showcase
- `child` (required) - The widget to highlight
- `title` - Title text for the tooltip
- `description` - Description text for the tooltip
- `titleTextStyle` - Custom text style for title
- `descTextStyle` - Custom text style for description
- `targetPadding` - Padding around the highlight (default: `EdgeInsets.zero`)
- `targetBorderRadius` - Border radius for the highlight cutout
- `overlayColor` - Color of the overlay (default: `Colors.black45`)
- `overlayOpacity` - Opacity of overlay 0.0-1.0 (default: `0.75`)
- `tooltipBackgroundColor` - Background color of tooltip (default: `Colors.white`)
- `tooltipPadding` - Padding inside tooltip (default: `EdgeInsets.all(16)`)
- `tooltipBorderRadius` - Border radius for tooltip
- `onTargetClick` - Callback when target is tapped
- `disposeOnTap` - Whether to dismiss tour when target is tapped

## How It Works

### Scale Detection

The `ScaleCalculator` class detects the transformation applied by `FittedBox`:

```dart
double scale = ScaleCalculator.calculateScale(context);
// Returns: 2.67 on iPad Pro, 1.54 on iPhone, etc.
```

This uses `RenderBox.getTransformTo(null)` to get the full transformation matrix from the widget to the screen root, then extracts the scale factor.

### Size Correction

When rendering highlights:

1. **Position**: Use `localToGlobal(Offset.zero)` ✅ Already correct
2. **Size**: Multiply `RenderBox.size` by scale factor ✅ Now correct!

```dart
final renderBox = targetContext.findRenderObject() as RenderBox;
final position = renderBox.localToGlobal(Offset.zero);  // Correct
final canvasSize = renderBox.size;                      // Canvas coordinates
final screenSize = canvasSize * scaleFactor;            // Screen coordinates
```

### Overlay Rendering

The overlay is rendered using `OverlayEntry` with a `CustomPainter` that:

1. Draws a full-screen overlay
2. Cuts out a hole for the target (with correct screen-size dimensions)
3. Positions the tooltip above/below the target

## Comparison with showcaseview

| Feature | showcaseview | canvas_showcase |
|---------|-------------|-----------------|
| Basic showcases | ✅ | ✅ |
| Sequential tours | ✅ | ✅ |
| Custom tooltips | ✅ | ✅ |
| FittedBox support | ❌ Breaks | ✅ Works perfectly |
| Scale detection | ❌ No | ✅ Automatic |
| Canvas apps | ❌ Incorrect sizing | ✅ Correct sizing |
| API complexity | Complex | Simplified |

## Migration from showcaseview

If you're currently using `showcaseview`, migration is straightforward:

1. Replace `package:showcaseview` with `package:canvas_showcase`
2. Update imports: `import 'package:canvas_showcase/canvas_showcase.dart'`
3. The API is compatible for basic use cases

**Note:** `canvas_showcase` uses a simplified API. Advanced showcaseview features (custom widgets, animations, etc.) are not yet supported but can be added if needed.

## Example App

The `example/` directory contains a full working demo with `DesignCanvas4x3`. Run it with:

```bash
cd example
flutter run
```

This demonstrates:
- Multiple showcases in sequence
- Correct sizing on all devices
- Integration with scaled canvas
- Custom styling and padding

## Technical Details

### Supported Transformations

- ✅ FittedBox with BoxFit.contain
- ✅ FittedBox with BoxFit.cover
- ✅ Transform widgets
- ✅ Nested transformations

### Orientation Support

The package automatically recalculates scale when orientation changes:

- Landscape: 1024×768 canvas → scaled to screen
- Portrait: 768×1024 canvas → scaled to screen
- Highlights update correctly on rotation

### Performance

- Lightweight: No heavy dependencies
- Efficient: Scale calculated once per showcase
- Smooth: Animations use `AnimationController`
- Memory safe: Properly disposes resources

## Limitations

- Tooltip customization is more limited than showcaseview
- No built-in support for auto-play tours (can be added)
- Assumes standard Flutter rendering (no custom render objects)

## Contributing

Contributions are welcome! Please open issues or pull requests on GitHub.

## License

MIT License - feel free to use in your projects

## Credits

Inspired by [showcaseview](https://pub.dev/packages/showcaseview) by Simform Solutions.

Modified to solve canvas scaling issues for apps using fixed-ratio canvas systems.

## Support

For issues, questions, or feature requests, please open a GitHub issue.
