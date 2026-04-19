import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/company.dart';
import '../core/super_admin_manager.dart';
import '../core/company_manager.dart';
import '../core/saas_financial_manager.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';
import 'company_form_screen.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyId;

  const CompanyDetailScreen({super.key, required this.companyId});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final _companyManager = CompanyManager();
  late Company _company;

  @override
  void initState() {
    super.initState();
    _companyManager.addListener(_onStateChanged);
    _loadCompany();
  }

  @override
  void dispose() {
    _companyManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() => _loadCompany());
    }
  }

  void _loadCompany() {
    _company = _companyManager.companies.firstWhere(
      (c) => c.id == widget.companyId,
      orElse: () => _companyManager.companies.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildGeneralInfoCard(),
                    const SizedBox(height: 24),
                    _buildUsageStatsCard(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildPlanCard(),
                    const SizedBox(height: 24),
                    _buildActionsCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _company.name,
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                _StatusBadge(status: _company.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${_company.id} • Cadastrada em ${_company.createdAt.day}/${_company.createdAt.month}/${_company.createdAt.year}',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () {
            SuperAdminManager.impersonate(_company.id, _company.name);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Acessando como ${_company.name}')),
            );
            context.push(AppRoutes.adminDashboard);
          },
          icon: const Icon(Icons.login),
          label: const Text('Acessar Painel'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard() {
    return _InfoSection(
      title: 'Informações Gerais',
      icon: Icons.business,
      children: [
        _buildInfoRow('CNPJ', _company.cnpj),
        _buildInfoRow('Responsável', _company.ownerName),
        _buildInfoRow('E-mail', _company.email),
        _buildInfoRow('Telefone', '(11) 98765-4321'), // Mock
        _buildInfoRow('Endereço', 'Av. das Nações, 1234 - São Paulo/SP'), // Mock
      ],
    );
  }

  Widget _buildUsageStatsCard() {
    final progress = _company.currentVehicles / _company.vehicleLimit;
    
    return _InfoSection(
      title: 'Uso de Recursos',
      icon: Icons.analytics_outlined,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Veículos', style: GoogleFonts.inter(color: Colors.white70)),
            Text('${_company.currentVehicles} / ${_company.vehicleLimit}', 
              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: progress > 0.9 ? Colors.redAccent : AppColors.accent,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoRow('Usuários Ativos', '12'),
        _buildInfoRow('Motoristas Cadastrados', '45'),
      ],
    );
  }

  Widget _buildPlanCard() {
    return _InfoSection(
      title: 'Assinatura',
      icon: Icons.card_membership,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plano ${_company.planName}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Próxima cobrança: 15/05/2026',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => _showChangePlanDialog(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Alterar Plano', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return _InfoSection(
      title: 'Ações Administrativas',
      icon: Icons.settings_outlined,
      children: [
        _buildActionButton(
          label: 'Editar dados',
          icon: Icons.edit_outlined,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CompanyFormScreen(company: _company)),
          ),
        ),
        _buildActionButton(
          label: _company.status == CompanyStatus.active ? 'Suspender Empresa' : 'Ativar Empresa',
          icon: Icons.pause_circle_outline,
          color: _company.status == CompanyStatus.active ? Colors.orangeAccent : Colors.greenAccent,
          onTap: () {
            final newStatus = _company.status == CompanyStatus.active ? CompanyStatus.inactive : CompanyStatus.active;
            _companyManager.changeStatus(_company.id, newStatus);
            AuditManager().logAction(
              action: newStatus == CompanyStatus.active ? AuditAction.impersonationEnd : AuditAction.companySuspended,
              target: _company.name,
              details: 'Status alterado para ${newStatus.name}',
            );
          },
        ),
        _buildActionButton(
          label: 'Bloquear Acesso',
          icon: Icons.block_outlined,
          color: Colors.redAccent,
          onTap: () {
            _companyManager.changeStatus(_company.id, CompanyStatus.blocked);
             AuditManager().logAction(
              action: AuditAction.companyBlocked,
              target: _company.name,
              details: 'Acesso bloqueado administrativamente',
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.inter(color: color, fontSize: 14)),
              const Spacer(),
              const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 14)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showChangePlanDialog(BuildContext context) {
    final plans = SaaSFinancialManager().plans;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text('Alterar Plano - ${_company.name}', style: GoogleFonts.manrope(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: plans.map((p) => ListTile(
            title: Text(p.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text('Até ${p.maxVehicles} veículos', style: const TextStyle(color: Colors.white54)),
            trailing: _company.planName == p.name ? const Icon(Icons.check, color: AppColors.accent) : null,
            onTap: () {
              _companyManager.changePlan(_company.id, p.name, p.maxVehicles);
              AuditManager().logAction(
                action: AuditAction.planUpdated,
                target: _company.name,
                details: 'Plano alterado para ${p.name}',
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Plano alterado para ${p.name}')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CompanyStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case CompanyStatus.active:
        color = Colors.greenAccent;
        label = 'Ativa';
        break;
      case CompanyStatus.inactive:
        color = Colors.white54;
        label = 'Inativa';
        break;
      case CompanyStatus.blocked:
        color = Colors.redAccent;
        label = 'Bloqueada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
