import 'package:flutter/material.dart';
import 'package:canvas_showcase/canvas_showcase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas Showcase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final GlobalKey _button1Key = GlobalKey();
  final GlobalKey _button2Key = GlobalKey();
  final GlobalKey _button3Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Auto-start the tour after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTour();
    });
  }

  void _startTour() {
    ShowCaseWidget.of(context).startShowCase([
      _button1Key,
      _button2Key,
      _button3Key,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: ShowCaseWidget(
        onFinish: () {
          debugPrint('Tour completed!');
        },
        onStart: (index, key) {
          debugPrint('Started showcase $index');
        },
        onComplete: (index, key) {
          debugPrint('Completed showcase $index');
        },
        builder: (context) {
          return DesignCanvas4x3(
            backgroundColor: Colors.green,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Canvas Showcase Demo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Showcase(
                    key: _button1Key,
                    title: 'Button 1',
                    description:
                        'This is the first button. It\'s 120×120 on the canvas, but the highlight scales correctly to your screen!',
                    targetPadding: EdgeInsets.zero,
                    targetBorderRadius: BorderRadius.circular(60),
                    child: _buildButton('Button 1', Colors.blue),
                  ),
                  const SizedBox(height: 30),
                  Showcase(
                    key: _button2Key,
                    title: 'Button 2',
                    description:
                        'Notice how the highlight perfectly matches the button size, regardless of screen scaling.',
                    targetPadding: const EdgeInsets.all(8),
                    targetBorderRadius: BorderRadius.circular(16),
                    child: _buildButton('Button 2', Colors.red),
                  ),
                  const SizedBox(height: 30),
                  Showcase(
                    key: _button3Key,
                    title: 'Button 3',
                    description:
                        'The canvas_showcase package automatically detects and applies the FittedBox scale factor!',
                    targetPadding: const EdgeInsets.all(4),
                    targetBorderRadius: BorderRadius.circular(12),
                    child: _buildButton('Button 3', Colors.orange),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _startTour,
                    child: const Text('Restart Tour'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(String label, Color color) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// DesignCanvas4x3 - A fixed-ratio canvas system for Flutter
///
/// This widget provides a consistent 1024×768 (landscape) or 768×1024 (portrait)
/// canvas that scales uniformly to fit any device screen using FittedBox.
class DesignCanvas4x3 extends StatelessWidget {
  static const double landscapeWidth = 1024.0;
  static const double landscapeHeight = 768.0;
  static const double portraitWidth = 768.0;
  static const double portraitHeight = 1024.0;

  final Widget child;
  final Color backgroundColor;

  const DesignCanvas4x3({
    super.key,
    required this.child,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;
        final double designWidth =
            isLandscape ? landscapeWidth : portraitWidth;
        final double designHeight =
            isLandscape ? landscapeHeight : portraitHeight;

        return Container(
          color: backgroundColor,
          child: Center(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: SizedBox(
                  width: designWidth,
                  height: designHeight,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
