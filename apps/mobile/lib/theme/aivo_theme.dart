import 'package:flutter/material.dart';

class AivoColors {
  static const Color background = Color(0xFF0B0B0E);
  static const Color surface = Color(0xFF121015);
  static const Color card = Color(0xFF16141B);
  static const Color cardBorder = Color(0x1FFFFFFF);
  
  // Glowing warm amber / orange palette
  static const Color orange = Color(0xFFFF6B2C);
  static const Color orangeLight = Color(0xFFFF8A3D);
  static const Color orangeBright = Color(0xFFFFA05C);
  static const Color copper = Color(0xFFB85D32);
  static const Color peach = Color(0xFFF3E8DC);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA7);
  static const Color textMuted = Color(0xFF7E7D88);
}

class AivoTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AivoColors.background,
      primaryColor: AivoColors.orange,
      colorScheme: const ColorScheme.dark(
        primary: AivoColors.orange,
        secondary: AivoColors.orangeLight,
        surface: AivoColors.surface,
      ),
    );
  }
}
