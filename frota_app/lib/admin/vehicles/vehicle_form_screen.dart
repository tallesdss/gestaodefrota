import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  int _currentStep = 0;
  final List<String> _stepTitles = ['Dados Básicos', 'Especificações', 'Documentação'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 16),
          Text(
            'ADICIONAR NOVO VEÍCULO',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final bool isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _stepTitles[index],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (index < _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: index < _currentStep ? AppColors.primary : AppColors.surfaceContainerHigh,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            const AppTextField(label: 'Placa do Veículo', hintText: 'ABC-1234'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Marca / Modelo', hintText: 'Toyota Corolla 2.0'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Ano de Fabricação', hintText: '2023'),
          ],
        );
      case 1:
        return Column(
          children: [
            const AppTextField(label: 'Chassi (VIN)', hintText: '9BWZZZ...'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Renavam', hintText: '0123456789'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Cor Predominante', hintText: 'Prata Metálico'),
          ],
        );
      case 2:
        return Column(
          children: [
            const AppTextField(label: 'Data de Vencimento do Licenciamento', hintText: 'DD/MM/AAAA'),
            const SizedBox(height: 24),
            const AppTextField(label: 'Apólice de Seguro', hintText: 'Número da apólice'),
            const SizedBox(height: 24),
            _buildFileUpload('Certificado de Registro (CRLV-e)'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFileUpload(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(label, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Text('PDF, PNG ou JPG (Máx 5MB)', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep > 0)
            AppButton(
              label: 'Voltar',
              onPressed: () => setState(() => _currentStep--),
              variant: AppButtonVariant.ghost,
            ),
          const SizedBox(width: 16),
          AppButton(
            label: _currentStep == _stepTitles.length - 1 ? 'Finalizar Cadastro' : 'Continuar',
            onPressed: () {
              if (_currentStep < _stepTitles.length - 1) {
                setState(() => _currentStep++);
              } else {
                // Finalize logic
              }
            },
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
