import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand Colors (Blue/Yellow palette matching reference UI) ──────────────
  static const Color primaryBlue      = Color(0xFF1565C0); // deep blue header
  static const Color primaryBlueMid   = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color accentYellow     = Color(0xFFFFD600); // yellow FAB / badge
  static const Color accentYellowDark = Color(0xFFFFC107);

  // Light surface
  static const Color lightSurface     = Color(0xFFFFFFFF);
  static const Color lightBackground  = Color(0xFFEEF4FF); // pale blue bg
  static const Color lightCard        = Color(0xFFFFFFFF);

  // Semantic
  static const Color success          = Color(0xFF00C853);
  static const Color lightError       = Color(0xFFFF1744);
  static const Color warning          = Color(0xFFFF9100);
  static const Color info             = Color(0xFF2979FF);

  // Text
  static const Color lightOnPrimary   = Color(0xFFFFFFFF);
  static const Color lightOnSurface   = Color(0xFF1A237E);
  static const Color lightOnBackground= Color(0xFF1A237E);
  static const Color textSecondary    = Color(0xFF5C6BC0);

  // Misc
  static const Color outline          = Color(0xFFBBDEFB);
  static const Color outlineVariant   = Color(0xFF90CAF9);
  static const Color surfaceVariant   = Color(0xFFE3F2FD);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF1565C0),
    Color(0xFF1976D2),
  ];
  static const List<Color> headerGradient = [
    Color(0xFF0D47A1),
    Color(0xFF1976D2),
  ];
  static const List<Color> successGradient = [Color(0xFF00C853), Color(0xFF69F0AE)];
  static const List<Color> warningGradient = [Color(0xFFFF9100), Color(0xFFFFD740)];
  static const List<Color> errorGradient   = [Color(0xFFFF1744), Color(0xFFFF6D00)];

  // ── Text Styles ───────────────────────────────────────────────────────────
  static TextStyle get headingStyle => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5,
  );
  static TextStyle get subheadingStyle => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.25,
  );
  static TextStyle get titleStyle => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w700,
  );
  static TextStyle get subtitleStyle => GoogleFonts.inter(
    fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.1,
  );
  static TextStyle get bodyStyle => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.2,
  );
  static TextStyle get captionStyle => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.3,
  );
  static TextStyle get buttonStyle => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5,
  );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        primaryContainer: primaryBlueMid,
        secondary: accentYellow,
        secondaryContainer: accentYellowDark,
        surface: lightSurface,
        background: lightBackground,
        error: lightError,
        onPrimary: lightOnPrimary,
        onSecondary: Color(0xFF1A237E),
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
        onError: lightOnPrimary,
        surfaceVariant: surfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: lightOnPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: titleStyle.copyWith(color: lightOnPrimary),
        iconTheme: const IconThemeData(color: lightOnPrimary),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: lightOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: buttonStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: buttonStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: bodyStyle.copyWith(color: Colors.grey.shade500),
        labelStyle: bodyStyle.copyWith(color: primaryBlue),
        prefixIconColor: primaryBlue,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Color(0xFF90A4AE),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: Color(0xFF1A237E),
        elevation: 6,
      ),
      dividerTheme: const DividerThemeData(
        color: surfaceVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ── Dark Theme (kept minimal, same palette) ───────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlueMid,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlueMid,
        primaryContainer: primaryBlue,
        secondary: accentYellow,
        surface: Color(0xFF1A237E),
        background: Color(0xFF0D1B4B),
        error: lightError,
        onPrimary: lightOnPrimary,
        onSurface: Color(0xFFE3F2FD),
        onBackground: Color(0xFFE3F2FD),
        surfaceVariant: Color(0xFF1E3A8A),
        outline: Color(0xFF3B5998),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1B4B),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentYellow,
        foregroundColor: Color(0xFF1A237E),
        elevation: 6,
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Color getCategoryColor(String categoryName) {
    const colors = {
      'Food & Dining':    Color(0xFFFF6B6B),
      'Transportation':   Color(0xFF4ECDC4),
      'Shopping':         Color(0xFF45B7D1),
      'Bills & Utilities':Color(0xFF96CEB4),
      'Entertainment':    Color(0xFFFFD600),
      'Health & Fitness': Color(0xFFDDA0DD),
      'Education':        Color(0xFF98D8C8),
      'Travel':           Color(0xFFFFB6C1),
      'Personal Care':    Color(0xFF87CEEB),
      'Gifts & Donations':Color(0xFFF0E68C),
      'Salary':           Color(0xFF00C853),
      'Freelance':        Color(0xFF2979FF),
      'Investments':      Color(0xFF9B59B6),
      'Business':         Color(0xFFE67E22),
      'Other Income':     Color(0xFF1ABC9C),
    };
    return colors[categoryName] ?? primaryBlue;
  }

  static LinearGradient getPrimaryGradient() => const LinearGradient(
    colors: primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getHeaderGradient() => const LinearGradient(
    colors: headerGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getSuccessGradient() => const LinearGradient(
    colors: successGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getWarningGradient() => const LinearGradient(
    colors: warningGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient getErrorGradient() => const LinearGradient(
    colors: errorGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
