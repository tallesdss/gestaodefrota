import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';
import '../../models/financial_entry.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xl),
            _buildVehicleStatusCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildFinancialSummaryCard(context),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.lg),
            _buildActivityTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BEM-VINDO,',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              'João da Silva',
              style: AppTextStyles.headlineMedium,
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.driverNotifications),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const AppIcon(
              icon: Icons.notifications_active_outlined,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VEÍCULO ATIVO',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Volkswagen Gol',
                    style: AppTextStyles.headlineSmall,
                  ),
                  Text(
                    'PLACA: ABC-1234',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const AppIcon(
                icon: Icons.directions_car_outlined,
                color: AppColors.primary,
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'DOCUMENTO EM DIA',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildVehicleInfoItem('Odômetro', '45.230 km'),
              const SizedBox(width: AppSpacing.xl),
              _buildVehicleInfoItem('Próx. Manut.', 'em 4.770 km'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FINANCEIRO PRÓXIMO VENCIMENTO',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ 550,00',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Vence em 2 dias',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'PAGAR COM PIX',
            onPressed: () => context.push(
              AppRoutes.driverPixCheckout,
              extra: FinancialEntry(
                id: '1',
                type: FinancialType.expense,
                category: 'Aluguel',
                amount: 550.00,
                date: DateTime.now().add(const Duration(days: 2)),
                description: 'Semana 12/03 a 19/03',
                isPaid: false,
              ),
            ),
            variant: AppButtonVariant.secondary,
            icon: Icons.qr_code_scanner_outlined,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Text(
          'AÇÕES RÁPIDAS',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Vistoria',
                onPressed: () => _showInspectionSelection(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.document_scanner_outlined,
                label: 'Documentos',
                onPressed: () => context.push(AppRoutes.driverDocuments),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildActionButton(
                icon: Icons.report_problem_outlined,
                label: 'Ocorrência',
                onPressed: () => context.push(AppRoutes.driverOccurrenceReport),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.support_agent_outlined,
                label: 'Suporte',
                onPressed: () => context.push(AppRoutes.driverSupport),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
             const Spacer(flex: 2), // Keeps the same button size
          ],
        ),
      ],
    );
  }

  void _showInspectionSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl + MediaQuery.of(modalContext).padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIPO DE VISTORIA',
                style: AppTextStyles.labelMedium.copyWith(
                  letterSpacing: 2,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSelectionItem(
                modalContext,
                Icons.login_outlined,
                'Check-in (Retirada)',
                'Iniciar jornada com o veículo',
                () {
                  context.push(AppRoutes.driverInspectionCheckIn);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSelectionItem(
                modalContext,
                Icons.logout_outlined,
                'Check-out (Entrega)',
                'Finalizar jornada e devolver veículo',
                () {
                  context.push(AppRoutes.driverInspectionCheckOut);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSelectionItem(
                modalContext,
                Icons.history_outlined,
                'Histórico de Vistorias',
                'Ver todas as inspeções anteriores',
                () {
                  context.push(AppRoutes.driverInspectionHistory);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            AppIcon(icon: icon, color: AppColors.primary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LINHA DO TEMPO',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.driverActivityTimeline),
              child: Text(
                'VER TUDO',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTimelineItem(
          'Manutenção Concluída',
          'Troca de óleo e filtros realizada.',
          'Ontem, 14:30',
          Icons.build_circle_outlined,
          Colors.blue,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTimelineItem(
          'Vistoria Aprovada',
          'Seu check-in foi validado com sucesso.',
          '28 Mar, 09:15',
          Icons.verified_outlined,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            time,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
