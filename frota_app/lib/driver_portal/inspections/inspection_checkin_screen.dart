import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_button.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/routes/app_routes.dart';

class InspectionCheckInScreen extends StatefulWidget {
  const InspectionCheckInScreen({super.key});

  @override
  State<InspectionCheckInScreen> createState() =>
      _InspectionCheckInScreenState();
}

class _InspectionCheckInScreenState extends State<InspectionCheckInScreen> {
  int _currentStep = 0;
  final int _totalSteps = 4; // Intro, External, Internal, Verification

  // Mocking photo states
  final Map<String, bool> _photosCaptured = {
    'Frente': false,
    'Traseira': false,
    'Lateral Direita': false,
    'Lateral Esquerda': false,
    'Painel': false,
    'Placa': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(child: _buildStepContent()),
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
            icon: const AppIcon(icon: Icons.arrow_back),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'ETAPA ${_currentStep + 1} DE $_totalSteps',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              Text(_getStepTitle(), style: AppTextStyles.titleMedium),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Início da Vistoria';
      case 1:
        return 'Fotos Externas';
      case 2:
        return 'Fotos Internas';
      case 3:
        return 'Verificação Final';
      default:
        return 'Vistoria';
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
      case 0:
        return _buildIntroStep();
      case 1:
        return _buildPhotoStep([
          'Frente',
          'Traseira',
          'Lateral Direita',
          'Lateral Esquerda',
        ]);
      case 2:
        return _buildPhotoStep([
          'Painel',
          'Hodômetro',
          'Bancos Dianteiros',
          'Placa',
        ]);
      case 3:
        return _buildVerificationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroStep() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppIcon(
            icon: Icons.camera_alt_outlined,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Vistoria de Check-in',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Certifique-se de estar em um local iluminado. '
            'Você precisará capturar fotos de todos os ângulos do veículo.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _buildInfoItem(Icons.light_mode_outlined, 'Boa iluminação'),
          _buildInfoItem(
            Icons.qr_code_scanner_outlined,
            'Foco nítido na placa',
          ),
          _buildInfoItem(
            Icons.verified_user_outlined,
            'Veracidade das informações',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoStep(List<String> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isCaptured = _photosCaptured[item] ?? false;

        return GestureDetector(
          onTap: () {
            setState(() {
              _photosCaptured[item] = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isCaptured
                  ? AppColors.successContainer.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCaptured ? AppColors.success : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCaptured)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 40,
                  )
                else
                  AppIcon(
                    icon: Icons.add_a_photo_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCaptured ? AppColors.success : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationStep() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildVerificationCheck('Pneus em bom estado'),
        _buildVerificationCheck('Nível de combustível registrado'),
        _buildVerificationCheck('Sem luzes de alerta no painel'),
        _buildVerificationCheck('Limpadores funcionando'),
        _buildVerificationCheck('Ar-condicionado gelando'),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Observações adicionais...',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCheck(String label) {
    bool checked = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return CheckboxListTile(
          value: checked,
          onChanged: (val) => setState(() => checked = val!),
          title: Text(label, style: AppTextStyles.bodyMedium),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      },
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
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
              label: _currentStep == _totalSteps - 1
                  ? 'CONCLUIR VISTORIA'
                  : 'PRÓXIMO',
              onPressed: () {
                if (_currentStep < _totalSteps - 1) {
                  setState(() => _currentStep++);
                } else {
                  _showSuccessDialog();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: AppColors.success, size: 80),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Vistoria Enviada!',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Os dados foram registrados com sucesso e já estão no sistema.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'VOLTAR PARA HOME',
              onPressed: () {
                context.go(AppRoutes.driverHome);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
