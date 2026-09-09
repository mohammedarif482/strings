import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';

class GlowingHumanSilhouette extends StatelessWidget {
  final String activeNode;
  final ValueChanged<String>? onNodeSelected;

  const GlowingHumanSilhouette({
    super.key,
    this.activeNode = 'mind',
    this.onNodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Ambient radial glowing aura
          Container(
            width: 220,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AivoColors.orangeLight.withOpacity(0.28),
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // 2. Custom Painted Ethereal Human Outline
          CustomPaint(
            size: const Size(200, 300),
            painter: _HumanSilhouettePainter(activeNode: activeNode),
          ),

          // 3. Interactive Callout: Mind (Head)
          Positioned(
            top: 24,
            right: 18,
            child: _CalloutPill(
              title: 'Mind',
              subtitle: 'Release Thoughts',
              isActive: activeNode == 'mind',
              onTap: () => onNodeSelected?.call('mind'),
            ),
          ),

          // 4. Interactive Callout: Heart (Chest)
          Positioned(
            top: 110,
            right: 16,
            child: _CalloutPill(
              title: 'Heart',
              subtitle: 'Find Peace',
              isActive: activeNode == 'heart',
              onTap: () => onNodeSelected?.call('heart'),
            ),
          ),

          // 5. Interactive Callout: Breath (Solar Plexus)
          Positioned(
            top: 170,
            left: 16,
            child: _CalloutPill(
              title: 'Breath',
              subtitle: 'Stay Present',
              isActive: activeNode == 'breath',
              onTap: () => onNodeSelected?.call('breath'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalloutPill extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const _CalloutPill({
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E1B24) : const Color(0xFF16141B).withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AivoColors.orangeLight : Colors.white.withOpacity(0.1),
            width: isActive ? 1.2 : 0.8,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AivoColors.orange.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: AivoColors.textSecondary,
                fontSize: 9,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HumanSilhouettePainter extends CustomPainter {
  final String activeNode;
  _HumanSilhouettePainter({required this.activeNode});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Body gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.85),
          const Color(0xFFFFDECB).withOpacity(0.65),
          AivoColors.orangeBright.withOpacity(0.45),
          Colors.white.withOpacity(0.2),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, 45), width: 40, height: 48),
      bodyPaint,
    );

    // Torso path
    final torso = Path()
      ..moveTo(cx - 10, 68)
      ..lineTo(cx + 10, 68)
      ..lineTo(cx + 20, 80)
      ..cubicTo(cx + 45, 95, cx + 55, 125, cx + 50, 155) // right arm/shoulder
      ..cubicTo(cx + 40, 140, cx + 26, 125, cx + 22, 120)
      ..cubicTo(cx + 25, 150, cx + 24, 190, cx + 20, 230) // waist
      ..cubicTo(cx + 15, 260, cx + 12, 285, cx + 5, 290)
      ..lineTo(cx - 5, 290)
      ..cubicTo(cx - 12, 285, cx - 15, 260, cx - 20, 230)
      ..cubicTo(cx - 24, 190, cx - 25, 150, cx - 22, 120)
      ..cubicTo(cx - 26, 125, cx - 40, 140, cx - 50, 155) // left arm
      ..cubicTo(cx - 55, 125, cx - 45, 95, cx - 20, 80)
      ..close();

    canvas.drawPath(torso, bodyPaint);

    // Leader lines & pulse points
    // 1. Mind node (cx, 45) -> right
    _drawPulseNode(canvas, Offset(cx, 45), activeNode == 'mind', Colors.white);
    _drawDottedLine(canvas, Offset(cx, 45), Offset(cx + 40, 36));

    // 2. Heart node (cx, 105) -> right
    _drawPulseNode(canvas, Offset(cx, 105), activeNode == 'heart', AivoColors.orange);
    _drawDottedLine(canvas, Offset(cx, 105), Offset(cx + 40, 120));

    // 3. Breath node (cx, 145) -> left
    _drawPulseNode(canvas, Offset(cx, 145), activeNode == 'breath', AivoColors.orangeBright);
    _drawDottedLine(canvas, Offset(cx, 145), Offset(cx - 40, 180));
  }

  void _drawPulseNode(Canvas canvas, Offset center, bool isActive, Color color) {
    if (isActive) {
      canvas.drawCircle(
        center,
        9,
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawCircle(
      center,
      4,
      Paint()..color = color,
    );
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _HumanSilhouettePainter oldDelegate) =>
      oldDelegate.activeNode != activeNode;
}
