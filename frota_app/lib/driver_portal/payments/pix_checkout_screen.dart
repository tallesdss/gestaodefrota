import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../models/financial_entry.dart';

class PixCheckoutScreen extends StatelessWidget {
  final FinancialEntry entry;

  const PixCheckoutScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildValueCard(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildQrCodeSection(context),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildInstructions(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildUploadSection(),
                    const SizedBox(height: AppSpacing.xxl),
                    AppButton(
                      label: 'CONFIRMAR PAGAMENTO',
                      onPressed: () => _showConfirmation(context),
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
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
            icon: const Icon(Icons.close),
            color: AppColors.onSurface,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'PAGAMENTO PIX',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard() {
    return Column(
      children: [
        Text(
          'VALOR DO PAGAMENTO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'R\$ ${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
          style: AppTextStyles.displayMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          entry.description,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 160, color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'QR CODE DINÂMICO',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          InkWell(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: '00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-4266141740005204000053039865802BR5913GESTAO_FROTA6009SAO_PAULO62070503***6304E2CA'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código Pix copiado!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.copy, color: AppColors.primary, size: 18),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'COPIAR CÓDIGO PIX',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INSTRUÇÕES',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInstructionRow('1', 'Abra o app do seu banco e escolha a opção PIX.'),
        const SizedBox(height: AppSpacing.sm),
        _buildInstructionRow('2', 'Escaneie o QR Code ou selecione "Pix Copia e Cola".'),
        const SizedBox(height: AppSpacing.sm),
        _buildInstructionRow('3', 'Após o pagamento, anexe o comprovante abaixo.'),
      ],
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.onSurface.withValues(alpha: 0.05),
          style: BorderStyle.none, // We use color shifts instead of borders as per DS
        ),
      ),
      child: Column(
        children: [
          const AppIcon(icon: Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ANEXAR COMPROVANTE',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'JPEG, PNG ou PDF (Máx. 5MB)',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('ENVIAR COMPROVANTE?', style: AppTextStyles.headlineSmall),
        content: Text(
          'Deseja enviar este comprovante para análise? O saldo será baixado em até 24h úteis.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCELAR', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to summary
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comprovante enviado com sucesso!')),
              );
            },
            child: Text('CONFIRMAR', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
