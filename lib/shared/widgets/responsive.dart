import 'package:flutter/material.dart';

class Responsive {
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1100;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 720 && MediaQuery.of(context).size.width < 1100;
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 720;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 64;
    if (width >= 720) return 32;
    return 20;
  }
}
