import 'package:flutter/material.dart';

/// Colour tokens taken from the UI reference mockups in docs/ui/.
abstract final class AppColors {
  // Surfaces
  static const Color background = Color(0xFFFBFBF9);
  static const Color surface = Color(0xFFFEFEFC);
  static const Color field = Color(0xFFF4F3F3);
  static const Color iconBox = Color(0xFFF4F4F2);
  static const Color divider = Color(0xFFEDEDEB);

  // Brand yellows
  static const Color yellow = Color(0xFFFCCF6B); // buttons, logo
  static const Color yellowSoft = Color(0xFFFEE39A); // next action card
  static const Color yellowPill = Color(0xFFFDE49D); // active nav item
  static const Color yellowTint = Color(0xFFFEEFCE); // icon backgrounds
  static const Color amber = Color(0xFFFDB616); // links ("See all")
  static const Color check = Color(0xFFFDBF1F); // completed checkbox

  // Text
  static const Color ink = Color(0xFF1A1A1A);
  static const Color muted = Color(0xFF7C8494);

  static const Color danger = Color(0xFFE5484D);

  // Priority chips
  static const Color highBg = Color(0xFFFDE8E8);
  static const Color highText = Color(0xFFD64545);
  static const Color mediumBg = Color(0xFFFFF4D6);
  static const Color mediumText = Color(0xFFB7791F);
  static const Color lowBg = Color(0xFFF1F2F4);
  static const Color lowText = Color(0xFF6B7280);
}
