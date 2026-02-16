import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const seed = Color(0xFF8C5E58);
  static const primary = Color(0xFF7B4B46);
  static const secondary = Color(0xFF3F6C6B);
  static const accent = Color(0xFFFFB677);
  static const ink = Color(0xFF2B1B17);
  static const softInk = Color(0xFF5A4A45);
  static const surface = Color(0xFFFFFAF6);
  static const background = Color(0xFFF7F3EE);
  static const success = Color(0xFF2F8E6F);
  static const warning = Color(0xFFE4A03B);
}

ThemeData buildTheme() {
  final textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: 44, fontWeight: FontWeight.w600),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700),
    titleMedium: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w500),
    bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500),
    bodySmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
  );

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.surface,
    error: const Color(0xFFB3261E),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.softInk.withOpacity(0.7)),
    ),
  );
}
