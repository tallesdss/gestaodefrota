import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageButton(
          icon: Icons.chevron_left_rounded,
          isDisabled: currentPage <= 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: 8),
        ..._buildPageNumbers(),
        const SizedBox(width: 8),
        _PageButton(
          icon: Icons.chevron_right_rounded,
          isDisabled: currentPage >= totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> widgets = [];

    // Simple logic for page numbers: 1 ... cur-1 cur cur+1 ... last
    for (int i = 1; i <= totalPages; i++) {
      if (totalPages <= 5 ||
          i == 1 ||
          i == totalPages ||
          (i >= currentPage - 1 && i <= currentPage + 1)) {
        widgets.add(
          _PageNumberItem(
            page: i,
            isActive: i == currentPage,
            onTap: () => onPageChanged(i),
          ),
        );
      } else if (widgets.last is! _PageEllipsis) {
        widgets.add(const _PageEllipsis());
      }
    }

    return widgets;
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDisabled
                ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _PageNumberItem extends StatelessWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumberItem({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              page.toString(),
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageEllipsis extends StatelessWidget {
  const _PageEllipsis();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
