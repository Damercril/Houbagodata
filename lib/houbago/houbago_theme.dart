import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class HoubagoTheme {
  HoubagoTheme._();
  
  // Couleur principale (Bleu) et ses variantes
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF03A9F4);
  static const Color primaryLighter = Color(0xFF80D8FF);
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primaryDarker = Color(0xFF0D0D0D);

  // Couleur secondaire (Bleu-gris) et ses variantes
  static const Color secondary = Color(0xFF03A9F4);
  static const Color secondaryLight = Color(0xFF80D8FF);
  static const Color secondaryLighter = Color(0xFFB2EBF2);
  static const Color secondaryDark = Color(0xFF006064);
  static const Color secondaryDarker = Color(0xFF003333);

  // Couleurs de fond
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFFE0E0E0);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceColor = Colors.white;

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black87;

  // Couleurs d'état
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Couleurs d'accentuation
  static const Color accent1 = Color(0xFFFFB74D);
  static const Color accent2 = Color(0xFF90CAF9);

  // Styles de composants
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: secondaryLight, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: secondaryLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: error, width: 1),
    ),
    labelStyle: textTheme.labelLarge?.copyWith(color: textSecondary),
    hintStyle: textTheme.bodyMedium?.copyWith(color: textHint),
    prefixIconColor: secondary,
    suffixIconColor: secondary,
    errorStyle: textTheme.bodySmall?.copyWith(color: error),
  );

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: textLight,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    textStyle: textTheme.labelLarge,
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primary,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: textTheme.labelLarge,
  );

  static final CardTheme cardTheme = CardTheme(
    color: surfaceColor,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primary,
    foregroundColor: textLight,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: textTheme.titleLarge?.copyWith(color: textLight),
    iconTheme: IconThemeData(color: textLight),
  );

  // Bordures personnalisées pour les inputs
  static final OutlineInputBorder _defaultInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: secondaryLight, width: 1),
  );

  static final OutlineInputBorder _focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: primary, width: 2),
  );

  static final OutlineInputBorder _errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: error, width: 1),
  );

  // Configuration des styles de texte
  static final TextTheme textTheme = TextTheme(
    // Grands titres
    displayLarge: GoogleFonts.poppins(
      fontSize: 96,
      fontWeight: FontWeight.w300,
      letterSpacing: -1.5,
      color: textPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 60,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.5,
      color: textPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 48,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),

    // Titres
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: 0,
      color: textPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 34,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimary,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: textPrimary,
    ),

    // Sous-titres
    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: textPrimary,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: textPrimary,
    ),

    // Corps de texte
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: textPrimary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: textSecondary,
    ),

    // Labels
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.25,
      color: textPrimary,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: textPrimary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.5,
      color: textSecondary,
    ),
  );

  // Styles additionnels pour cas spécifiques
  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.43,
    color: textLight,
  );

  static final TextStyle captionBold = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.33,
    color: textPrimary,
  );

  static final TextStyle overline = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
    color: textSecondary,
  );
}
