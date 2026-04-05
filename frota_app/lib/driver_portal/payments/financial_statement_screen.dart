import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';
import '../../models/financial_entry.dart';

class FinancialStatementScreen extends StatefulWidget {
  const FinancialStatementScreen({super.key});

  @override
  State<FinancialStatementScreen> createState() =>
      _FinancialStatementScreenState();
}

class _FinancialStatementScreenState extends State<FinancialStatementScreen> {
  final List<FinancialEntry> mockEntries = [
    FinancialEntry(
      id: '1',
      type: FinancialType.expense,
      category: 'Aluguel',
      amount: 550.00,
      date: DateTime.now().add(const Duration(days: 2)),
      description: 'Semana 12/03 a 19/03',
      isPaid: false,
      isLate: false,
    ),
    FinancialEntry(
      id: '2',
      type: FinancialType.expense,
      category: 'Multa',
      amount: 195.23,
      date: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Excesso de velocidade - Av. Brasil',
      isPaid: false,
      isLate: true,
    ),
    FinancialEntry(
      id: '3',
      type: FinancialType.expense,
      category: 'Aluguel',
      amount: 550.00,
      date: DateTime.now().subtract(const Duration(days: 7)),
      description: 'Semana 05/03 a 12/03',
      isPaid: true,
      isLate: false,
    ),
    FinancialEntry(
      id: '4',
      type: FinancialType.income,
      category: 'Crédito',
      amount: 50.00,
      date: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Bônus Indicação',
      isPaid: true,
      isLate: false,
    ),
    FinancialEntry(
      id: '5',
      type: FinancialType.expense,
      category: 'Aluguel',
      amount: 550.00,
      date: DateTime.now().subtract(const Duration(days: 14)),
      description: 'Semana 26/02 a 05/03',
      isPaid: true,
      isLate: false,
    ),
  ];

  String selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final filteredEntries = mockEntries.where((e) {
      if (selectedFilter == 'Todos') return true;
      if (selectedFilter == 'Pendentes') return !e.isPaid;
      if (selectedFilter == 'Pagos') return e.isPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(context),
            _buildFinancialSummary(),
            _buildFilters(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  return _buildTransactionCard(filteredEntries[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'EXTRATO',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.push(AppRoutes.driverReceipts),
            icon: const Icon(Icons.receipt_long_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    double totalPending = mockEntries
        .where((e) => !e.isPaid)
        .fold(
          0,
          (sum, e) =>
              sum + (e.type == FinancialType.expense ? e.amount : -e.amount),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO DEVEDOR ATUAL',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ ${totalPending.toStringAsFixed(2).replaceAll('.', ',')}',
                style: AppTextStyles.displayMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const AppIcon(
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _buildSummaryItem(
                'PAGO',
                'R\$ 1.650,00',
                Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: AppSpacing.xxl),
              _buildSummaryItem(
                'CRÉDITOS',
                'R\$ 50,00',
                Colors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final filters = ['Todos', 'Pendentes', 'Pagos'];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedFilter = filter;
                  });
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(FinancialEntry entry) {
    final isExpense = entry.type == FinancialType.expense;
    final statusColor = entry.isPaid
        ? Colors.green
        : (entry.isLate ? AppColors.error : AppColors.secondary);

    return InkWell(
      onTap: entry.isPaid
          ? null
          : () => context.push(AppRoutes.driverPixCheckout, extra: entry),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isExpense ? AppColors.error : Colors.green).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isExpense ? Icons.arrow_outward : Icons.arrow_downward,
                color: isExpense ? AppColors.error : Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    entry.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? "-" : "+"} R\$ ${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isExpense ? AppColors.onSurface : Colors.green,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.isPaid
                        ? 'PAGO'
                        : (entry.isLate ? 'ATRASADO' : 'PENDENTE'),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
