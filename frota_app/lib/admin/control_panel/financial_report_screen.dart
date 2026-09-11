import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/financial_repository.dart';
import '../../models/financial_entry.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();
  List<FinancialEntry> _entries = [];
  bool _isLoading = true;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _financialRepo.getFinancialEntries();
      if (mounted) {
        setState(() {
          _entries = data.where((e) => e.date.month == _selectedMonth && e.date.year == _selectedYear).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paidEntries = _entries.where((e) => e.isPaid).toList();
    final totalIncome = paidEntries
        .where((e) => e.type == FinancialType.income)
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalExpense = paidEntries
        .where((e) => e.type == FinancialType.expense)
        .fold(0.0, (sum, e) => sum + e.amount);

    final netProfit = totalIncome - totalExpense;
    final margin = totalIncome > 0 ? (netProfit / totalIncome * 100) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'RELATÓRIO CONSOLIDADO',
              style: AppTextStyles.labelLarge.copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildMonthYearSelector(),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'LUCRO LÍQUIDO',
                            'R\$ ${netProfit.toStringAsFixed(2).replaceAll('.', ',')}',
                            'Margem ${margin.toStringAsFixed(1)}%',
                            netProfit >= 0 ? AppColors.success : AppColors.error,
                            Icons.trending_up,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildSummaryCard(
                            'TOTAL ENTRADAS (Pagas)',
                            'R\$ ${totalIncome.toStringAsFixed(2).replaceAll('.', ',')}',
                            '${paidEntries.where((e) => e.type == FinancialType.income).length} recebimentos',
                            AppColors.primary,
                            Icons.account_balance_wallet_outlined,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildSummaryCard(
                            'TOTAL SAÍDAS (Pagas)',
                            'R\$ ${totalExpense.toStringAsFixed(2).replaceAll('.', ',')}',
                            '${paidEntries.where((e) => e.type == FinancialType.expense).length} despesas',
                            AppColors.error,
                            Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Main Content Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildCategoryBreakdown()),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(flex: 1, child: _buildStatusBreakdown()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Recent Transactions Table
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Row(
      children: [
        DropdownButton<int>(
          value: _selectedMonth,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          items: List.generate(12, (index) => index + 1).map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text(month.toString().padLeft(2, '0')),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              _loadReportData();
            }
          },
        ),
        const Text('/', style: TextStyle(color: AppColors.onSurfaceVariant)),
        DropdownButton<int>(
          value: _selectedYear,
          dropdownColor: AppColors.surfaceContainerHigh,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          underline: const SizedBox(),
          items: [DateTime.now().year - 1, DateTime.now().year, DateTime.now().year + 1].map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              _loadReportData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String trend,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            trend,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final Map<String, double> byCategory = {};
    for (final e in _entries) {
      byCategory[e.category] = (byCategory[e.category] ?? 0.0) + e.amount;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DISTRIBUIÇÃO POR CATEGORIA',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (byCategory.isEmpty)
            const Text('Nenhum dado disponível.')
          else
            ...byCategory.entries.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.key, style: AppTextStyles.bodyMedium),
                    Text(
                      'R\$ ${item.value.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final paidCount = _entries.where((e) => e.isPaid).length;
    final pendingCount = _entries.where((e) => !e.isPaid).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATUS DE COBRANÇAS',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusRow('Liquidados (Pagos)', paidCount, AppColors.success),
          const SizedBox(height: 12),
          _buildStatusRow('Pendentes / Abertos', pendingCount, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodyMedium),
          ],
        ),
        Text(
          '$count',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÚLTIMOS LANÇAMENTOS CONSOLIDADOS',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_entries.isEmpty)
            const Text('Nenhum lançamento no histórico.')
          else
            ..._entries.take(5).map((e) {
              final isIncome = e.type == FinancialType.income;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? AppColors.success : AppColors.error,
                ),
                title: Text(e.description, style: AppTextStyles.titleMedium),
                subtitle: Text(
                  '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}',
                  style: AppTextStyles.bodySmall,
                ),
                trailing: Text(
                  '${isIncome ? "+" : "-"} R\$ ${e.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? AppColors.success : AppColors.error,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
