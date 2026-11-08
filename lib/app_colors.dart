import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF070C1C);
  static const white = Color(0xFFFFFFFF);
  static const label = Color(0xFFB4B9CC);
  static const chevron = Color(0xFFF4F5F8);
  static const toast = Color(0xFFD5D8E6);

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF070C1C),
      Color(0xFF0B1328),
      Color(0xFF10182F),
      Color(0xFF17142F),
    ],
    stops: [0.0, 0.42, 0.74, 1.0],
  );
}
