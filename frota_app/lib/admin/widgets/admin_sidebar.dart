import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';

class AdminSidebar extends StatelessWidget {
  final String activeRoute;

  const AdminSidebar({
    super.key,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.surfaceContainerLowest,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xxl),
          // Logo Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Architect Fleet',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '65 Veículos Ativos',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // Navigation Items
          _SidebarItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isActive: activeRoute == AppRoutes.adminDashboard,
            onTap: () => context.go(AppRoutes.adminDashboard),
          ),
          _SidebarItem(
            icon: Icons.directions_car_outlined,
            label: 'Veículos',
            isActive: activeRoute.startsWith(AppRoutes.adminVehicleList),
            onTap: () => context.go(AppRoutes.adminVehicleList),
          ),
          _SidebarItem(
            icon: Icons.person_search_outlined,
            label: 'Motoristas',
            isActive: activeRoute.startsWith(AppRoutes.adminDriverList),
            onTap: () => context.go(AppRoutes.adminDriverList),
          ),
          _SidebarItem(
            icon: Icons.fact_check_outlined,
            label: 'Auditoria',
            isActive: activeRoute == AppRoutes.adminRegistrationAudit,
            onTap: () => context.go(AppRoutes.adminRegistrationAudit),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Financeiro',
            isActive: activeRoute.startsWith(AppRoutes.adminFinancialList),
            onTap: () => context.go(AppRoutes.adminFinancialList),
          ),
          _SidebarItem(
            icon: Icons.task_outlined,
            label: 'Vistorias',
            isActive: activeRoute.startsWith(AppRoutes.adminInspectionAudit),
            onTap: () => context.go(AppRoutes.adminInspectionAudit),
          ),
          _SidebarItem(
            icon: Icons.settings_applications_outlined,
            label: 'Painel de Controle',
            isActive: activeRoute == AppRoutes.adminControlPanel,
            onTap: () => context.go(AppRoutes.adminControlPanel),
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: isActive
                  ? const Border(
                      left: BorderSide(
                        color: AppColors.primary,
                        width: 4,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.xl),
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
