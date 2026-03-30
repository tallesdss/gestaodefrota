import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_button.dart';

class DriverSupportScreen extends StatelessWidget {
  const DriverSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _buildEmergencySection(),
              const SizedBox(height: AppSpacing.xxl),
              _buildFaqSection(),
              const SizedBox(height: AppSpacing.xxl),
              _buildDirectContactCard(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.onSurface, size: 20),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'SUPORTE E SEGURANÇA',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text(
          'Central de Ajuda',
          style: AppTextStyles.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMERGÊNCIA 24H',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildEmergencyCard(
                icon: Icons.car_repair_outlined,
                title: 'Assistência\nMecânica',
                color: AppColors.primary,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildEmergencyCard(
                icon: Icons.gavel_outlined,
                title: 'Assunto\nJurídico',
                color: AppColors.secondary,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildEmergencyCard(
          icon: Icons.medical_services_outlined,
          title: 'Sinistros e Acidentes',
          color: AppColors.error,
          isFullWidth: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildEmergencyCard({
    required IconData icon,
    required String title,
    required Color color,
    bool isFullWidth = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon: icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isFullWidth) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ligar direto para central de emergência',
                style: AppTextStyles.labelSmall.copyWith(
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FAQ DO CONDUTOR',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFaqItem(
          'O que fazer em caso de pane mecânica?',
          'Primeiro, sinalize a via e ligue imediatamente para nossa assistência mecânica pelo botão acima. Não realize reparos por conta própria.',
        ),
        _buildFaqItem(
          'Como funciona a política de multas?',
          'As multas são identificadas via sistema e debitadas do condutor responsável no momento da infração, acrescidas de taxa administrativa.',
        ),
        _buildFaqItem(
          'Qual o procedimento para devolução?',
          'O check-out deve ser agendado com pelo menos 24h de antecedência. O veículo deve ser entregue limpo e com o mesmo nível de combustível.',
        ),
      ],
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: const RoundedRectangleBorder(),
        collapsedShape: const RoundedRectangleBorder(),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.onSurfaceVariant,
        childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          Text(
            answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectContactCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const AppIcon(
            icon: Icons.chat_outlined,
            color: AppColors.primary,
            size: 40,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Fale conosco via WhatsApp',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Atendimento humano de Segunda a Sexta, das 08h às 18h.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'INICIAR ATENDIMENTO',
            onPressed: () {},
            variant: AppButtonVariant.primary,
            icon: Icons.message,
          ),
        ],
      ),
    );
  }
}
