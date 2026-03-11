import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryGold,
        surface: surfaceDark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          textStyle: const TextStyle(color: primaryGold, fontWeight: FontWeight.bold),
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          textStyle: const TextStyle(color: primaryGold, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          textStyle: const TextStyle(color: primaryGold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
