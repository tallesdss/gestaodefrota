import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';

class DriverOnboardingDocsScreen extends StatefulWidget {
  const DriverOnboardingDocsScreen({super.key});

  @override
  State<DriverOnboardingDocsScreen> createState() =>
      _DriverOnboardingDocsScreenState();
}

class _DriverOnboardingDocsScreenState
    extends State<DriverOnboardingDocsScreen> {
  int _currentStep = 0;
  bool _cnhUploaded = false;
  bool _residenceUploaded = false;
  bool _analyzing = false;

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _startAnalysis();
    }
  }

  void _startAnalysis() async {
    setState(() {
      _analyzing = true;
    });
    // Simulating OCR/Analysis
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.push(AppRoutes.driverOnboardingContract);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _analyzing ? _buildAnalysisState() : _buildFormState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '0${_currentStep + 1}',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ONBOARDING',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Identidade Digital',
                    style: AppTextStyles.headlineSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(2, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == 0 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFormState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentStep == 0 ? 'Capture sua CNH' : 'Comprovante de Residência',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _currentStep == 0
                ? 'Certifique-se de que o documento esteja visível e em um local iluminado.'
                : 'Deve estar no seu nome e ser de no máximo 90 dias atrás.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildUploadCard(
            title: _currentStep == 0 ? 'Frente da CNH' : 'Comprovante',
            isUploaded: _currentStep == 0 ? _cnhUploaded : _residenceUploaded,
            onTap: () {
              setState(() {
                if (_currentStep == 0) {
                  _cnhUploaded = true;
                } else {
                  _residenceUploaded = true;
                }
              });
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: AppButton(
              label: _currentStep == 0 ? 'CONTINUAR' : 'ENVIAR PARA ANÁLISE',
              isFullWidth: true,
              onPressed: (_currentStep == 0 ? _cnhUploaded : _residenceUploaded)
                  ? _nextStep
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUploaded)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              )
            else
              const AppIcon(icon: Icons.camera_alt_outlined, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              isUploaded ? 'Documento Capturado' : title,
              style: AppTextStyles.labelLarge,
            ),
            if (!isUploaded)
              Text(
                'Toque para abrir a câmera',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'AUDITORIA DIGITAL',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text('Validando Documentos...', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nossa IA está analisando a nitidez e a validade dos seus dados.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
