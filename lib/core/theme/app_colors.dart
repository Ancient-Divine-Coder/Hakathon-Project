import 'package:flutter/material.dart';

/// Design tokens derived from Stitch DESIGN.md for Smart Campus ERP
class AppColors {
  AppColors._();

  // Surfaces & Canvas
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFCBDBF5);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD3E4FE);

  // Content / Foreground
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color inverseSurface = Color(0xFF213145);
  static const Color inverseOnSurface = Color(0xFFEAF1FF);

  // Outlines & Borders
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color surfaceTint = Color(0xFF565E74);

  // Brand / Actions
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF131B2E);
  static const Color onPrimaryContainer = Color(0xFF7C839B);
  static const Color inversePrimary = Color(0xFFBEC6E0);

  // Secondary
  static const Color secondary = Color(0xFF545F73);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD5E0F8);
  static const Color onSecondaryContainer = Color(0xFF586377);

  // Tertiary
  static const Color tertiary = Color(0xFF000000);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00174B);
  static const Color onTertiaryContainer = Color(0xFF497CFF);

  // Semantic Status Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color success = Color(0xFF059669);
  static const Color successContainer = Color(0xFFECFDF5);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF047857);

  static const Color warning = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFFFBEB);
  static const Color onWarningContainer = Color(0xFFB45309);

  static const Color info = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFEFF6FF);

  // Fixed Tokens from Stitch Palette
  static const Color secondaryFixed = Color(0xFFD8E3FB);
  static const Color onSecondaryFixedVariant = Color(0xFF3C475A);
  static const Color onTertiaryFixedVariant = Color(0xFF003EA8);
}
