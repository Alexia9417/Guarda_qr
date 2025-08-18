import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.azul),
    scaffoldBackgroundColor: AppColors.fondo,
    primaryColor: AppColors.azul,

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.azul,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        minimumSize: const Size.fromHeight(55),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: AppColors.texto),
      prefixIconColor: AppColors.texto,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: BorderSide(color: AppColors.azul.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: AppColors.azul, width: 2),
      ),
    ),
  );
}
