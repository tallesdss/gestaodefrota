import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_button.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _biometricEnabled = true;

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
              const SizedBox(height: AppSpacing.xxl),
              _buildPasswordField(),
              const SizedBox(height: AppSpacing.xl),
              _buildBiometricToggle(),
              const SizedBox(height: AppSpacing.xxxl),
              _buildLgpdSection(),
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
          'SEGURANÇA DA CONTA',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text('Privacidade e Acesso', style: AppTextStyles.headlineMedium),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                icon: Icons.lock_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'SENHA DE ACESSO',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            '********',
            style: TextStyle(
              fontSize: 24,
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'ALTERAR SENHA',
            onPressed: () {},
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTENTICAÇÃO BIOMÉTRICA',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Usar FaceID ou Digital para entrar',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _biometricEnabled,
            onChanged: (v) => setState(() => _biometricEnabled = v),
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLgpdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIREITOS DO USUÁRIO (LGPD)',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Você tem o direito de solicitar a exclusão definitiva de seus dados conforme a Lei Geral de Proteção de Dados.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'SOLICITAR EXCLUSÃO DE CONTA',
          onPressed: () {},
          variant: AppButtonVariant.ghost,
          icon: Icons.delete_outline,
        ),
      ],
    );
  }
}
