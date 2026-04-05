import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_dialogs.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest),
      child: Row(
        children: [
          // Global Search Trigger
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showGlobalSearch(context),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Buscar veículo, placa ou motorista...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // Maintenance Status Badge
          InkWell(
            onTap: () => context.go(AppRoutes.adminMaintenanceList),
            borderRadius: BorderRadius.circular(999),
            child: Container(
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
          ),
          const SizedBox(width: AppSpacing.xl),
          // Notifications
          IconButton(
            onPressed: () => context.go(AppRoutes.adminNotifications),
            tooltip: 'Notificações',
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          // Settings
          IconButton(
            onPressed: () => context.go(AppRoutes.adminSettings),
            tooltip: 'Configurações',
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // User Profile Trigger
          const _UserSection(),
        ],
      ),
    );
  }

  void _showGlobalSearch(BuildContext context) {
    AppDialogs.showModal(
      context: context,
      title: 'Busca Global',
      content: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Digite para buscar...',
              prefixIcon: const Icon(Icons.search),
              fillColor: AppColors.surfaceContainerLow,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Center(child: Text('Resultados dinâmicos aparecerão aqui')),
          const SizedBox(height: 100), // Placeholder space
        ],
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  const _UserSection();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.adminProfile),
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
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
        ),
      ),
    );
  }
}
