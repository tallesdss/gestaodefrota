import 'package:flutter/material.dart';

class AppColors {
  // Primary - Autoridade e Comando
  static const Color primary = Color(0xFF00236F);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary - Funcionalidade e Calma
  static const Color secondary = Color(0xFF425E91);
  static const Color secondaryContainer = Color(0xFFD7E2FF);
  static const Color onSecondaryContainer = Color(0xFF001A40);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  // Surfaces - Filosofia de Camadas Tonais
  static const Color surface = Color(0xFFF8F9FF); // Base canvas
  static const Color surfaceContainerLow = Color(0xFFEFF4FF); // Logical groups
  static const Color surfaceContainerLowest = Color(
    0xFFFFFFFF,
  ); // Interaction/Cards
  static const Color surfaceContainerHigh = Color(
    0xFFDCE9FF,
  ); // Fly-outs/Tooltips
  static const Color surfaceVariant = Color(0xFFE1E2EC); // Glassmorphism base

  // Content
  static const Color onSurface = Color(0xFF0B1C30); // Pure black is avoided
  static const Color onSurfaceVariant = Color(0xFF44474E); // Typo label color

  // Functional - Triggers e Alertas
  static const Color tertiary = Color(
    0xFF4B1C00,
  ); // Alerts (e.g. Brake Pad Wear)
  static const Color tertiaryContainer = Color(
    0xFFFFDBCA,
  ); // Light Orange for badges
  static const Color accent = Color(0xFFF5A623); // Dashboard accent
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFB1F0AC);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningContainer = Color(0xFFFFF1CC);

  // Variants
  static const Color outlineVariant = Color(0xFFC5C5D3);

  // Ambient Shadows
  static Color get ambientShadow => onSurface.withValues(alpha: 0.06);

  // Gradients - The "Glass & Gradient" Rule
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
}
