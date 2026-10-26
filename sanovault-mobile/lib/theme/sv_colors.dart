import 'package:flutter/cupertino.dart';

/// Reference palette. Keep in sync with sanovault-web/app/globals.css.
abstract final class SvColors {
  static const brand = Color(0xFF1E76F7);
  static const brandStrong = Color(0xFF165FCF);
  static const brandTint = Color(0xFFE8F0FF);
  static const ink = Color(0xFF362F2F);
  static const slate = Color(0xFF625D66);
  static const silver = Color(0xFFCDD1D9);
  static const groupedBackground = Color(0xFFF3F2F3);
  static const surface = Color(0xFFFFFFFF);
  static const peach = Color(0xFFF4999D);
  static const highlighterRed = Color(0xFFE44B58);
  static const separator = silver;
  // Darker red and blue keep small text and white button labels readable.
  static const danger = Color(0xFFB22B3C);
  static const dangerTint = Color(0xFFFDEBEE);
  static const success = brandStrong;
  static const warning = ink;
  static const warningTint = peach;

  static const primaryButton = brandStrong;
  static const sage = brand;
  static const inviteFill = brandTint;
  static const inviteInk = brandStrong;
}
