import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

class SuperAdminScaffold extends StatelessWidget {
  final Widget child;

  const SuperAdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Row(
        children: [
          // Sidebar
          const SuperAdminSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                const SuperAdminHeader(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SuperAdminSidebar extends StatelessWidget {
  const SuperAdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF050A1A),
        border: Border(
          right: BorderSide(
            color: Colors.white.withAlpha(10),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FLEET',
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'COMMAND MASTER',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          // Menu Items
          _SidebarItem(
            icon: Icons.dashboard_customize_outlined,
            label: 'Dashboard Global',
            isSelected: location == AppRoutes.superAdminDashboard,
            onTap: () => context.go(AppRoutes.superAdminDashboard),
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            label: 'Gestão de Empresas',
            isSelected: location == AppRoutes.superAdminCompanies,
            onTap: () => context.go(AppRoutes.superAdminCompanies),
          ),
          _SidebarItem(
            icon: Icons.layers_outlined,
            label: 'Planos e Tarifas',
            isSelected: location == AppRoutes.superAdminPlans,
            onTap: () => context.go(AppRoutes.superAdminPlans),
          ),
          const Spacer(),
          _SidebarItem(
            icon: Icons.logout_rounded,
            label: 'Sair do Sistema',
            isSelected: false,
            onTap: () => context.go(AppRoutes.login),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.accent : Colors.white60,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import '../core/super_admin_manager.dart';

class SuperAdminHeader extends StatelessWidget {
  const SuperAdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: SuperAdminManager.impersonatedCompanyName,
      builder: (context, companyName, _) {
        final isImpersonating = companyName != null;

        return Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: isImpersonating
                ? Colors.orange.withAlpha(20)
                : const Color(0xFF020617),
            border: Border(
              bottom: BorderSide(
                color: isImpersonating
                    ? Colors.orange.withAlpha(50)
                    : Colors.white.withAlpha(10),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              if (isImpersonating)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.privacy_tip_outlined,
                          size: 16, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'SHADOW MODE: $companyName',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                isImpersonating
                    ? 'Visualização da Empresa'
                    : 'Visão Geral do Ecossistema',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (isImpersonating)
                TextButton.icon(
                  onPressed: () => SuperAdminManager.stopImpersonation(),
                  icon: const Icon(Icons.exit_to_app, color: Colors.orange),
                  label: Text(
                    'Sair da Sessão',
                    style: GoogleFonts.inter(color: Colors.orange),
                  ),
                ),
              if (isImpersonating) const SizedBox(width: 24),
              // Profile
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Super Administrador',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Operação Master',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
