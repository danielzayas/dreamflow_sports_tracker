import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Headspace inspired colors
  static const Color primaryColor = Color(0xFF1AACFE); // Blue
  static const Color secondaryColor = Color(0xFFF7B500); // Yellow
  static const Color backgroundColor = Color(0xFFF8F9FB);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF3F414E);
  static const Color textSecondaryColor = Color(0xFF979797);
  static const Color accentColor = Color(0xFFFF4C60); // Coral
  static const Color errorColor = Color(0xFFFF4C60);
  
  // Status colors
  static const Color liveColor = Color(0xFFFF4C60); // Coral
  static const Color upcomingColor = Color(0xFF6CB28E); // Mint
  static const Color completedColor = Color(0xFF979797); // Grey
  
  // Category colors by sport
  static const Map<String, Color> sportColors = {
    'mens_ncaa_basketball': Color(0xFFFEB18F), // Soft orange
    'womens_ncaa_basketball': Color(0xFFFFCF86), // Soft yellow
    'pga_tour': Color(0xFF6CB28E), // Soft green
    'wpga_tour': Color(0xFF6AC3BD), // Soft teal
    'nhl': Color(0xFF1AACFE), // Soft blue
  };

  // Light Theme - Headspace inspired
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
      surface: cardColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardTheme: CardTheme(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimaryColor,
      centerTitle: true,
      elevation: 0,
      shadowColor: Colors.transparent,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
    ),
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      titleLarge: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        color: textPrimaryColor,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        color: textPrimaryColor,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade50,
      labelStyle: GoogleFonts.nunito(fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: textSecondaryColor,
      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.normal),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: primaryColor.withOpacity(0.1),
      ),
    ),
  );

  // Helper methods for status colors
  static Color getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return upcomingColor;
      case 'ongoing':
      case 'live':
        return liveColor;
      case 'completed':
        return completedColor;
      default:
        return textSecondaryColor;
    }
  }

  // Helper methods for category colors
  static Color getSportCategoryColor(String categoryId) {
    return sportColors[categoryId] ?? primaryColor;
  }
}