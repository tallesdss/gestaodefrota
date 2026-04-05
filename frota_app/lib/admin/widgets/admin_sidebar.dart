import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';

class AdminSidebar extends StatelessWidget {
  final String activeRoute;

  const AdminSidebar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final bool isGestor = activeRoute.startsWith('/gestor');
    final String prefix = isGestor ? '/gestor' : '/admin';

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
                  isGestor ? 'Perfil Gestor' : 'Perfil Administrador',
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
            isActive: activeRoute == '$prefix/dashboard',
            onTap: () => context.go('$prefix/dashboard'),
          ),
          _SidebarItem(
            icon: Icons.directions_car_outlined,
            label: 'Veículos',
            isActive: activeRoute.startsWith('$prefix/vehicles'),
            onTap: () => context.go('$prefix/vehicles'),
          ),
          _SidebarItem(
            icon: Icons.person_search_outlined,
            label: 'Motoristas',
            isActive: activeRoute.startsWith('$prefix/drivers'),
            onTap: () => context.go('$prefix/drivers'),
          ),
          _SidebarItem(
            icon: Icons.fact_check_outlined,
            label: 'Auditoria',
            isActive: activeRoute.startsWith('$prefix/audit'),
            onTap: () => context.go('$prefix/audit'),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Financeiro',
            isActive: activeRoute.startsWith('$prefix/financial'),
            onTap: () => context.go('$prefix/financial'),
          ),
          _SidebarItem(
            icon: Icons.task_outlined,
            label: 'Vistorias',
            isActive: activeRoute.startsWith('$prefix/inspections'),
            onTap: () => context.go('$prefix/inspections'),
          ),
          _SidebarItem(
            icon: Icons.build_circle_outlined,
            label: 'Oficina',
            isActive: activeRoute.startsWith('$prefix/workshops'),
            onTap: () => context.go('$prefix/workshops'),
          ),
          if (!isGestor)
            _SidebarItem(
              icon: Icons.settings_applications_outlined,
              label: 'Painel de Controle',
              isActive: activeRoute.startsWith('/admin/control-panel'),
              onTap: () => context.go(AppRoutes.adminControlPanel),
            ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout,
            label: 'Sair do Sistema',
            isActive: false,
            onTap: () => context.go(AppRoutes.login),
            color: Colors.redAccent,
          ),
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
  final Color? color;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.color,
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
                      left: BorderSide(color: AppColors.primary, width: 4),
                    )
                  : null,
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.xl),
                Icon(
                  icon,
                  color:
                      color ??
                      (isActive
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color:
                        color ??
                        (isActive
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant),
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
