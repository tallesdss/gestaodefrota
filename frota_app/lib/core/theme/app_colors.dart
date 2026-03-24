import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  
  // Surfaces
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  
  // Content
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color onSurfaceVariant = Color(0xFF44474E); // Typo label color
  
  // Functional
  static const Color tertiary = Color(0xFF4B1C00); // Alerts (e.g. Brake Pad Wear)
  static const Color accent = Color(0xFFF5A623);   // Dashboard accent
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);  
  
  // Variants
  static const Color outlineVariant = Color(0xFFC5C5D3);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(2.35619), // 135 degrees
  );
}
