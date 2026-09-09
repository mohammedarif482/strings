import 'dart:async';
import 'package:flutter/material.dart';

class DotMatrixVisualizer extends StatefulWidget {
  final bool isPlaying;
  const DotMatrixVisualizer({super.key, required this.isPlaying});

  @override
  State<DotMatrixVisualizer> createState() => _DotMatrixVisualizerState();
}

class _DotMatrixVisualizerState extends State<DotMatrixVisualizer> {
  int _playheadIndex = 12;
  Timer? _timer;

  static const int columns = 22;
  static const int rows = 5;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant DotMatrixVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _timer?.cancel();
      }
    }
  }

  void _startAnimation() {
    _timer?.cancel();
    if (!widget.isPlaying) return;
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (mounted) {
        setState(() {
          _playheadIndex = (_playheadIndex + 1) % columns;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Inverted triangle playhead marker
        SizedBox(
          height: 8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final colWidth = constraints.maxWidth / columns;
              final markerLeft = (_playheadIndex * colWidth) + (colWidth / 2) - 4;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    left: markerLeft,
                    top: 0,
                    child: CustomPaint(
                      size: const Size(8, 6),
                      painter: _TrianglePainter(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 3),

        // Dot matrix box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF141219),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(columns, (cIdx) {
              final isNearPlayhead = (_playheadIndex - cIdx).abs() <= 2;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(rows, (rIdx) {
                  final bool isLit = widget.isPlaying &&
                      (isNearPlayhead ? (rIdx >= 1) : ((cIdx + rIdx) % 3 == 0));
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    width: 4.5,
                    height: 4.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLit ? Colors.white : Colors.white.withOpacity(0.12),
                      boxShadow: isLit
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.6),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                  );
                }),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
