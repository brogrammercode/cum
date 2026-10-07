import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme(ColorScheme colorScheme) {
  return GoogleFonts.spaceGroteskTextTheme().copyWith(
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 32.r,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 25.r,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 21.r,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      fontSize: 16.r,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.spaceGrotesk(fontSize: 16.r),
    bodyMedium: GoogleFonts.spaceGrotesk(fontSize: 14.r),
    bodySmall: GoogleFonts.spaceGrotesk(fontSize: 12.r),
    labelLarge: GoogleFonts.spaceGrotesk(
      fontSize: 14.r,
      fontWeight: FontWeight.w700,
    ),
  );
}
