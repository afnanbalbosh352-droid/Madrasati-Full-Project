import 'package:flutter/material.dart';

class AppColors {
  // 🔵 Primary Blues
  static const primaryDark = Color(0xFF0D47A1);
  static const primary = Color(0xFF1565C0);
  static const primaryLight = Color(0xFF1E88E5);

  // ⚪ Background
  static const background = Color(0xFFF4F6F9);
  static const white = Colors.white;

  // ⚫ Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);

  // 🟡 Accent
  static const accent = Color(0xFFFFC107);

  static const LinearGradient gradient = LinearGradient(
    colors: [
      Color(0xFF0D47A1),
      Color(0xFF1565C0),
      Color(0xFF42A5F5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}