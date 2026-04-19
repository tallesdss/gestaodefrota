import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/billing_invoice.dart';
import '../core/saas_financial_manager.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';
import 'package:intl/intl.dart';

class BillingManagementScreen extends StatefulWidget {
  const BillingManagementScreen({super.key});

  @override
  State<BillingManagementScreen> createState() => _BillingManagementScreenState();
}

class _BillingManagementScreenState extends State<BillingManagementScreen> {
  final _financialManager = SaaSFinancialManager();
  InvoiceStatus? _statusFilter;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _financialManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _financialManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _applyFilter(InvoiceStatus? status) {
    setState(() {
      _statusFilter = status;
    });
  }

  List<BillingInvoice> get _filteredInvoices {
    final all = _financialManager.invoices;
    if (_statusFilter == null) return all;
    return all.where((i) => i.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildKpiRow(),
          const SizedBox(height: 32),
          _buildFilters(),
          const SizedBox(height: 16),
          Expanded(child: _buildInvoiceList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Controle Financeiro Master',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          'Gestão de faturamento global e MRR por empresa.',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        _KpiCard(
          label: 'MRR Total (Estimado)',
          value: _currencyFormat.format(_financialManager.totalMRR),
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.accent,
        ),
        const SizedBox(width: 24),
        _KpiCard(
          label: 'Inadimplência',
          value: _currencyFormat.format(_financialManager.overdueAmount),
          icon: Icons.warning_amber_rounded,
          color: Colors.redAccent,
          trend: '${((_financialManager.overdueAmount / _financialManager.totalMRR) * 100).toStringAsFixed(1)}% do total',
        ),
        const SizedBox(width: 24),
        _KpiCard(
          label: 'Faturas Pagas (Mês)',
          value: _financialManager.invoices.where((i) => i.status == InvoiceStatus.paid).length.toString(),
          icon: Icons.check_circle_outline,
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'Todas',
          isSelected: _statusFilter == null,
          onTap: () => _applyFilter(null),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Pagas',
          isSelected: _statusFilter == InvoiceStatus.paid,
          onTap: () => _applyFilter(InvoiceStatus.paid),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Pendentes',
          isSelected: _statusFilter == InvoiceStatus.pending,
          onTap: () => _applyFilter(InvoiceStatus.pending),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Em Atraso',
          isSelected: _statusFilter == InvoiceStatus.overdue,
          onTap: () => _applyFilter(InvoiceStatus.overdue),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Exportar Relatório'),
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildInvoiceList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.02)),
            columnSpacing: 24,
            columns: [
              DataColumn(label: _TableHead('Empresa')),
              DataColumn(label: _TableHead('Plano')),
              DataColumn(label: _TableHead('Vencimento')),
              DataColumn(label: _TableHead('Valor')),
              DataColumn(label: _TableHead('Status')),
              DataColumn(label: _TableHead('Ações')),
            ],
            rows: _filteredInvoices.map((invoice) {
              return DataRow(cells: [
                DataCell(Text(invoice.companyName, style: const TextStyle(color: Colors.white70))),
                DataCell(Text(invoice.planName, style: const TextStyle(color: Colors.white54))),
                DataCell(Text(DateFormat('dd/MM/yyyy').format(invoice.dueDate), style: const TextStyle(color: Colors.white54))),
                DataCell(Text(_currencyFormat.format(invoice.amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                DataCell(_StatusBadge(invoice: invoice)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      onPressed: () {
                        // Diálogo simulando visualização da fatura
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A1A),
                            title: const Text('Fatura Detalhada', style: TextStyle(color: Colors.white)),
                            content: Text(
                              'Exibindo detalhes da fatura ${invoice.id} para ${invoice.companyName}.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Fechar'),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: 'Ver Fatura',
                    ),
                    if (invoice.status != InvoiceStatus.paid)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.greenAccent),
                        onPressed: () {
                          _financialManager.confirmPayment(invoice.id);
                          AuditManager().logAction(
                            action: AuditAction.paymentConfirmed,
                            target: invoice.companyName,
                            details: 'Fatura de R\$ ${invoice.amount.toStringAsFixed(2)} confirmada manualmente.',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pagamento confirmado com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        tooltip: 'Confirmar Pagamento',
                      ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}


class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const _KpiCard({required this.label, required this.value, required this.icon, required this.color, this.trend});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (trend != null)
                   Text(trend!, style: GoogleFonts.inter(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isSelected ? AppColors.accent : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TableHead extends StatelessWidget {
  final String label;
  const _TableHead(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BillingInvoice invoice;
  const _StatusBadge({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final color = invoice.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        invoice.statusLabel,
        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
