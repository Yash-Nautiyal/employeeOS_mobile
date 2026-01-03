import 'package:flutter/material.dart';

enum Fonts { publicSans, inter, dmSans, nunitoSans }

class AppTypography {
  // remove const so this can change at runtime:
  static String primaryFont = 'PublicSans';
  static const String secondaryFont = 'Barlow';

  // helper to map enum → actual family name:
  static String fontFamily(Fonts font) {
    switch (font) {
      case Fonts.inter:
        return 'Inter';
      case Fonts.dmSans:
        return 'DM Sans';
      case Fonts.nunitoSans:
        return 'Nunito Sans';
      case Fonts.publicSans:
        return 'Public Sans';
    }
  }

  // optional setter you can call from the bloc:
  static void setPrimaryFont(Fonts font) {
    primaryFont = fontFamily(font);
  }

  static Map<Fonts, String> fontMap = {
    Fonts.publicSans: 'Public Sans',
    Fonts.inter: 'Inter',
    Fonts.dmSans: 'DM Sans',
    Fonts.nunitoSans: 'Nunito Sans',
  };
  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Headings
  static const TextStyle displayLarge = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: extraBold,
    fontSize: 40,
    height: 80 / 64,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: extraBold,
    fontSize: 32,
    height: 64 / 48,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: secondaryFont,
    fontWeight: bold,
    fontSize: 24,
    height: 1.5,
  );

  // Subtitles
  static const TextStyle titleLarge = TextStyle(
    fontWeight: semiBold,
    fontSize: 20,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontWeight: semiBold,
    fontSize: 16,
    height: 1.5,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, height: 1.5);

  static const TextStyle bodyMedium = TextStyle(fontSize: 14, height: 22 / 14);

  static const TextStyle bodySmall = TextStyle(fontSize: 12, height: 1.5);

  // Button Text
  static const TextStyle button = TextStyle(
    fontWeight: bold,
    fontSize: 14,
    height: 24 / 14,
  );
}
