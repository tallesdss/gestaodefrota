import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppNotifier {
  /// Mostra uma notificação flutuante (Toast/SnackBar)
  static void show({
    required BuildContext context,
    required String message,
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Calcula a cor base
    Color backgroundColor = AppColors.surfaceContainerHigh;
    Color iconColor = AppColors.primary;
    IconData icon = Icons.info_outline_rounded;

    if (isError) {
      backgroundColor = AppColors.errorContainer;
      iconColor = AppColors.error;
      icon = Icons.error_outline_rounded;
    } else if (isSuccess) {
      backgroundColor = AppColors.successContainer;
      iconColor = AppColors.success;
      icon = Icons.check_circle_outline_rounded;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        content: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.06),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: iconColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: () {
                    scaffoldMessenger.hideCurrentSnackBar();
                    onAction();
                  },
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context: context, message: message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context: context, message: message, isError: true);
  }
}
