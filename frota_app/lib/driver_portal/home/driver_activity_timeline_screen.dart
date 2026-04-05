import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';

class DriverActivityTimelineScreen extends StatelessWidget {
  const DriverActivityTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  _buildSectionTitle('Sexta, 29 Março'),
                  _buildTimelineItem(
                    'Manutenção Concluída',
                    'Troca de óleo e filtros realizada conforme agendamento.',
                    '14:30',
                    Icons.build_circle_outlined,
                    Colors.blue,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTimelineItem(
                    'Vistoria Aprovada',
                    'Seu check-in foi validado com sucesso pela central.',
                    '09:15',
                    Icons.verified_outlined,
                    Colors.green,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Quinta, 28 Março'),
                  _buildTimelineItem(
                    'Pagamento Confirmado',
                    'Recebemos o pagamento da semana 12/03 a 19/03.',
                    '18:45',
                    Icons.account_balance_wallet_outlined,
                    Colors.green,
                    isFirst: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTimelineItem(
                    'Documento Atualizado',
                    'Sua CNH Digital foi validada no sistema.',
                    '11:00',
                    Icons.assignment_ind_outlined,
                    AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Segunda, 25 Março'),
                  _buildTimelineItem(
                    'Check-out Realizado',
                    'Veículo entregue no pátio central.',
                    '19:20',
                    Icons.logout_outlined,
                    Colors.orange,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTimelineItem(
                    'Ocorrência Reportada',
                    'Pneu furado na Rodovia SP-280.',
                    '10:30',
                    Icons.report_problem_outlined,
                    AppColors.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.onSurface,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'HISTÓRICO COMPLETO',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          Text('Linha do Tempo', style: AppTextStyles.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color iconColor, {
    bool isFirst = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: AppIcon(icon: icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
