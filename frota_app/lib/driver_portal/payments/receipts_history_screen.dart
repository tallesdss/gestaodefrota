import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/repositories/financial_repository.dart';
import '../../core/repositories/auth_repository.dart';
import '../../models/financial_entry.dart';

class ReceiptsHistoryScreen extends StatefulWidget {
  const ReceiptsHistoryScreen({super.key});

  @override
  State<ReceiptsHistoryScreen> createState() => _ReceiptsHistoryScreenState();
}

class _ReceiptsHistoryScreenState extends State<ReceiptsHistoryScreen> {
  final FinancialRepository _financialRepo = FinancialRepository();
  final AuthRepository _authRepo = AuthRepository();
  List<FinancialEntry> _receipts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    setState(() => _isLoading = true);
    try {
      final uid = _authRepo.currentUserId;
      final data = uid != null
          ? await _financialRepo.getFinancialEntries(driverId: uid, status: 'pago')
          : <FinancialEntry>[];
      if (mounted) {
        setState(() {
          _receipts = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _receipts.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.receipt_outlined,
                          title: 'Nenhum recibo emitido',
                          description: 'Seus comprovantes de pagamento aparecerão aqui.',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadReceipts,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.md,
                            ),
                            itemCount: _receipts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              final receipt = _receipts[index];
                              final dateStr =
                                  '${receipt.date.day.toString().padLeft(2, '0')}/${receipt.date.month.toString().padLeft(2, '0')}/${receipt.date.year}';
                              return Container(
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
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const AppIcon(
                                        icon: Icons.receipt_long_outlined,
                                        color: AppColors.primary,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            receipt.description.isNotEmpty
                                                ? receipt.description
                                                : 'Comprovante de Pagamento',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            dateStr,
                                            style: AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${receipt.amount.toStringAsFixed(2)}',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'CENTRAL DE RECIBOS',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
