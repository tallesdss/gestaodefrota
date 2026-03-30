import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';

class ControlPanelScreen extends StatelessWidget {
  const ControlPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel de Controle',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Gerencie gestores, finanças e configurações do sistema.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                // Quick Action
                GestureDetector(
                  onTap: () => context.push(AppRoutes.adminCashFlowForm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ambientShadow,
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SALDO EM CAIXA',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              r'R$ 45.230,00',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Quick Actions Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionButton(
                    context,
                    title: 'Gestores',
                    icon: Icons.badge_outlined,
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.adminManagerList),
                  ),
                  _buildQuickActionButton(
                    context,
                    title: 'Salários',
                    icon: Icons.payments_outlined,
                    color: Colors.purple,
                    onTap: () => context.push(AppRoutes.adminManagerSalaries),
                  ),
                  _buildQuickActionButton(
                    context,
                    title: 'Categorias',
                    icon: Icons.category_outlined,
                    color: AppColors.success,
                    onTap: () => context.push(AppRoutes.adminExpenseCategories),
                  ),
                  _buildQuickActionButton(
                    context,
                    title: 'Relatórios',
                    icon: Icons.analytics_outlined,
                    color: Colors.orange,
                    onTap: () => context.push(AppRoutes.adminFinancialReport),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Future Features Section
            Text(
              'Configurações do Sistema (Futuro)',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildFutureIcon(Icons.notifications_none_outlined, 'Alertas'),
                  const SizedBox(width: AppSpacing.xxl),
                  _buildFutureIcon(Icons.history_outlined, 'Logs'),
                  const SizedBox(width: AppSpacing.xxl),
                  _buildFutureIcon(Icons.cloud_upload_outlined, 'Backup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFutureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          size: 28,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
