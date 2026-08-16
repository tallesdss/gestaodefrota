import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'widgets/kpi_card.dart';
import 'widgets/delay_list_item.dart';
import 'widgets/fleet_status_chart.dart';
import 'widgets/dashboard_cta_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/module_nav_card.dart';
import '../../core/repositories/financial_repository.dart';
import '../../models/financial_entry.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();

  Map<String, dynamic> _kpis = {};
  List<FinancialEntry> _recentDelays = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final kpis = await _financialRepo.getDashboardKpis();
      final delays = await _financialRepo.getFinancialEntries(status: 'atrasado');

      if (mounted) {
        setState(() {
          _kpis = kpis;
          _recentDelays = delays;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final bool isGestor = location.startsWith('/gestor');
    final String prefix = isGestor ? '/gestor' : '/admin';

    final totalVehicles = _kpis['total_veiculos'] ?? 65;
    final rentedVehicles = _kpis['veiculos_alugados'] ?? 58;
    final double occupancyRate = _kpis['taxa_ocupacao_percentual'] != null
        ? ((_kpis['taxa_ocupacao_percentual'] as num).toDouble() / 100).clamp(0.0, 1.0)
        : 0.89;
    final double revenueMonth = (_kpis['receita_mes_atual'] ?? 42000.0).toDouble();
    final double delinquencyTotal = (_kpis['total_inadimplencia'] ?? 3500.0).toDouble();

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_isLoading) const SizedBox(height: AppSpacing.md),
          // Page Title & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGestor ? 'Painel Operacional' : 'Visão Geral da Frota',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Dados sincronizados em tempo real com o Supabase',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _loadDashboardData,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Atualizar Dados',
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => context.push('$prefix/inspections/new'),
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
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // KPI Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                KpiCard(
                  title: 'Capacidade',
                  value: '$totalVehicles',
                  subtitle: 'Total de Veículos',
                  icon: Icons.directions_car_outlined,
                  accentColor: Colors.indigo,
                ),
                const SizedBox(width: AppSpacing.md),
                KpiCard(
                  title: 'Ocupação',
                  value: '$rentedVehicles',
                  subtitle: 'Veículos Alugados',
                  icon: Icons.vpn_key_outlined,
                  accentColor: Colors.blueAccent,
                  hasProgressBar: true,
                  progress: occupancyRate,
                ),
                const SizedBox(width: AppSpacing.md),
                KpiCard(
                  title: 'Financeiro',
                  value: 'R\$ ${revenueMonth.toStringAsFixed(0)}',
                  subtitle: 'Receita do Mês',
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: Colors.green,
                ),
                const SizedBox(width: AppSpacing.md),
                KpiCard(
                  title: 'Atenção',
                  value: 'R\$ ${delinquencyTotal.toStringAsFixed(0)}',
                  subtitle: 'Inadimplência',
                  icon: Icons.error_outline,
                  accentColor: Colors.redAccent,
                  onTap: () => context.go('$prefix/delinquency'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quick Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Veículo',
                onTap: () => context.push('$prefix/vehicles/form'),
              ),
              QuickActionButton(
                icon: Icons.person_add_outlined,
                label: 'Add Motorista',
                onTap: () => context.push('$prefix/drivers/form'),
              ),
              QuickActionButton(
                icon: Icons.fact_check_outlined,
                label: 'Auditoria',
                onTap: () => context.go('$prefix/audit'),
              ),
              QuickActionButton(
                icon: Icons.payments_outlined,
                label: 'Novo Lançamento',
                onTap: () => context.go('$prefix/financial'),
              ),
              QuickActionButton(
                icon: Icons.notifications_outlined,
                label: 'Notificações',
                onTap: () => context.go('$prefix/notifications'),
              ),
              QuickActionButton(
                icon: Icons.tune_outlined,
                label: 'Ajustes',
                onTap: () => context.go('$prefix/settings'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Module Navigation Grid (Bento Style)
          Text(
            'Módulos do Sistema',
            style: AppTextStyles.headlineSmall.copyWith(
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.6,
            children: [
              ModuleNavCard(
                title: 'Gestão de Veículos',
                description: 'Controle de frota, documentação e status.',
                icon: Icons.directions_car_outlined,
                onTap: () => context.go('$prefix/vehicles'),
                color: Colors.indigo,
              ),
              ModuleNavCard(
                title: 'Financeiro',
                description: 'Ganhos, gastos e relatórios mensais.',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () => context.go('$prefix/financial'),
                color: Colors.green,
              ),
              ModuleNavCard(
                title: 'Motoristas',
                description: 'Perfis, CNH e histórico de aluguéis.',
                icon: Icons.person_search_outlined,
                onTap: () => context.go('$prefix/drivers'),
                color: Colors.blueAccent,
              ),
              ModuleNavCard(
                title: 'Auditoria de Cadastro',
                description: 'Validar documentos e perfis pendentes.',
                icon: Icons.fact_check_outlined,
                onTap: () => context.go('$prefix/audit'),
                color: Colors.orange,
              ),
              ModuleNavCard(
                title: 'Vistorias & Check-ins',
                description: 'Histórico de estados de entrada e saída.',
                icon: Icons.task_outlined,
                onTap: () => context.go('$prefix/inspections'),
                color: Colors.purple,
              ),
              ModuleNavCard(
                title: 'Plano de Manutenção',
                description: 'Previsão de revisões e alertas de peças.',
                icon: Icons.handyman_outlined,
                onTap: () => context.go('$prefix/maintenance'),
                color: Colors.redAccent,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Middle Section: Status Chart + Recent Delays
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Fleet Status (320px fixed)
              const SizedBox(width: 320, child: FleetStatusChart()),
              const SizedBox(width: AppSpacing.xl),
              // Right: Recent Delays
              Expanded(
                child: _RecentDelaysSection(
                  delays: _recentDelays,
                  prefix: prefix,
                ),
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
                  description:
                      'Acompanhe a localização e o comportamento de condução em tempo real.',
                  buttonText: 'Abrir Mapa da Frota',
                  icon: Icons.map_outlined,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: DashboardCtaCard(
                  title: 'Relatórios Automáticos',
                  description:
                      'Gere o fechamento mensal e notas fiscais com apenas um clique.',
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
      ),
    );
  }
}

class _RecentDelaysSection extends StatelessWidget {
  final List<FinancialEntry> delays;
  final String prefix;

  const _RecentDelaysSection({required this.delays, required this.prefix});

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
                    'Últimos registros com pendência financeira',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('$prefix/financial'),
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
          if (delays.isEmpty)
            DelayListItem(
              imageUrl:
                  'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=200&auto=format&fit=crop',
              model: 'Volkswagen Virtus 2023',
              plate: 'ABC-1D23',
              client: 'João Silva',
              value: 'R\$ 1.250,00',
              delay: '3 dias de atraso',
              onTap: () => context.go('$prefix/delinquency'),
            )
          else
            ...delays.take(5).map((d) => DelayListItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=200&auto=format&fit=crop',
                  model: d.description,
                  plate: d.vehicleId ?? 'FROTA',
                  client: d.category,
                  value: 'R\$ ${d.amount.toStringAsFixed(2)}',
                  delay: 'Vencimento: ${d.date.day}/${d.date.month}',
                  onTap: () => context.go('$prefix/financial'),
                )),
        ],
      ),
    );
  }
}
