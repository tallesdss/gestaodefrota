import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';

class DriverSidebar extends StatelessWidget {
  final String activeRoute;

  const DriverSidebar({super.key, required this.activeRoute});

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
                  'Portal do Motorista',
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
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: activeRoute == AppRoutes.driverHome,
            onTap: () => context.go(AppRoutes.driverHome),
          ),
          _SidebarItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Financeiro',
            isActive: activeRoute.startsWith('/driver/financial'),
            onTap: () => context.go(AppRoutes.driverFinancialStatement),
          ),
          _SidebarItem(
            icon: Icons.task_outlined,
            label: 'Vistorias',
            isActive: activeRoute.startsWith('/driver/inspection'),
            onTap: () => context.go(AppRoutes.driverInspectionHistory),
          ),
          _SidebarItem(
            icon: Icons.notifications_none_outlined,
            label: 'Notificações',
            isActive: activeRoute == AppRoutes.driverNotifications,
            onTap: () => context.go(AppRoutes.driverNotifications),
          ),
          _SidebarItem(
            icon: Icons.support_agent_outlined,
            label: 'Suporte',
            isActive: activeRoute == AppRoutes.driverSupport,
            onTap: () => context.go(AppRoutes.driverSupport),
          ),
          _SidebarItem(
            icon: Icons.person_outline,
            label: 'Meu Perfil',
            isActive: activeRoute == AppRoutes.driverProfileDetail,
            onTap: () => context.go(AppRoutes.driverProfileDetail),
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
