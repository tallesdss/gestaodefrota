import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class ExpenseCategoriesScreen extends StatelessWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final expenseCategories = [
      {'name': 'Manutenção Corretiva', 'icon': Icons.build_outlined, 'color': AppColors.error},
      {'name': 'Abastecimento', 'icon': Icons.local_gas_station_outlined, 'color': AppColors.primary},
      {'name': 'Limpeza / Estética', 'icon': Icons.waves_outlined, 'color': Colors.blue},
      {'name': 'Documentação / IPVA', 'icon': Icons.description_outlined, 'color': Colors.grey},
    ];
    
    final dismissalCategories = [
      {'name': 'Peças Desgastadas', 'icon': Icons.delete_outline, 'color': Colors.brown},
      {'name': 'Óleo Usado', 'icon': Icons.opacity_outlined, 'color': Colors.black},
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Categorias Financeiras',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        leading: BackButton(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategorySection(
              context, 
              title: 'Categorias de Despesas', 
              categories: expenseCategories,
              onAdd: () {},
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _buildCategorySection(
              context, 
              title: 'Categorias de Dispensas', 
              categories: dismissalCategories,
              onAdd: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> categories,
    required VoidCallback onAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
              label: Text(
                'Adicionar',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final category = categories[index];
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (category['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: category['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      category['name'] as String,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
