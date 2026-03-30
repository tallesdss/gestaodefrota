import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ManagerSalariesScreen extends StatelessWidget {
  const ManagerSalariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final managers = [
      {'name': 'Carlos Oliveira', 'role': 'Gestor Operacional', 'salary': r'R$ 5.500,00'},
      {'name': 'Ana Paula', 'role': 'Gestora Financeira', 'salary': r'R$ 6.200,00'},
      {'name': 'Roberto Silva', 'role': 'Supervisor de Frota', 'salary': r'R$ 4.800,00'},
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Salários dos Gestores',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        leading: BackButton(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuração de Remuneração',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            // Salary Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL FOLHA MENSAL',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        r'R$ 16.500,00',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Managers List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: managers.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final manager = managers[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ambientShadow,
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerLow,
                        child: Text(
                          manager['name']![0],
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              manager['name']!,
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              manager['role']!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            manager['salary']!,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'editar',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
