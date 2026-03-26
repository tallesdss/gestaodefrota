import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class DashboardCtaCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData? icon;
  final bool isSecondary;
  final VoidCallback onTap;

  const DashboardCtaCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
    this.icon,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isSecondary ? AppColors.surfaceContainerLow : AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        gradient: isSecondary ? null : AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: isSecondary ? AppColors.primary : AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSecondary ? AppColors.onSurfaceVariant : AppColors.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSecondary ? AppColors.surfaceContainerLowest : AppColors.onPrimary,
                  foregroundColor: isSecondary ? AppColors.primary : AppColors.primary,
                  minimumSize: const Size(180, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              if (icon != null)
                Icon(
                  icon,
                  color: isSecondary ? AppColors.onSurface.withValues(alpha: 0.05) : AppColors.onPrimary.withValues(alpha: 0.1),
                  size: 64,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
