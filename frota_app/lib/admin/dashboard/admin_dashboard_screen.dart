import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/routes/app_routes.dart';
import 'widgets/dashboard_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Header with profile
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, Administrador',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'João Silva',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.notifications_outlined, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
          
          // Dashboard Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // KPI Section
                _SectionTitle(title: 'Visão Geral da Frota'),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.5,
                  children: const [
                    StatCard(
                      title: 'Ativos Totais',
                      value: '42',
                      icon: Icons.directions_car_outlined,
                    ),
                    StatCard(
                      title: 'Locados',
                      value: '35',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.primary,
                    ),
                    StatCard(
                      title: 'Disponíveis',
                      value: '05',
                      icon: Icons.event_available_outlined,
                      iconColor: Colors.green,
                    ),
                    StatCard(
                      title: 'Manutenção',
                      value: '02',
                      icon: Icons.build_outlined,
                      iconColor: AppColors.tertiary,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Chart Section
                const DashboardChart(),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Critical Alerts Section
                _SectionTitle(title: 'Alertas Prioritários'),
                const SizedBox(height: AppSpacing.md),
                const AlertCard(
                  title: 'Documentação Vencendo',
                  subtitle: 'Veículo ABC-1234: IPVA em 3 dias',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.tertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                const AlertCard(
                  title: 'Manutenção Preventiva',
                  subtitle: 'Corolla GHI-9012: Troca de Óleo Pendente',
                  icon: Icons.build_circle_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                const AlertCard(
                  title: 'Pendência Financeira',
                  subtitle: 'Motorista Maria Santos: Mensalidade Atrasada',
                  icon: Icons.money_off_csred_outlined,
                  color: AppColors.error,
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Navigation to management screens
                _SectionTitle(title: 'Gestão de Ativos'),
                const SizedBox(height: AppSpacing.md),
                _ManagementMenu(),
                
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(
            fontSize: 20,
            color: AppColors.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Ver Tudo',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class AlertCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AlertCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
        ],
      ),
    );
  }
}

class _ManagementMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MenuItem(
          title: 'Veículos',
          count: '42 ativos',
          icon: Icons.directions_car_filled_outlined,
          onTap: () => context.push(AppRoutes.adminVehicleList),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuItem(
          title: 'Motoristas',
          count: '38 cadastrados',
          icon: Icons.people_outline,
          onTap: () => context.push(AppRoutes.adminDriverList),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuItem(
          title: 'Contratos',
          count: '35 vigentes',
          icon: Icons.article_outlined,
          onTap: () {},
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuItem({
    required this.title,
    required this.count,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(AppSpacing.sm),
      tileColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(count, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outlineVariant),
    );
  }
}
