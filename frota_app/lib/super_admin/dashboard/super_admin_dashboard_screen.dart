import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      children: [
        // Welcome & Date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comando Global Master',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visão panorâmica de todo o ecossistema SaaS em tempo real.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Text(
                    '18 Abril, 2026',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // KPI Row
        Row(
          children: [
            Expanded(
              child: _MasterKpiCard(
                label: 'Empresas Ativas',
                value: '42',
                trend: '+3 este mês',
                icon: Icons.business_outlined,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _MasterKpiCard(
                label: 'Frota Total Global',
                value: '1.280',
                trend: '+84 veículos',
                icon: Icons.directions_car_outlined,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _MasterKpiCard(
                label: 'Receita Mensal (SaaS)',
                value: r'R$ 158.400',
                trend: '+12% vs mês ant.',
                icon: Icons.payments_outlined,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _MasterKpiCard(
                label: 'Usuários Ativos',
                value: '5.642',
                trend: 'Tempo real',
                icon: Icons.people_outline,
                color: AppColors.accent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Main Content Area
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Recent Companies & Alerts
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _SectionHeader(
                    title: 'Empresas Recém Cadastradas',
                    actionLabel: 'Ver Todas',
                    onAction: () => context.push(AppRoutes.superAdminCompanies),
                  ),
                  const SizedBox(height: 16),
                  _CompanyListItem(
                    name: 'Transportes TransLog Ltda',
                    owner: 'Ricardo Almeida',
                    plan: 'Enterprise',
                    date: 'Hoje, 14:30',
                    veiculos: 150,
                  ),
                  _CompanyListItem(
                    name: 'Frota Rápida Delivery',
                    owner: 'Mariana Costa',
                    plan: 'Pro',
                    date: 'Hoje, 09:15',
                    veiculos: 45,
                  ),
                  _CompanyListItem(
                    name: 'Express Encomendas',
                    owner: 'Carlos Eduardo',
                    plan: 'Basic',
                    date: 'Ontem',
                    veiculos: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right Column: System Health & Alerts
            Expanded(
              child: Column(
                children: [
                  _SectionHeader(
                    title: 'Status do Ecossistema',
                  ),
                  const SizedBox(height: 16),
                  _HealthCard(
                    label: 'API Gateways',
                    status: 'Operacional',
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  _HealthCard(
                    label: 'Banco de Dados Master',
                    status: '98% Performance',
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  _HealthCard(
                    label: 'Storage (Documentos)',
                    status: 'Normal',
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Alertas Críticos'),
                  const SizedBox(height: 16),
                  _AlertCard(
                    title: 'Inadimplência Elevada',
                    description: '4 empresas com faturas vencidas há +10 dias.',
                    level: 'High',
                  ),
                  const SizedBox(height: 12),
                  _AlertCard(
                    title: 'Migração de Tenant',
                    description: 'Empresa "LogEx" solicitou upgrade de base.',
                    level: 'Medium',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MasterKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  const _MasterKpiCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }
}

class _CompanyListItem extends StatelessWidget {
  final String name;
  final String owner;
  final String plan;
  final String date;
  final int veiculos;

  const _CompanyListItem({
    required this.name,
    required this.owner,
    required this.plan,
    required this.date,
    required this.veiculos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business_outlined, color: Colors.white70),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Responsável: $owner',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$veiculos veículos',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _HealthCard(
      {required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(status,
                  style: GoogleFonts.inter(
                      color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final String title;
  final String description;
  final String level;

  const _AlertCard(
      {required this.title, required this.description, required this.level});

  @override
  Widget build(BuildContext context) {
    final color = level == 'High' ? Colors.redAccent : Colors.orangeAccent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.inter(
                      color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description,
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}
