import 'package:flutter/material.dart';

class AppTheme {
  // Primary gradient colors (matching original design)
  static const Color primaryStart = Color(0xFF5865F2);
  static const Color primaryMiddle = Color(0xFF4752C4);
  static const Color primaryEnd = Color(0xFF3C45A5);

  // Main gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryMiddle, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFFFFFFF);
  static const Color textTertiary = Color(0xB3FFFFFF); // 70% opacity

  // Card colors
  static const Color cardBackground = Color(0x33FFFFFF); // 20% opacity
  static const Color cardBorder = Color(0x4DFFFFFF); // 30% opacity

  // Button colors
  static const Color buttonBackground = Color(0x33FFFFFF); // 20% opacity
  static const Color buttonHover = Color(0x4DFFFFFF); // 30% opacity

  // Shadow colors
  static const Color shadowColor = Color(0x40000000); // 25% opacity
  static const Color glowColor = Color(0x66FFFFFF); // 40% opacity

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle pingLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle pingDescription = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.3,
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXL = 32.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: shadowColor,
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: glowColor,
      blurRadius: 30,
      offset: Offset(0, 0),
    ),
  ];

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Create Material Theme
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: heading3,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonText,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBackground,
          foregroundColor: textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusL),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingL,
            vertical: spacingM,
          ),
          textStyle: buttonText,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
          side: const BorderSide(
            color: cardBorder,
            width: 1,
          ),
        ),
      ),
    );
  }
}

// Gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
      ),
      child: child,
    );
  }
}