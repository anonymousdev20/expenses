import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF6366F1);
  static const Color lightPrimaryVariant = Color(0xFF4F46E5);
  static const Color lightSecondary = Color(0xFF8B5CF6);
  static const Color lightSecondaryVariant = Color(0xFF7C3AED);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnBackground = Color(0xFF111827);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF6366F1);
  static const Color darkPrimaryVariant = Color(0xFF818CF8);
  static const Color darkSecondary = Color(0xFF8B5CF6);
  static const Color darkSecondaryVariant = Color(0xFFA78BFA);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkOnBackground = Color(0xFFF3F4F6);
  static const Color darkOnError = Color(0xFFFFFFFF);

  // Common Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFFBB024),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFF87171),
  ];

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle get subheadingStyle => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  static TextStyle get titleStyle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  static TextStyle get subtitleStyle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get captionStyle => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle get buttonStyle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightPrimary,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        primaryContainer: lightPrimaryVariant,
        secondary: lightSecondary,
        secondaryContainer: lightSecondaryVariant,
        surface: lightSurface,
        background: lightBackground,
        error: lightError,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnSecondary,
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
        onError: lightOnError,
        surfaceVariant: surfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleStyle.copyWith(color: lightOnSurface),
        iconTheme: const IconThemeData(color: lightOnSurface),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: lightOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: buttonStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: bodyStyle.copyWith(color: Colors.grey.shade600),
        labelStyle: bodyStyle.copyWith(color: lightPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(color: lightOnBackground),
        displayMedium: subheadingStyle.copyWith(color: lightOnBackground),
        displaySmall: titleStyle.copyWith(color: lightOnBackground),
        headlineLarge: titleStyle.copyWith(color: lightOnBackground),
        headlineMedium: subtitleStyle.copyWith(color: lightOnBackground),
        headlineSmall: subtitleStyle.copyWith(color: lightOnBackground),
        titleLarge: titleStyle.copyWith(color: lightOnBackground),
        titleMedium: subtitleStyle.copyWith(color: lightOnBackground),
        titleSmall: bodyStyle.copyWith(color: lightOnBackground),
        bodyLarge: bodyStyle.copyWith(color: lightOnBackground),
        bodyMedium: bodyStyle.copyWith(color: lightOnBackground),
        bodySmall: captionStyle.copyWith(color: lightOnBackground),
        labelLarge: buttonStyle.copyWith(color: lightOnBackground),
        labelMedium: bodyStyle.copyWith(color: lightOnBackground),
        labelSmall: captionStyle.copyWith(color: lightOnBackground),
      ),
      iconTheme: const IconThemeData(
        color: lightOnSurface,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: lightPrimary.withOpacity(0.1),
        disabledColor: Colors.grey.shade300,
        labelStyle: bodyStyle.copyWith(color: lightOnSurface),
        secondaryLabelStyle: bodyStyle.copyWith(color: lightPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
        elevation: 4,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryVariant,
        secondary: darkSecondary,
        secondaryContainer: darkSecondaryVariant,
        surface: darkSurface,
        background: darkBackground,
        error: darkError,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
        onError: darkOnError,
        surfaceVariant: Color(0xFF374151),
        outline: Color(0xFF4B5563),
        outlineVariant: Color(0xFF6B7280),
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleStyle.copyWith(color: darkOnSurface),
        iconTheme: const IconThemeData(color: darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: buttonStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: bodyStyle.copyWith(color: Colors.grey.shade400),
        labelStyle: bodyStyle.copyWith(color: darkPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(color: darkOnBackground),
        displayMedium: subheadingStyle.copyWith(color: darkOnBackground),
        displaySmall: titleStyle.copyWith(color: darkOnBackground),
        headlineLarge: titleStyle.copyWith(color: darkOnBackground),
        headlineMedium: subtitleStyle.copyWith(color: darkOnBackground),
        headlineSmall: subtitleStyle.copyWith(color: darkOnBackground),
        titleLarge: titleStyle.copyWith(color: darkOnBackground),
        titleMedium: subtitleStyle.copyWith(color: darkOnBackground),
        titleSmall: bodyStyle.copyWith(color: darkOnBackground),
        bodyLarge: bodyStyle.copyWith(color: darkOnBackground),
        bodyMedium: bodyStyle.copyWith(color: darkOnBackground),
        bodySmall: captionStyle.copyWith(color: darkOnBackground),
        labelLarge: buttonStyle.copyWith(color: darkOnBackground),
        labelMedium: bodyStyle.copyWith(color: darkOnBackground),
        labelSmall: captionStyle.copyWith(color: darkOnBackground),
      ),
      iconTheme: const IconThemeData(
        color: darkOnSurface,
        size: 24,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF4B5563),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF374151),
        selectedColor: darkPrimary.withOpacity(0.2),
        disabledColor: Colors.grey.shade600,
        labelStyle: bodyStyle.copyWith(color: darkOnSurface),
        secondaryLabelStyle: bodyStyle.copyWith(color: darkPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        elevation: 4,
      ),
    );
  }

  // Custom Colors
  static Color getCategoryColor(String categoryName) {
    final colors = {
      'Food & Dining': const Color(0xFFFF6B6B),
      'Transportation': const Color(0xFF4ECDC4),
      'Shopping': const Color(0xFF45B7D1),
      'Bills & Utilities': const Color(0xFF96CEB4),
      'Entertainment': const Color(0xFFFFEAA7),
      'Health & Fitness': const Color(0xFFDDA0DD),
      'Education': const Color(0xFF98D8C8),
      'Travel': const Color(0xFFFFB6C1),
      'Personal Care': const Color(0xFF87CEEB),
      'Gifts & Donations': const Color(0xFFF0E68C),
      'Salary': const Color(0xFF2ECC71),
      'Freelance': const Color(0xFF3498DB),
      'Investments': const Color(0xFF9B59B6),
      'Business': const Color(0xFFE67E22),
      'Other Income': const Color(0xFF1ABC9C),
    };
    return colors[categoryName] ?? lightPrimary;
  }

  static LinearGradient getPrimaryGradient() {
    return const LinearGradient(
      colors: primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getSuccessGradient() {
    return const LinearGradient(
      colors: successGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getWarningGradient() {
    return const LinearGradient(
      colors: warningGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getErrorGradient() {
    return const LinearGradient(
      colors: errorGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
