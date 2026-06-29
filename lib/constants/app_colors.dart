import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF0B0E17);
  static const Color bg2 = Color(0xFF111827);
  static const Color bg3 = Color(0xFF1A2235);
  static const Color border = Color(0xFF1E2D45);
  static const Color t1 = Color(0xFFE8EDF5);
  static const Color t2 = Color(0xFFB0BDD0);
  static const Color t3 = Color(0xFF7A8FAD);
  static const Color t4 = Color(0xFF4A5F7A);
  static const Color green = Color(0xFF00E676);
  static const Color greenDim = Color(0xFF00C853);
  static const Color red = Color(0xFFFF3D57);
  static const Color redDim = Color(0xFFD32F2F);
  static const Color gold = Color(0xFFFFB300);
  static const Color accent = Color(0xFF2979FF);
  static const Color demoColor = Color(0xFFFFB300);
  static const Color realColor = Color(0xFF00E676);

  static const Color lightBg = Color(0xFFF0F4FA);
  static const Color lightBg2 = Color(0xFFFFFFFF);
  static const Color lightBg3 = Color(0xFFE8EDF5);
  static const Color lightBorder = Color(0xFFCDD5E0);
  static const Color lightT1 = Color(0xFF1A2235);
  static const Color lightT2 = Color(0xFF3A4F6A);
  static const Color lightT3 = Color(0xFF6A7F9A);
  static const Color lightT4 = Color(0xFF9AAFCA);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    primaryColor: accent,
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: bg2,
      error: red,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBg,
    primaryColor: accent,
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.light(
      primary: accent,
      surface: lightBg2,
      error: red,
    ),
  );
}
