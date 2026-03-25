import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../admin/dashboard/widgets/kpi_card.dart';
import '../../admin/dashboard/widgets/delay_list_item.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      children: [
        // Page Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel Operacional',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Supervisão de Fluxo de Caixa e Equipe • Hoje',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Confirmar Recebimento'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // KPI Row - Focused for Manager
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              KpiCard(
                title: 'PENDÊNCIAS',
                value: 'R\$ 12.450',
                subtitle: 'Contas a Receber (Atrasadas)',
                icon: Icons.error_outline,
                accentColor: Colors.redAccent,
              ),
              SizedBox(width: AppSpacing.md),
              KpiCard(
                title: 'RECEBIDO HOJE',
                value: 'R\$ 2.890',
                subtitle: 'Baixas confirmadas hoje',
                icon: Icons.trending_up,
                accentColor: Colors.green,
              ),
              SizedBox(width: AppSpacing.md),
              KpiCard(
                title: 'CONTRATOS',
                value: '12',
                subtitle: 'Vencendo nos próximos 7 dias',
                icon: Icons.description_outlined,
                accentColor: Colors.orange,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Main Content Area
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Recent Delays Section
            Expanded(
              flex: 2,
              child: _ManagerAtrasosSection(),
            ),
            const SizedBox(width: AppSpacing.xl),
            // Right: Important Alerts Section
            Expanded(
              flex: 1,
              child: _ManagerAlertsSection(),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _ManagerAtrasosSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestão de Inadimplência',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          Text(
            'Motoristas com parcelas em atraso',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayListItem(
            imageUrl: 'https://img.freepik.com/fotos-premium/carro-branco-elegante-sobre-fundo-branco-isolado-em-fundo-branco-com-reflexo-sob-o-carro-generative-ai_438099-22341.jpg',
            model: 'Volkswagen Virtus 2023',
            plate: 'ABC-1234',
            client: 'João da Silva',
            value: 'R\$ 1.250,00',
            delay: '3 dias de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://img.freepik.com/fotos-premium/carro-sedan-preto-compacto-carro-sedan-preto-compacto-em-fundo-branco_1082121-654.jpg',
            model: 'Chevrolet Onix Plus',
            plate: 'XYZ-9876',
            client: 'Maria Oliveira',
            value: 'R\$ 890,00',
            delay: '2 dias de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://img.freepik.com/premium-photo/compact-red-car_244243-228.jpg',
            model: 'Fiat Cronos 2024',
            plate: 'QWE-4567',
            client: 'Pedro Henrique',
            value: 'R\$ 1.100,00',
            delay: '1 dia de atraso',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ManagerAlertsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas da Equipe',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AlertItem(
            icon: Icons.contact_page_outlined,
            title: 'CNH Vencendo',
            subtitle: 'Marcos Souza (5 dias)',
            color: Colors.orange,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AlertItem(
            icon: Icons.car_repair_outlined,
            title: 'Revisão Pendente',
            subtitle: 'Prisma ABC-8899',
            color: Colors.blueAccent,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AlertItem(
            icon: Icons.history_outlined,
            title: 'Check-out Atrasado',
            subtitle: 'Onix XYZ-9090',
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
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
        ],
      ),
    );
  }
}
