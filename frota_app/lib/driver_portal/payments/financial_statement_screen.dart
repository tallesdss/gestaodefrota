import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/financial_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../models/financial_entry.dart';
import 'widgets/receipt_upload_dialog.dart';

class FinancialStatementScreen extends StatefulWidget {
  const FinancialStatementScreen({super.key});

  @override
  State<FinancialStatementScreen> createState() =>
      _FinancialStatementScreenState();
}

class _FinancialStatementScreenState extends State<FinancialStatementScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();
  final AuthRepository _authRepo = AuthRepository();
  List<FinancialEntry> _entries = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    FinancialRepository.entriesChangedNotifier.addListener(_onFinancialUpdated);
    _loadEntries();
  }

  @override
  void dispose() {
    FinancialRepository.entriesChangedNotifier.removeListener(_onFinancialUpdated);
    super.dispose();
  }

  void _onFinancialUpdated() {
    if (mounted) {
      _loadEntries();
    }
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String uid = _authRepo.currentUserId ?? '';
      if (uid.isEmpty) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }
      List<FinancialEntry> data = await _financialRepo.getFinancialEntries(driverId: uid);
      if (mounted) {
        setState(() {
          _entries = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Não foi possível carregar o extrato financeiro.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _entries.where((e) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Atrasados') return !e.isPaid && e.isLate;
      if (_selectedFilter == 'Pendentes') return !e.isPaid;
      if (_selectedFilter == 'Pagos') return e.isPaid;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadEntries,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context)),
              SliverToBoxAdapter(child: _buildFinancialSummary()),
              SliverToBoxAdapter(child: _buildFilters()),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton(
                            onPressed: _loadEntries,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredEntries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Nenhum lançamento',
                    description: 'Não encontramos registros para o filtro "$_selectedFilter".',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTransactionCard(filteredEntries[index]),
                      childCount: filteredEntries.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          ),
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
            'HISTÓRICO FINANCEIRO',
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
    final pendingEntries = _entries.where((e) => !e.isPaid).toList();
    final lateEntries = pendingEntries.where((e) => e.isLate).toList();
    final totalPending = pendingEntries.fold(0.0, (sum, e) => sum + e.amount);
    final totalLate = lateEntries.fold(0.0, (sum, e) => sum + e.amount);
    final totalPaid = _entries.where((e) => e.isPaid).fold(0.0, (sum, e) => sum + e.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalLate > 0
              ? [const Color(0xFFC92A2A), const Color(0xFFE03131)]
              : [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (totalLate > 0 ? AppColors.error : AppColors.primary).withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
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
                totalLate > 0 ? '⚠️ ATENÇÃO: DÉBITOS EM ATRASO' : 'SALDO DEVEDOR ATUAL',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              if (totalLate > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lateEntries.length} ATRASADA(S)',
                    style: const TextStyle(
                      color: Color(0xFFC92A2A),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'R\$ ${totalPending.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const AppIcon(
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildSummaryItem(
                'QUITADO',
                'R\$ ${totalPaid.toStringAsFixed(2).replaceAll('.', ',')}',
                Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.xxl),
              _buildSummaryItem(
                'EM ATRASO',
                'R\$ ${totalLate.toStringAsFixed(2).replaceAll('.', ',')}',
                totalLate > 0 ? const Color(0xFFFFD8A8) : Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
          if (pendingEntries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res = await context.push(
                    AppRoutes.driverPixCheckout,
                    extra: pendingEntries,
                  );
                  if (res == true) _loadEntries();
                },
                icon: const Icon(Icons.flash_on, color: AppColors.primary),
                label: Text(
                  pendingEntries.length > 1
                      ? 'PAGAR TUDO DE UMA VEZ (R\$ ${totalPending.toStringAsFixed(2)})'
                      : 'PAGAR COM PIX (R\$ ${totalPending.toStringAsFixed(2)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
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
            color: color.withValues(alpha: 0.7),
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
    final filters = ['Todos', 'Atrasados', 'Pendentes', 'Pagos'];
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: filter == 'Atrasados' ? AppColors.error : AppColors.primary,
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
    final statusColor = entry.isPaid
        ? Colors.green
        : (entry.isLate ? AppColors.error : AppColors.secondary);

    final String statusText = entry.isPaid
        ? 'PAGO'
        : (entry.isUnderReview
            ? 'EM ANÁLISE'
            : (entry.isLate ? 'ATRASADO' : 'PENDENTE'));

    final dateStr =
        '${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}/${entry.date.year}';

    final daysOverdue = entry.isLate && !entry.isPaid
        ? DateTime.now().difference(entry.date).inDays
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: entry.isLate && !entry.isPaid
              ? AppColors.error.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (entry.isPaid
                          ? Colors.green
                          : (entry.isLate ? AppColors.error : AppColors.primary))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  entry.isPaid
                      ? Icons.check_circle_outline
                      : (entry.isLate ? Icons.warning_amber_rounded : Icons.payments_outlined),
                  color: entry.isPaid
                      ? Colors.green
                      : (entry.isLate ? AppColors.error : AppColors.primary),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(height: 2),
                    Text(
                      'Vencimento: $dateStr ${daysOverdue > 0 ? "($daysOverdue dias em atraso)" : ""}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: entry.isLate && !entry.isPaid
                            ? AppColors.error
                            : AppColors.onSurfaceVariant,
                        fontWeight: entry.isLate && !entry.isPaid
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'R\$ ${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: entry.isLate && !entry.isPaid
                          ? AppColors.error
                          : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (entry.isUnderReview ? Colors.blue : statusColor)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: entry.isUnderReview ? Colors.blue : statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!entry.isPaid) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await context.push(
                        AppRoutes.driverPixCheckout,
                        extra: entry,
                      );
                      if (res == true) _loadEntries();
                    },
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('Pagar com PIX'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: entry.isLate ? AppColors.error : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ReceiptUploadDialog.show(
                        context,
                        entry: entry,
                        onUploaded: _loadEntries,
                      );
                    },
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: Text(entry.isUnderReview ? 'Trocar Comprovante' : 'Anexar Comprovante'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
