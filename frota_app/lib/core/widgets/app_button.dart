import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _getTextColor(isDisabled),
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(icon, size: 20, color: _getTextColor(isDisabled)),
          ),
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: _getTextColor(isDisabled),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 48,
        decoration: _getBoxDecoration(isDisabled),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(
              6,
            ), // md radius per design system
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: buttonContent,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration(bool isDisabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(6),
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6),
        );
      case AppButtonVariant.ghost:
        return const BoxDecoration(color: Colors.transparent);
    }
  }

  Color _getTextColor(bool isDisabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.onPrimary;
      case AppButtonVariant.secondary:
        return AppColors.onSecondaryContainer;
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppColors.primary;
    }
  }
}
