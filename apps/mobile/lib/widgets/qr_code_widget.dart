import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/aivo_theme.dart';

class AivoQrCodeWidget extends StatelessWidget {
  final String code;
  final double size;

  const AivoQrCodeWidget({
    super.key,
    required this.code,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141218),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AivoColors.orange.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AivoColors.orange.withOpacity(0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _QrMatrixPainter(code: code),
      ),
    );
  }
}

class _QrMatrixPainter extends CustomPainter {
  final String code;

  _QrMatrixPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final paintAccent = Paint()
      ..color = AivoColors.orangeBright
      ..style = PaintingStyle.fill;

    final paintWhite = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const matrixSize = 17; // 17x17 grid
    final cellSize = size.width / matrixSize;

    // Draw the 3 corner finder patterns (top-left, top-right, bottom-left)
    void drawFinderPattern(int r, int c) {
      // Outer 5x5
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          if (i == 0 || i == 4 || j == 0 || j == 4 || (i >= 1 && i <= 3 && j >= 1 && j <= 3 && (i == 2 && j == 2))) {
            final rect = Rect.fromLTWH((c + j) * cellSize, (r + i) * cellSize, cellSize - 1.2, cellSize - 1.2);
            final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
            canvas.drawRRect(rrect, paintAccent);
          }
        }
      }
    }

    drawFinderPattern(0, 0); // Top-left
    drawFinderPattern(0, matrixSize - 5); // Top-right
    drawFinderPattern(matrixSize - 5, 0); // Bottom-left

    // Seed pseudorandom data cells derived from code
    final seed = code.codeUnits.fold(0, (prev, elem) => prev + elem);
    final rng = Random(seed);

    for (int r = 0; r < matrixSize; r++) {
      for (int c = 0; c < matrixSize; c++) {
        // Skip finder areas
        if ((r < 5 && c < 5) || (r < 5 && c >= matrixSize - 5) || (r >= matrixSize - 5 && c < 5)) {
          continue;
        }

        // Generate dot based on seeded pseudo-randomness
        if (rng.nextDouble() > 0.46) {
          final isAccent = (r + c) % 4 == 0;
          final rect = Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1.5, cellSize - 1.5);
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
          canvas.drawRRect(rrect, isAccent ? paintAccent : paintWhite);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrMatrixPainter oldDelegate) => oldDelegate.code != code;
}
