// // utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// class AppTheme {
//   static const Color primaryColor = Color(0xFF2E7D32);
//   static const Color secondaryColor = Color(0xFF4CAF50);
//   static const Color accentColor = Color(0xFF81C784);
//   static const Color errorColor = Color(0xFFE57373);
//   static const Color warningColor = Color.fromRGBO(255, 183, 77, 1);
//   static const Color successColor = Color(0xFF66BB6A);

//   static ThemeData get lightTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       primarySwatch: Colors.green,
//       primaryColor: primaryColor,
//       scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      
//       appBarTheme: const AppBarTheme(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
      
//       cardTheme: const CardTheme(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//       ),
      
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//       ),
      
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: primaryColor, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
      
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }

//   static ThemeData get darkTheme {
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       primarySwatch: Colors.green,
//       primaryColor: primaryColor,
//       scaffoldBackgroundColor: const Color(0xFF121212),
      
//       appBarTheme: const AppBarTheme(
//         backgroundColor: Color(0xFF1E1E1E),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//       ),
      
//       cardTheme: const CardTheme(
//         color: Color(0xFF1E1E1E),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//         ),
//       ),
      
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         ),
//       ),
      
//       inputDecorationTheme: InputDecorationTheme(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: primaryColor, width: 2),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       ),
      
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }
// }

// // utils/constants.dart
import 'dart:ui';

import 'package:intl/intl.dart';

class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String currency = '₹'; // Indian Rupee
  
  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String monthFormat = 'MMM yyyy';
  static const String dayFormat = 'EEE, MMM dd';
  
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Sizes
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue  
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Grey
    Color(0xFF00BCD4), // Cyan
  ];
}



class AppHelpers {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currency,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat(AppConstants.monthFormat).format(date);
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static Color getRandomChartColor(int index) {
    return AppConstants.chartColors[index % AppConstants.chartColors.length];
  }
}



class AppTheme {
  // Define light and dark color schemes
  static const Color primaryLight = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF4CAF50); // A slightly lighter green for contrast on dark backgrounds

  static const Color accentLight = Color(0xFF81C784);
  static const Color accentDark = Color(0xFF81C784); // Can be the same or adjusted

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color cardBackgroundLight = Colors.white;
  static const Color cardBackgroundDark = Color(0xFF1E1E1E);

  static const Color textLight = Colors.black87;
  static const Color textDark = Colors.white;

  // Semantic colors
  static const Color errorColor = Color(0xFFE57373);
  static const Color warningColor = Color(0xFFFFB74D);
  static const Color successColor = Color(0xFF66BB6A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: accentLight,
        background: backgroundLight,
        surface: cardBackgroundLight,
        onSurface: textLight,
        error: errorColor,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: const CardTheme(
        color: cardBackgroundLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryLight,
        foregroundColor: Colors.white,
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textLight),
        bodyMedium: TextStyle(color: textLight),
        bodySmall: TextStyle(color: textLight),
        titleLarge: TextStyle(color: textLight),
        titleMedium: TextStyle(color: textLight),
        titleSmall: TextStyle(color: textLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: accentDark,
        background: backgroundDark,
        surface: cardBackgroundDark,
        onSurface: textDark,
        error: errorColor,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      cardTheme: const CardTheme(
        color: cardBackgroundDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        bodySmall: TextStyle(color: textDark),
        titleLarge: TextStyle(color: textDark),
        titleMedium: TextStyle(color: textDark),
        titleSmall: TextStyle(color: textDark),
      ),
    );
  }
}