import 'package:flutter/material.dart';

class AppColors {
  static const Color bgColor = Colors.white;
  static const Color primaryColor = Color.fromARGB(255, 0, 0, 0);
  static const Color secondaryColor = Color(0xff000710);
  static final Color fade = const Color(0xff2563EB).withValues(alpha: 0.4);
  static const LinearGradient gradientColor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7B4BF5), Color(0xFFBD5FF3)],
  );
}
