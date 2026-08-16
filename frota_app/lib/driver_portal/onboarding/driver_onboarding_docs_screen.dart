import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';

import '../../core/repositories/driver_repository.dart';
import '../../core/config/supabase_config.dart';

class DriverOnboardingDocsScreen extends StatefulWidget {
  const DriverOnboardingDocsScreen({super.key});

  @override
  State<DriverOnboardingDocsScreen> createState() =>
      _DriverOnboardingDocsScreenState();
}

class _DriverOnboardingDocsScreenState
    extends State<DriverOnboardingDocsScreen> {
  int _currentStep = 0;
  final ImagePicker _picker = ImagePicker();
  final DriverRepository _driverRepo = DriverRepository();
  XFile? _cnhFile;
  XFile? _residenceFile;
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

    try {
      final driverId = SupabaseConfig.currentUserId;
      if (driverId != null) {
        if (_cnhFile != null) {
          final bytes = await _cnhFile!.readAsBytes();
          await _driverRepo.uploadDriverDocument(
            driverId: driverId,
            docType: 'cnh_frente',
            bytes: bytes,
            fileName: 'cnh_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }
        if (_residenceFile != null) {
          final bytes = await _residenceFile!.readAsBytes();
          await _driverRepo.uploadDriverDocument(
            driverId: driverId,
            docType: 'comprovante_residencia',
            bytes: bytes,
            fileName: 'comprovante_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
        }
      }
    } catch (_) {}

    if (mounted) {
      context.push(AppRoutes.driverOnboardingContract);
    }
  }

  Future<void> _pickImage(bool isCnh) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCnh ? 'Documento da CNH' : 'Comprovante de Residência',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Tirar Foto', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (file != null) {
                    setState(() {
                      if (isCnh) {
                        _cnhFile = file;
                      } else {
                        _residenceFile = file;
                      }
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Escolher da Galeria', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(ctx);
                  final file = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (file != null) {
                    setState(() {
                      if (isCnh) {
                        _cnhFile = file;
                      } else {
                        _residenceFile = file;
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
    final hasFile = _currentStep == 0 ? _cnhFile != null : _residenceFile != null;
    final currentFile = _currentStep == 0 ? _cnhFile : _residenceFile;

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
            file: currentFile,
            onTap: () => _pickImage(_currentStep == 0),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: AppButton(
              label: _currentStep == 0 ? 'CONTINUAR' : 'ENVIAR PARA ANÁLISE',
              isFullWidth: true,
              onPressed: hasFile ? _nextStep : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
  }) {
    final isUploaded = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUploaded ? AppColors.success : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: isUploaded
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    if (kIsWeb)
                      Image.network(file.path, fit: BoxFit.cover)
                    else
                      Image.file(File(file.path), fit: BoxFit.cover),
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                            const SizedBox(width: 8),
                            Text('Toque para alterar', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppIcon(icon: Icons.camera_alt_outlined, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      title,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toque para abrir a câmera ou galeria',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
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
              'Os documentos foram anexados com sucesso e estão prontos para envio.',
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
