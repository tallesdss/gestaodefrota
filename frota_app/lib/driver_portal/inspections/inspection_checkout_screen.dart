import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_button.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/routes/app_routes.dart';

class InspectionCheckOutScreen extends StatefulWidget {
  const InspectionCheckOutScreen({super.key});

  @override
  State<InspectionCheckOutScreen> createState() => _InspectionCheckOutScreenState();
}

class _InspectionCheckOutScreenState extends State<InspectionCheckOutScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3; // Comparison, Final Photos, Verification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: _buildStepContent(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const AppIcon(icon: Icons.close),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'CHECK-OUT DE VEÍCULO',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _getStepTitle(),
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Comparativo Visual';
      case 1: return 'Fotos Finais';
      case 2: return 'Quilometragem e Avarias';
      default: return 'Vistoria';
    }
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentStep + 1) / _totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildComparisonStep();
      case 1: return _buildFinalPhotosStep();
      case 2: return _buildFinalVerificationStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildComparisonStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text(
          'Compare o estado atual com a vistoria de entrada.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildComparisonItem('FRENTE DO VEÍCULO'),
        _buildComparisonItem('LATERAL DIREITA'),
        _buildComparisonItem('LATERAL ESQUERDA'),
        _buildComparisonItem('TRASEIRA'),
      ],
    );
  }

  Widget _buildComparisonItem(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.history, color: AppColors.onSurfaceVariant)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Check-in', style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: const Center(child: Icon(Icons.camera_alt_outlined, color: AppColors.primary)),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Agora', style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPhotosStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const AppIcon(icon: Icons.camera_enhance_outlined, size: 64, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Capture as fotos de encerramento.',
            style: AppTextStyles.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'É essencial documentar como o veículo está sendo entregue para evitar cobranças indevidas.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildCaptureTile('Placa do Veículo'),
          _buildCaptureTile('Painel com KM Final'),
          _buildCaptureTile('Luz do Tanque'),
        ],
      ),
    );
  }

  Widget _buildCaptureTile(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          const AppIcon(icon: Icons.camera_alt, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildFinalVerificationStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text('INFORMAÇÕES DE ENCERRAMENTO', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1)),
        const SizedBox(height: AppSpacing.xl),
        _buildInputField('Quilometragem Final (KM)', Icons.speed),
        _buildInputField('Nível de Combustível (%)', Icons.gas_meter_outlined),
        const SizedBox(height: AppSpacing.xl),
        Text('RELATAR NOVA AVARIA?', style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'NÃO',
                onPressed: () {},
                variant: AppButtonVariant.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'SIM, RELATAR',
                onPressed: () {},
                variant: AppButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          if (_currentStep > 0)
             Expanded(
               child: AppButton(
                 label: 'VOLTAR',
                 onPressed: () => setState(() => _currentStep--),
                 variant: AppButtonVariant.outline,
               ),
             ),
          if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: AppButton(
              label: _currentStep == _totalSteps - 1 ? 'CONCLUIR DEVOLUÇÃO' : 'PRÓXIMO',
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  context.go(AppRoutes.driverHome);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
