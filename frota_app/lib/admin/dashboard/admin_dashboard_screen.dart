import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'widgets/kpi_card.dart';
import 'widgets/delay_list_item.dart';
import 'widgets/fleet_status_chart.dart';
import 'widgets/dashboard_cta_card.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      children: [
        // Page Title & Action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visão Geral da Frota',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Relatório atualizado em tempo real • 24 Out 2023',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Nova Vistoria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size(180, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // KPI Row
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              KpiCard(
                title: 'Capacidade',
                value: '65',
                subtitle: 'Total de Veículos',
                icon: Icons.directions_car_outlined,
                accentColor: Colors.indigo,
              ),
              SizedBox(width: AppSpacing.md),
              KpiCard(
                title: 'Ocupação',
                value: '58',
                subtitle: 'Veículos Alugados',
                icon: Icons.vpn_key_outlined,
                accentColor: Colors.blueAccent,
                hasProgressBar: true,
                progress: 0.89,
              ),
              SizedBox(width: AppSpacing.md),
              KpiCard(
                title: 'Financeiro',
                value: 'R\$ 42.000',
                subtitle: 'Receita do Mês',
                icon: Icons.account_balance_wallet_outlined,
                accentColor: Colors.green,
              ),
              SizedBox(width: AppSpacing.md),
              KpiCard(
                title: 'Atenção',
                value: 'R\$ 3.500',
                subtitle: 'Inadimplência',
                icon: Icons.error_outline,
                accentColor: Colors.redAccent,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Middle Section: Status Chart + Recent Delays
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Fleet Status (320px fixed)
            const SizedBox(
              width: 320,
              child: FleetStatusChart(),
            ),
            const SizedBox(width: AppSpacing.xl),
            // Right: Recent Delays
            Expanded(
              child: _RecentDelaysSection(),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Bottom Section: CTA Cards
        Row(
          children: [
            Expanded(
              child: DashboardCtaCard(
                title: 'Monitoramento Ativo',
                description: 'Acompanhe a localização e o comportamento de condução em tempo real.',
                buttonText: 'Abrir Mapa da Frota',
                icon: Icons.map_outlined,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: DashboardCtaCard(
                title: 'Relatórios Automáticos',
                description: 'Gere o fechamento mensal e notas fiscais com apenas um clique.',
                buttonText: 'Configurar Agendamento',
                icon: Icons.bar_chart_outlined,
                isSecondary: true,
                onTap: () {},
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

class _RecentDelaysSection extends StatelessWidget {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Atrasos Recentes',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontSize: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Últimos 5 registros com pendência financeira',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Ver Financeiro Completo',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DelayListItem(
            imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=200&auto=format&fit=crop',
            model: 'Volkswagen Virtus 2023',
            plate: 'ABC-1D23',
            client: 'João Silva',
            value: 'R\$ 1.250,00',
            delay: '3 dias de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://images.unsplash.com/photo-1550355291-bbee04a92027?q=80&w=200&auto=format&fit=crop',
            model: 'Chevrolet Onix Turbo',
            plate: 'XYZ-9A87',
            client: 'Maria Oliveira',
            value: 'R\$ 890,00',
            delay: '2 dias de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=200&auto=format&fit=crop',
            model: 'Fiat Cronos Precision',
            plate: 'FGH-5J44',
            client: 'Pedro Santos',
            value: 'R\$ 1.100,00',
            delay: '1 dia de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?q=80&w=200&auto=format&fit=crop',
            model: 'Renault Kwid Zen',
            plate: 'QWE-2R34',
            client: 'Carla Dias',
            value: 'R\$ 560,00',
            delay: '5 dias de atraso',
            onTap: () {},
          ),
          DelayListItem(
            imageUrl: 'https://images.unsplash.com/photo-1542362567-b055034193b4?q=80&w=200&auto=format&fit=crop',
            model: 'Toyota Corolla XEi',
            plate: 'TYU-0P12',
            client: 'Roberto Lima',
            value: 'R\$ 2.450,00',
            delay: '2 dias de atraso',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
