import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'RELATÓRIO CONSOLIDADO',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),
            const SizedBox(height: AppSpacing.xl),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'LUCRO LÍQUIDO',
                    r'R$ 32.730,00',
                    '+12.5%',
                    AppColors.success,
                    Icons.trending_up,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'TOTAL ENTRADAS',
                    r'R$ 45.230,00',
                    '+8.2%',
                    AppColors.primary,
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'TOTAL SAÍDAS',
                    r'R$ 12.500,00',
                    '-2.1%',
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
                // Revenue Breakdown Chart (Simulated)
                Expanded(flex: 2, child: _buildChartSection()),
                const SizedBox(width: AppSpacing.xl),
                // Expense Breakdown
                Expanded(flex: 1, child: _buildExpenseBreakdown()),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Recent Transactions Table
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Março 2024',
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String change,
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
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 24,
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
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FLUXO MENSAL',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Jan', 0.6, AppColors.outlineVariant),
                _buildBar('Fev', 0.8, AppColors.outlineVariant),
                _buildBar('Mar', 1.0, AppColors.primary),
                _buildBar('Abr', 0.7, AppColors.outlineVariant),
                _buildBar('Mai', 0.5, AppColors.outlineVariant),
                _buildBar('Jun', 0.9, AppColors.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 160 * heightFactor,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildExpenseBreakdown() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESPESAS POR TIPO',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const Expanded(
                flex: 70,
                child: Divider(thickness: 8, color: Colors.purple),
              ),
              const SizedBox(width: 4),
              const Expanded(
                flex: 20,
                child: Divider(thickness: 8, color: AppColors.success),
              ),
              const SizedBox(width: 4),
              const Expanded(
                flex: 10,
                child: Divider(thickness: 8, color: AppColors.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildExpenseItem('Salários', '70%', Colors.purple),
          _buildExpenseItem('Manutenção', '20%', AppColors.success),
          _buildExpenseItem('Outros', '10%', AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRANSAÇÕES RECENTES',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceContainerLow),
          ),
          child: Column(
            children: [
              _buildTransactionRow(
                'Entrada de Caixa',
                'Mar 28',
                '+ R\$ 2.500',
                AppColors.success,
              ),
              const Divider(height: 1),
              _buildTransactionRow(
                'Pagamento Salário - João',
                'Mar 25',
                '- R\$ 3.200',
                AppColors.error,
              ),
              const Divider(height: 1),
              _buildTransactionRow(
                'Manutenção Veículo ABC-1234',
                'Mar 22',
                '- R\$ 450',
                AppColors.error,
              ),
              const Divider(height: 1),
              _buildTransactionRow(
                'Aporte Capital',
                'Mar 15',
                '+ R\$ 10.000',
                AppColors.success,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(
    String label,
    String date,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
