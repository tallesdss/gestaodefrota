import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum BadgeType { 
  active, 
  warning, 
  error, 
  neutral 
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
  });

  Color _getBgColor() {
    switch (type) {
      case BadgeType.active: return AppColors.primary.withAlpha(25);
      case BadgeType.warning: return AppColors.accent.withAlpha(25);
      case BadgeType.error: return AppColors.error.withAlpha(25);
      case BadgeType.neutral: return AppColors.outlineVariant.withAlpha(51);
    }
  }

  Color _getTextColor() {
    switch (type) {
      case BadgeType.active: return AppColors.primary;
      case BadgeType.warning: return Colors.orange[800]!;
      case BadgeType.error: return AppColors.error;
      case BadgeType.neutral: return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.labelMedium.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
