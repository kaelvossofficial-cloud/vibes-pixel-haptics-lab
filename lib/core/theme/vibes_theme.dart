import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System for VIBES: The Pixel Haptics Lab
/// Retro-cyber terminal aesthetic meets cozy 16-bit sandbox.
class VibesTheme {
  // Color Palette Constants
  static const Color deepVoid = Color(0xFF121216);      // Deep Void Background
  static const Color obsidianSlate = Color(0xFF1E1F29); // Card / Container Surface
  static const Color surfaceBorder = Color(0xFF2E3040); // Pixel Outlines
  static const Color surfaceHighlight = Color(0xFF383A4E);

  // Accent Colors
  static const Color emeraldXP = Color(0xFF55FF55);     // Accent Green (Active/Play)
  static const Color redstone = Color(0xFFFF3B30);      // Accent Redstone (Danger/Stop)
  static const Color diamondCyan = Color(0xFF00E5FF);   // Accent Cyan (Frequency/Sine)
  static const Color lapisBlue = Color(0xFF2979FF);     // Secondary Accent (Wave/Data)
  static const Color goldNugget = Color(0xFFFFD700);    // Warm Gold (Warning/Resonance)
  static const Color pixelWhite = Color(0xFFF4F4F4);    // High-contrast readout
  static const Color mutedStone = Color(0xFF8E8E93);    // Secondary text / inactive

  // Typography definitions
  static TextStyle pixelHeadline({
    double fontSize = 16,
    Color color = pixelWhite,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 1.2,
    );
  }

  static TextStyle pixelDisplay({
    double fontSize = 22,
    Color color = emeraldXP,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.silkscreen(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 2.0,
    );
  }

  static TextStyle monoNumeric({
    double fontSize = 14,
    Color color = pixelWhite,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    );
  }

  static TextStyle monoLabel({
    double fontSize = 11,
    Color color = mutedStone,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: 1.0,
    );
  }

  // ThemeData
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepVoid,
      primaryColor: emeraldXP,
      colorScheme: const ColorScheme.dark(
        primary: emeraldXP,
        secondary: diamondCyan,
        surface: obsidianSlate,
        error: redstone,
      ),
      textTheme: TextTheme(
        headlineMedium: pixelHeadline(fontSize: 20),
        titleMedium: pixelHeadline(fontSize: 14),
        bodyMedium: monoNumeric(fontSize: 14),
        bodySmall: monoLabel(fontSize: 12),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: obsidianSlate,
        contentTextStyle: TextStyle(color: pixelWhite),
      ),
    );
  }
}
