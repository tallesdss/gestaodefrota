import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';

class DriverProfileDetailScreen extends StatelessWidget {
  const DriverProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildStatsGrid(),
              const SizedBox(height: AppSpacing.xxl),
              _buildActionList(context),
              const SizedBox(height: AppSpacing.xxl),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHigh,
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/300?u=joao'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'João da Silva',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Condutor Parceiro desde 2023',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildScoreBadge(),
      ],
    );
  }

  Widget _buildScoreBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFF4CAF50), size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Score 4.9',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('KM RODADOS', '12.450', Icons.speed),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard('CONTRATOS', '02', Icons.description_outlined),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard('DIAS ATIVO', '342', Icons.calendar_today_outlined),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon: icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(
          icon: Icons.article_outlined,
          title: 'Central de Documentos',
          subtitle: 'CNH, Contratos e Comprovantes',
          onTap: () => context.push(AppRoutes.driverDocuments),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionItem(
          icon: Icons.security_outlined,
          title: 'Segurança da Conta',
          subtitle: 'Senha e Autenticação',
          onTap: () => context.push(AppRoutes.driverAccountSecurity),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionItem(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          subtitle: 'Preferências e Notificações',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon: icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(AppRoutes.login),
      child: Text(
        'ENCERRAR SESSÃO',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.error,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
