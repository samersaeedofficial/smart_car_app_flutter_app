import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  // Core Background & Surfaces
  static const Color background = Color(0xFF020617); // Slate 950
  static const Color surface = Color(0xFF0F172A); // Slate 900
  static const Color surfaceElevated = Color(0xFF1E293B); // Slate 800
  static const Color border = Color(0xFF334155); // Slate 700
  static const Color borderSubtle = Color(0x33475569); // Slate 600 with opacity

  // Neon Accent Colors
  static const Color cyan = Color(0xFF06B6D4); // Primary Action
  static const Color cyanGlow = Color(0xFF22D3EE);
  static const Color emerald = Color(0xFF10B981); // Move Freely / Success
  static const Color emeraldGlow = Color(0xFF34D399);
  static const Color violet = Color(0xFF8B5CF6); // Move in Line / Precision
  static const Color violetGlow = Color(0xFFA78BFA);
  static const Color amber = Color(0xFFF59E0B); // Warning / Throttle
  static const Color rose = Color(0xFFF43F5E); // Danger / Stop

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF2563EB), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF14B8A6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF9333EA), Color(0xFFC026D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFBE123C), Color(0xFF881337)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xEE0F172A), Color(0xCC020617)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows & Glows
  static List<BoxShadow> glowShadow(Color color, {double blur = 20, double opacity = 0.4}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 1,
      ),
    ];
  }

  // Card Decoration Helper
  static BoxDecoration glassCardDecoration({
    Color borderColor = borderSubtle,
    Color glowColor = Colors.transparent,
    double borderRadius = 24.0,
  }) {
    return BoxDecoration(
      color: surface.withOpacity(0.85),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        if (glowColor != Colors.transparent)
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: -2,
          ),
      ],
    );
  }

  // ThemeData Setup
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: cyan,
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: violet,
        surface: surface,
        error: rose,
        onPrimary: Colors.white,
        onSurface: Color(0xFFF1F5F9),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        bodyMedium: GoogleFonts.inter(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        labelSmall: GoogleFonts.jetBrainsMono(
          color: const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
