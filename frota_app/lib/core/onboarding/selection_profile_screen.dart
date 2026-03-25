import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';

class SelectionProfileScreen extends StatelessWidget {
  const SelectionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Bem-vindo ao',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                'Fleet Premium',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Selecione seu perfil para acessar o comando da frota.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _ProfileCard(
                title: 'Administrador',
                subtitle: 'Controle total e auditoria',
                icon: Icons.admin_panel_settings_outlined,
                onTap: () => context.go(AppRoutes.adminDashboard),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileCard(
                title: 'Gestor',
                subtitle: 'Operação financeira e supervisão',
                icon: Icons.business_outlined,
                onTap: () => context.go('/gestor'),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfileCard(
                title: 'Motorista',
                subtitle: 'Vistorias e portal do condutor',
                icon: Icons.drive_eta_outlined,
                onTap: () => context.go(AppRoutes.driverHome),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          // Using Tonal Layering instead of Shadow as per Design System
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
