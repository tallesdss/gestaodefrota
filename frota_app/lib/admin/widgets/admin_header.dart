import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  hintText: 'Buscar veículo, placa ou motorista...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Pending Maintenance Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.report_problem_outlined,
                  size: 16,
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '3 Manutenções Pendentes',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Icon Buttons
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // User Section
          const _UserSection(),
        ],
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  const _UserSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Ricardo Almeida',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'GESTOR DE FROTA',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
        ),
      ],
    );
  }
}
