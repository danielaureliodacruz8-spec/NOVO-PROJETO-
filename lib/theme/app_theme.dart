import 'package:flutter/material.dart';

class AppColors {
  static const Color azulPrimario = Color(0xFF0B3D91);
  static const Color azulSecundario = Color(0xFF1463D9);
  static const Color azulClaro = Color(0xFFEAF2FF);

  static const Color fundo = Color(0xFFF4F7FB);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color textoPrincipal = Color(0xFF172033);
  static const Color textoSecundario = Color(0xFF64748B);
  static const Color borda = Color(0xFFD9E2F0);

  static const Color sucesso = Color(0xFF16803C);
  static const Color sucessoClaro = Color(0xFFE8F7ED);

  static const Color atencao = Color(0xFFC77B00);
  static const Color atencaoClaro = Color(0xFFFFF5D9);

  static const Color erro = Color(0xFFC62828);
  static const Color erroClaro = Color(0xFFFDEBEC);
}

class AppTheme {
  static ThemeData get temaClaro {
    final esquemaCores = ColorScheme.fromSeed(
      seedColor: AppColors.azulPrimario,
      primary: AppColors.azulPrimario,
      secondary: AppColors.azulSecundario,
      surface: AppColors.superficie,
      error: AppColors.erro,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquemaCores,
      scaffoldBackgroundColor: AppColors.fundo,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: AppColors.borda,
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulPrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.azulPrimario,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(
            color: AppColors.azulPrimario,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textoSecundario,
          fontSize: 16,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textoSecundario,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.borda,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.borda,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.azulSecundario,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.erro,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.erro,
            width: 2,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.azulPrimario,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: StadiumBorder(),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textoPrincipal,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borda,
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textoSecundario,
          fontSize: 14,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}