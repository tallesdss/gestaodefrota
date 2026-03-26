import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/financial_entry.dart';
import '../../core/utils/report_generator.dart';

class FinancialListScreen extends StatefulWidget {
  const FinancialListScreen({super.key});

  @override
  State<FinancialListScreen> createState() => _FinancialListScreenState();
}

class _FinancialListScreenState extends State<FinancialListScreen> {
  final MockRepository _repository = MockRepository();
  List<FinancialEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFinancials();
  }

  Future<void> _fetchFinancials() async {
    final list = await _repository.getFinancialEntries();
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Actions
          _buildHeaderActions(),
          const SizedBox(height: AppSpacing.xxl),

          // Filter Bar
          _buildFilterBar(),
          const SizedBox(height: AppSpacing.xxl),

          // Bento Grid: KPIs & Ranking
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildKpiGrid(),
              ),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(
                flex: 1,
                child: _buildProfitRanking(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Transactions Table
          _buildTransactionsTable(),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestão Financeira',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Controle de receitas, despesas e rentabilidade da frota.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            _buildSmallButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Exportar PDF',
              color: AppColors.surfaceContainerLow,
              textColor: AppColors.onSurface,
              onPressed: () => ReportGenerator.generateFinancialReport(_entries),
            ),
            const SizedBox(width: AppSpacing.md),
            _buildSmallButton(
              icon: Icons.download_outlined,
              label: 'Planilha Excel',
              color: AppColors.primary,
              textColor: AppColors.onPrimary,
              onPressed: () {},
              useGradient: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool useGradient = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: useGradient ? null : color,
        gradient: useGradient ? AppColors.primaryGradient : null,
        borderRadius: BorderRadius.circular(8),
        boxShadow: useGradient ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _buildFilterItem('PERÍODO', 'Selecione a data', isDate: true)),
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: _buildFilterItem('VEÍCULO', 'Todos os Veículos')),
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: _buildFilterItem('MOTORISTA', 'Todos os Motoristas')),
          const SizedBox(width: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(String label, String value, {bool isDate = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: AppTextStyles.bodyMedium),
              Icon(isDate ? Icons.calendar_month_outlined : Icons.keyboard_arrow_down, size: 18, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Receita Total',
                'R\$ 145.280,00',
                '+12% vs mês anterior',
                AppColors.primary,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _buildKpiCard(
                'Despesas',
                'R\$ 42.150,00',
                '-4% vs mês anterior',
                AppColors.error,
                Icons.trending_down,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _buildKpiCard(
                'Lucro Líquido',
                'R\$ 103.130,00',
                'Margem de 71%',
                Colors.orange[800]!,
                Icons.payments_outlined,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String label, String value, String trend, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        border: Border(top: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                trend,
                style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitRanking() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Rentabilidade',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const Icon(Icons.emoji_events_outlined, size: 20, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 20),
          _buildRankingItem('01', 'Toyota Corolla', 'ABC-1234', 'R\$ 8.420', AppColors.primary),
          const SizedBox(height: 16),
          _buildRankingItem('02', 'Jeep Compass', 'GHI-5544', 'R\$ 7.150', AppColors.primary),
          const SizedBox(height: 16),
          _buildRankingItem('03', 'Honda Civic', 'LMN-4422', 'R\$ 6.980', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildRankingItem(String rank, String name, String plate, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank == '01' ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                rank,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rank == '01' ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(plate, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
        Text(
          '+ $value',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildTransactionsTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhamento de Fluxo',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Ver tudo',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceContainerLow),
          _buildTableHeader(),
          const Divider(height: 1, color: AppColors.surfaceContainerLow),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5, // Show 5 as per HTML
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceContainerLow),
            itemBuilder: (context, index) {
              if (index >= _entries.length) return const SizedBox.shrink();
              return _buildTransactionRow(_entries[index]);
            },
          ),
          const Divider(height: 1, color: AppColors.surfaceContainerLow),
          _buildTableFooter(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: AppColors.surfaceContainerLow.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildHeaderText('DATA')),
          Expanded(flex: 2, child: _buildHeaderText('CATEGORIA')),
          Expanded(flex: 2, child: _buildHeaderText('VEÍCULO / MOTORISTA')),
          Expanded(flex: 1, child: _buildHeaderText('VALOR')),
          Expanded(flex: 1, child: _buildHeaderText('STATUS')),
          const SizedBox(width: 48), // Action space
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTransactionRow(FinancialEntry entry) {
    final bool isIncome = entry.type == FinancialType.income;
    final String sign = isIncome ? 'R\$ ' : '- R\$ ';
    final Color amountColor = isIncome ? AppColors.primary : AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(_formatDate(entry.date), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(
                  entry.category.toLowerCase().contains('manutenção') ? Icons.build_outlined : entry.category.toLowerCase().contains('multa') ? Icons.report_problem_outlined : Icons.add_circle_outline,
                  size: 18,
                  color: amountColor,
                ),
                const SizedBox(width: 8),
                Text(
                  entry.description,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: amountColor),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Corolla ABC-1234', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)), // Mocked vehicle
                Text('Ricardo Silva', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)), // Mocked driver
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$sign${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w900, color: amountColor),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: entry.isPaid ? AppColors.primaryContainer.withOpacity(0.1) : AppColors.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                entry.isPaid ? 'PAGO' : 'PENDENTE',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: entry.isPaid ? AppColors.primary : AppColors.error,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildTableFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: AppColors.surfaceContainerLow.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Exibindo 5 de ${_entries.length} transações no período',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              _buildPageButton(Icons.chevron_left, enabled: false),
              const SizedBox(width: 8),
              _buildPageButton(null, text: '1', active: true),
              const SizedBox(width: 8),
              _buildPageButton(null, text: '2'),
              const SizedBox(width: 8),
              _buildPageButton(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(IconData? icon, {String? text, bool active = false, bool enabled = true}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceContainerLow),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 16, color: enabled ? (active ? Colors.white : AppColors.onSurfaceVariant) : AppColors.onSurfaceVariant.withOpacity(0.3))
          : Text(
              text!,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

