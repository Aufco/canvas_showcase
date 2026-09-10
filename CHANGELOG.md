# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-11-07

### Added
- Initial release of canvas_showcase package
- Automatic scale detection for FittedBox transformations
- Scale-aware highlight rendering
- ShowCaseWidget controller for managing tours
- Showcase wrapper widget for marking targets
- ScaleCalculator utility for transform analysis
- Full example app with DesignCanvas4x3
- Comprehensive README documentation
- Support for sequential showcase tours
- Customizable tooltips and overlays
- Orientation change support

### Features
- Correctly sizes highlights when content is scaled via FittedBox
- Drop-in replacement for basic showcaseview use cases
- Automatic detection of transformation scale factors
- Works with nested transformations
- Smooth animations for overlay appearance
- Flexible tooltip positioning (above/below target)

### Technical
- Uses RenderBox transform matrix for scale detection
- Applies scale factor to sizes while preserving position calculations
- Renders overlay using OverlayEntry and CustomPainter
- Properly disposes resources and cleans up state
