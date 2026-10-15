import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle headlineXl = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.8,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.18,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.13,
    color: AppColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.48,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle codeSm = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.onSurfaceVariant,
  );
}
