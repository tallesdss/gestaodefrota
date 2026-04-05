import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppFilterItem {
  final String label;
  final String value;
  final bool isSelected;

  AppFilterItem({
    required this.label,
    required this.value,
    this.isSelected = false,
  });
}

class AppFilterBar extends StatelessWidget {
  final List<AppFilterItem> filters;
  final Function(String) onFilterSelected;
  final List<Widget>? actions;

  const AppFilterBar({
    super.key,
    required this.filters,
    required this.onFilterSelected,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ...filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        filter.label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: filter.isSelected
                              ? AppColors.onPrimary
                              : AppColors.onSurface,
                          fontWeight: filter.isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      selected: filter.isSelected,
                      onSelected: (bool selected) {
                        onFilterSelected(filter.value);
                      },
                      selectedColor: AppColors.primary,
                      checkmarkColor: AppColors.onPrimary,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: filter.isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          999,
                        ), // full pill radius
                      ),
                    ),
                  );
                }),
                if (actions != null) ...[
                  const VerticalDivider(width: 24, thickness: 1),
                  ...actions!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
