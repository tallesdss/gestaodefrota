import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

class PlansManagementScreen extends StatelessWidget {
  const PlansManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Gestão de Planos', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Níveis de Serviço', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('Configure os limites e preços para cada categoria de cliente.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 24),
            _buildPlanListItem(
              context,
              'Básico',
              r'R$ 199,00',
              '10 Veículos • 5 Admins',
              AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildPlanListItem(
              context,
              'Profissional',
              r'R$ 499,00',
              '50 Veículos • 20 Admins • Módulo Oficina',
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildPlanListItem(
              context,
              'Enterprise',
              r'R$ 999,00',
              'Ilimitado • Suporte 24h • White-label',
              const Color(0xFF1A237E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanListItem(BuildContext context, String name, String price, String features, Color color) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.headlineSmall),
                      Text(features, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text(price, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Editar Limites'),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Ver Assinantes',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
