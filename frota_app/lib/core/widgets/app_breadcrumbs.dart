import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.label, this.onTap});
}

class AppBreadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const AppBreadcrumbs({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.asMap().entries.map((entry) {
        final int index = entry.key;
        final BreadcrumbItem item = entry.value;
        final bool isLast = index == items.length - 1;

        return Row(
          children: [
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  item.label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isLast ? AppColors.onSurface : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
