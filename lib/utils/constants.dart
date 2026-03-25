import 'package:flutter/material.dart';

class AppColors {
  // Driver App Color System from Design Spec
  static const Color primary = Color(0xFF37474F);           // Primary blue-grey
  static const Color primaryLight = Color(0xFF546E7A);      // Primary light blue-grey
  static const Color accent = Color(0xFFC8960C);            // Accent/warning highlights
  static const Color success = Color(0xFF27AE60);           // Success states
  static const Color error = Color(0xFFE74C3C);             // Error states
  static const Color warning = Color(0xFFF39C12);           // Warning/out for delivery
  static const Color background = Color(0xFFF5F7FA);        // App background
  static const Color surface = Color(0xFFFFFFFF);           // Cards, modals
  static const Color textPrimary = Color(0xFF1A1A2E);       // Main text
  static const Color textSecondary = Color(0xFF6C757D);     // Subtitles, timestamps
  
  // Legacy colors for backward compatibility
  static const Color primaryDark = Color(0xFF37474F);       // Same as primary
  static const Color secondary = Color(0xFF546E7A);         // Same as primaryLight
  static const Color info = Color(0xFF546E7A);              // Same as primaryLight
  static const Color textLight = Color(0xFF6C757D);         // Same as textSecondary
  static const Color border = Color(0xFFE5E7EB);            // Light border
}

class AppStrings {
  static const String appName = "Zaf's Tea Driver";
  static const String loginTitle = 'Driver Login';
  static const String dashboard = "Zaf's Tea Driver";
  static const String activeOrders = 'Active Orders';
  static const String orderHistory = 'Order History';
  static const String earnings = 'Earnings';
  static const String profile = 'Profile';
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double borderWidth = 1.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}