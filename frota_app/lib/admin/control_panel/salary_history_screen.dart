import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'package:intl/intl.dart';

class SalaryHistoryScreen extends StatelessWidget {
  const SalaryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock History Data
    final payments = [
      {
        'manager': 'Carlos Oliveira',
        'amount': r'R$ 2.750,00',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'type': 'Adiantamento',
        'status': 'Pago',
      },
      {
        'manager': 'Ana Paula',
        'amount': r'R$ 6.200,00',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'type': 'Salário Integral',
        'status': 'Pago',
      },
      {
        'manager': 'Roberto Silva',
        'amount': r'R$ 2.400,00',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'type': 'Adiantamento',
        'status': 'Pago',
      },
      {
        'manager': 'Carlos Oliveira',
        'amount': r'R$ 2.750,00',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'type': 'Saldo Salarial',
        'status': 'Pago',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Histórico de Pagamentos',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        leading: const BackButton(color: AppColors.primary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final date = payment['date'] as DateTime;
          final formattedDate = DateFormat('dd/MM/yyyy').format(date);

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['manager'] as String,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${payment['type']} • $formattedDate',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  payment['amount'] as String,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
