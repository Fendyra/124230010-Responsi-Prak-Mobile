import 'package:flutter/material.dart';

class ChamberColor {
  static const Color background = Color(0xFFFBF3E6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF3D405B);
  static const Color secondary = Color(0xFFA9E4F7);
  static const Color accent = Color(0xFFFDEB93);
  static const Color text = Color(0xFF3D405B);
  static const Color grey = Color(0xFF8D99AE);
}

ThemeData buildTheme() {
  final baseTheme = ThemeData.light(useMaterial3: true);
  
  return baseTheme.copyWith(
    primaryColor: ChamberColor.primary,
    scaffoldBackgroundColor: ChamberColor.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: ChamberColor.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: ChamberColor.primary),
      titleTextStyle: TextStyle(
        color: ChamberColor.primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
      ),
    ),

    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ChamberColor.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: ChamberColor.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: ChamberColor.primary, width: 2.0),
      ),
      labelStyle: const TextStyle(color: ChamberColor.grey),
      hintStyle: const TextStyle(color: ChamberColor.grey),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.focused) ? ChamberColor.primary : ChamberColor.grey,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ChamberColor.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ChamberColor.primary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    textTheme: baseTheme.textTheme.apply(
      bodyColor: ChamberColor.text,
      displayColor: ChamberColor.primary,
    ).copyWith(
      displaySmall: baseTheme.textTheme.displaySmall?.copyWith(
        color: ChamberColor.primary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
        color: ChamberColor.grey,
        fontSize: 16,
      ),
      bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
        color: ChamberColor.grey,
        fontSize: 16,
      ),
    ),
  );
}