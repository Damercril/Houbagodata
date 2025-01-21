import 'package:flutter/material.dart';

class HoubagoTheme {
  static const Color primary = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textLight = Colors.white;

  static final TextTheme textTheme = TextTheme(
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black.withOpacity(0.8),
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.black.withOpacity(0.8),
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.black.withOpacity(0.7),
    ),
  );
}
