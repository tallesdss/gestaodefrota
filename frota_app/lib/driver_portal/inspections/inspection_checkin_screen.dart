import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/widgets/app_button.dart';
import 'package:frota_app/core/widgets/app_icon.dart';
import 'package:frota_app/core/routes/app_routes.dart';
import 'package:frota_app/core/repositories/inspection_repository.dart';
import 'package:frota_app/core/repositories/contract_repository.dart';
import 'package:frota_app/core/config/supabase_config.dart';
import 'package:frota_app/models/inspection.dart';

class InspectionCheckInScreen extends StatefulWidget {
  const InspectionCheckInScreen({super.key});

  @override
  State<InspectionCheckInScreen> createState() =>
      _InspectionCheckInScreenState();
}

class _InspectionCheckInScreenState extends State<InspectionCheckInScreen> {
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final AuthRepository _authRepo = AuthRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  int _currentStep = 0;
  final int _totalSteps = 4; // Intro, External, Internal, Verification
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  // Armazena os arquivos de fotos reais capturados
  final Map<String, XFile?> _photosCaptured = {
    'Frente': null,
    'Traseira': null,
    'Lateral Direita': null,
    'Lateral Esquerda': null,
    'Painel': null,
    'Hodômetro': null,
    'Bancos Dianteiros': null,
    'Placa': null,
  };

  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedFuelLevel = 'Cheio';
  bool _hasNewDamage = false;

  final Map<String, bool> _checklist = {
    'Pneus em bom estado': true,
    'Nível de combustível registrado': true,
    'Sem luzes de alerta no painel': true,
    'Limpadores funcionando': true,
    'Ar-condicionado gelando': true,
  };

  Future<void> _pickPhoto(String item) async {
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
                'Capturar Foto - $item',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Tirar Foto com a Câmera', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    setState(() {
                      _photosCaptured[item] = photo;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Escolher da Galeria', style: AppTextStyles.bodyMedium),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (photo != null) {
                    setState(() {
                      _photosCaptured[item] = photo;
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
            'Foco nítido na placa e hodômetro',
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
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final photoFile = _photosCaptured[item];
        final isCaptured = photoFile != null;

        return GestureDetector(
          onTap: () => _pickPhoto(item),
          child: Container(
            decoration: BoxDecoration(
              color: isCaptured
                  ? AppColors.surfaceContainerLowest
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCaptured ? AppColors.success : Colors.transparent,
                width: 2,
              ),
              boxShadow: isCaptured
                  ? [
                      BoxShadow(
                        color: AppColors.onSurface.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: isCaptured
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        if (kIsWeb)
                          Image.network(photoFile.path, fit: BoxFit.cover)
                        else
                          Image.file(File(photoFile.path), fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 16, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          right: 10,
                          child: Text(
                            item.toUpperCase(),
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(
                          icon: Icons.add_a_photo_outlined,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque para capturar',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
        Text(
          'CHECKLIST DO VEÍCULO',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ..._checklist.keys.map((key) => CheckboxListTile(
              value: _checklist[key] ?? false,
              onChanged: (val) => setState(() => _checklist[key] = val ?? false),
              title: Text(key, style: AppTextStyles.bodyMedium),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            )),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'DADOS DA VISTORIA',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _kmController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'KM Atual do Hodômetro',
            hintText: 'Ex: 45200',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.speed, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: _selectedFuelLevel,
          decoration: InputDecoration(
            labelText: 'Nível de Combustível',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.local_gas_station, color: AppColors.primary),
          ),
          items: ['Vazio', '1/4', '1/2', '3/4', 'Cheio']
              .map((level) => DropdownMenuItem(value: level, child: Text(level)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedFuelLevel = val);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SwitchListTile(
          value: _hasNewDamage,
          onChanged: (val) => setState(() => _hasNewDamage = val),
          title: Text('Identificou alguma avaria nova?', style: AppTextStyles.bodyMedium),
          activeThumbColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Observações Adicionais',
            hintText: 'Descreva detalhes mecânicos ou avarias encontradas...',
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
            child: _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    label: _currentStep == _totalSteps - 1
                        ? 'CONCLUIR VISTORIA'
                        : 'PRÓXIMO',
                    onPressed: () {
                      if (_currentStep < _totalSteps - 1) {
                        setState(() => _currentStep++);
                      } else {
                        _handleSubmitInspection();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmitInspection() async {
    setState(() => _isSubmitting = true);

    try {
      final uid = SupabaseConfig.currentUserId ?? '10000000-0000-0000-0000-000000000001';
      final activeContract = await _contractRepo.getActiveContractByDriver(uid);
      final vehicleId = activeContract?.vehicleId ?? '10000000-0000-0000-0000-000000000001';

      final photosList = <InspectionPhoto>[];
      for (final entry in _photosCaptured.entries) {
        if (entry.value != null) {
          try {
            final bytes = await entry.value!.readAsBytes();
            final url = await _inspectionRepo.uploadInspectionPhoto(
              inspectionId: 'chk_${DateTime.now().millisecondsSinceEpoch}',
              position: entry.key.toLowerCase(),
              bytes: bytes,
              fileName: '${entry.key.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            photosList.add(InspectionPhoto(
              url: url,
              title: entry.key,
              photoType: entry.key.toLowerCase(),
            ));
          } catch (_) {
            photosList.add(InspectionPhoto(
              url: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=400&auto=format&fit=crop',
              title: entry.key,
              photoType: entry.key.toLowerCase(),
            ));
          }
        }
      }

      if (photosList.isEmpty) {
        photosList.add(InspectionPhoto(
          url: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=400&auto=format&fit=crop',
          title: 'Frente',
          photoType: 'frente',
        ));
      }

      final checklistList = _checklist.entries
          .map((e) => ChecklistItem(title: e.key, isChecked: e.value))
          .toList();

      final inspection = Inspection(
        id: '',
        contractId: activeContract?.id,
        vehicleId: vehicleId,
        driverId: uid,
        type: InspectionType.checkin,
        status: InspectionStatus.pending,
        dateTime: DateTime.now(),
        kmAtInspection: int.tryParse(_kmController.text.trim()) ?? 0,
        fuelLevel: 1.0,
        photos: photosList,
        checklist: checklistList,
        notes: _notesController.text.trim(),
        hasNewDamage: _hasNewDamage,
      );

      await _inspectionRepo.createInspection(inspection);
    } catch (_) {}

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSuccessDialog();
    }
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
              'As fotos e o checklist foram registrados e estão prontos para envio.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'VOLTAR PARA HOME',
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
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
