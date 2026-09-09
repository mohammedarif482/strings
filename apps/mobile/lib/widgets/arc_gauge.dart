import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';

class ArcGauge extends StatelessWidget {
  final int score;
  const ArcGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(260, 140),
      painter: _ArcGaugePainter(score: score),
    );
  }
}

class _ArcGaugePainter extends CustomPainter {
  final int score;
  _ArcGaugePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width * 0.42;

    const startAngle = pi;
    const sweepAngle = pi;

    // 1. Background guide track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Active illuminated gradient arc
    final progressSweep = sweepAngle * (score / 100.0);
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: const [
        AivoColors.copper,
        AivoColors.orange,
        AivoColors.orangeLight,
        AivoColors.orangeBright,
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );

    // 3. Glowing knob at the end of progress
    final currentAngle = startAngle + progressSweep;
    final knobX = center.dx + radius * cos(currentAngle);
    final knobY = center.dy + radius * sin(currentAngle);
    final knobCenter = Offset(knobX, knobY);

    // Outer glow halo
    canvas.drawCircle(
      knobCenter,
      12,
      Paint()
        ..color = AivoColors.orangeLight.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // White knob outer
    canvas.drawCircle(
      knobCenter,
      8,
      Paint()..color = Colors.white,
    );

    // Orange knob center
    canvas.drawCircle(
      knobCenter,
      3.5,
      Paint()..color = AivoColors.orange,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcGaugePainter oldDelegate) => oldDelegate.score != score;
}
