import 'package:flutter/material.dart';
import 'vibes_theme.dart';

/// Provides retro stepped pixel box decorations and border painters
class PixelBorders {
  /// Standard 3D pixel container decoration with hard drop shadow
  static BoxDecoration container({
    Color backgroundColor = VibesTheme.obsidianSlate,
    Color borderColor = VibesTheme.surfaceBorder,
    Color? shadowColor,
    double borderWidth = 2.0,
    double shadowOffset = 3.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        if (shadowColor != null || shadowOffset > 0)
          BoxShadow(
            color: shadowColor ?? Colors.black.withOpacity(0.6),
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0, // Hard pixel shadow
          ),
      ],
    );
  }

  /// Inset retro panel decoration for input fields and readouts
  static BoxDecoration insetPanel({
    Color backgroundColor = VibesTheme.deepVoid,
    Color borderColor = VibesTheme.surfaceBorder,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: borderColor,
        width: 2.0,
      ),
    );
  }

  /// Glowing accent border for active/running state
  static BoxDecoration activeNeonContainer({
    Color backgroundColor = VibesTheme.obsidianSlate,
    Color neonColor = VibesTheme.emeraldXP,
    double shadowOffset = 3.0,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      border: Border.all(
        color: neonColor,
        width: 2.0,
      ),
      boxShadow: [
        BoxShadow(
          color: neonColor.withOpacity(0.3),
          blurRadius: 8.0,
          spreadRadius: 1.0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.8),
          offset: Offset(shadowOffset, shadowOffset),
          blurRadius: 0,
        ),
      ],
    );
  }
}
