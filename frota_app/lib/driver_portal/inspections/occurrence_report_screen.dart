import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../core/repositories/inspection_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../models/inspection.dart';
import '../../core/config/supabase_config.dart';

class OccurrenceReportScreen extends StatefulWidget {
  const OccurrenceReportScreen({super.key});

  @override
  State<OccurrenceReportScreen> createState() => _OccurrenceReportScreenState();
}

class _OccurrenceReportScreenState extends State<OccurrenceReportScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory = 'Dano Externo (Lataria)';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationKmController = TextEditingController();
  final List<XFile> _capturedMedia = [];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Dano Externo (Lataria)',
    'Problema Mecânico',
    'Ar Condicionado',
    'Pneu/Roda',
    'Vidros/Espelhos',
    'Outro (Especificar)',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationKmController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _capturedMedia.add(photo);
        });
      }
    } catch (_) {}
  }

  Future<void> _pickVideo() async {
    try {
      final video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (video != null) {
        setState(() {
          _capturedMedia.add(video);
        });
      }
    } catch (_) {}
  }

  void _showMediaSourceModal() {
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
                'Adicionar Mídia da Ocorrência',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Tirar Foto com a Câmera', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Escolher Foto da Galeria', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined, color: AppColors.primary),
                title: Text('Adicionar Vídeo da Galeria', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma categoria para a ocorrência.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty && _capturedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione uma foto ou detalhamento do que ocorreu.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = _authRepo.currentUserId;
      if (uid == null) throw Exception('Usuário não autenticado');

      final activeContract = await _contractRepo.getActiveContractByDriver(uid);
      final driver = await _driverRepo.getDriverById(uid);
      final vehicleId = activeContract?.vehicleId ?? driver?.currentVehicleId ?? '';

      int currentKm = 0;
      if (vehicleId.isNotEmpty) {
        final veh = await _vehicleRepo.getVehicleById(vehicleId);
        currentKm = veh?.currentKm ?? 0;
      }

      final photosList = <InspectionPhoto>[];
      final inspectionId = 'ocorr_${DateTime.now().millisecondsSinceEpoch}';

      for (int i = 0; i < _capturedMedia.length; i++) {
        final file = _capturedMedia[i];
        try {
          final bytes = await file.readAsBytes();
          String documentUrl = '';

          // 1. Tentar upload no Supabase Storage
          try {
            documentUrl = await _inspectionRepo.uploadInspectionPhoto(
              inspectionId: inspectionId,
              position: 'avaria_$i',
              bytes: bytes,
              fileName: 'ocorr_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            );
          } catch (_) {
            // 2. Fallback Base64 caso o bucket não exista
            final base64String = base64Encode(bytes);
            documentUrl = 'data:image/jpeg;base64,$base64String';
          }

          photosList.add(InspectionPhoto(
            url: documentUrl,
            title: 'Foto ${i + 1} - $_selectedCategory',
            photoType: 'avaria',
          ));
        } catch (_) {}
      }

      final notesBuffer = StringBuffer();
      notesBuffer.writeln('[OCORRÊNCIA - $_selectedCategory]');
      if (_locationKmController.text.trim().isNotEmpty) {
        notesBuffer.writeln('Local/KM informado: ${_locationKmController.text.trim()}');
      }
      notesBuffer.writeln('Detalhes: ${_descriptionController.text.trim()}');

      final inspection = Inspection(
        id: '',
        contractId: activeContract?.id,
        vehicleId: vehicleId,
        driverId: uid,
        type: InspectionType.routine,
        status: InspectionStatus.pending,
        dateTime: DateTime.now(),
        kmAtInspection: currentKm,
        fuelLevel: 1.0,
        photos: photosList,
        checklist: [],
        notes: notesBuffer.toString(),
        hasNewDamage: true,
      );

      await _inspectionRepo.createInspection(inspection);

      // Registrar atividade na timeline
      try {
        await SupabaseConfig.client.from(SupabaseConfig.tabelaHistoricoAtividades).insert({
          'motorista_id': uid,
          'tipo': 'ocorrencia_relatada',
          'descricao': 'Ocorrência relatada: $_selectedCategory',
          'criado_em': DateTime.now().toIso8601String(),
        });
      } catch (_) {}

      final protocol = '#OC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSentConfirmation(protocol);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar ocorrência: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'RELATAR OCORRÊNCIA',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O que aconteceu com o veículo?',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Seu relato será enviado diretamente para a central de gestão para análise imediata.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _buildSectionLabel('CATEGORIA DA OCORRÊNCIA'),
            const SizedBox(height: AppSpacing.md),
            _buildCategorySelector(),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('ASPECTOS VISUAIS & FOTOS'),
            const SizedBox(height: AppSpacing.md),
            _buildPhotoUploader(),

            if (_capturedMedia.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildCapturedMediaPreview(),
            ],

            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('LOCAL E QUILOMETRAGEM (OPCIONAL)'),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _locationKmController,
              decoration: InputDecoration(
                hintText: 'Ex: Av. Paulista, 1000 - KM 45.200',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _buildSectionLabel('DETALHAMENTO DO OCORRIDO'),
            const SizedBox(height: AppSpacing.md),
            _buildDescriptionField(),

            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: _isSubmitting ? 'ENVIANDO RELATÓRIO...' : 'ENVIAR RELATÓRIO',
              onPressed: _isSubmitting ? null : _submitReport,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category : null;
            });
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.surfaceContainerLow,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhotoUploader() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _showMediaSourceModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(icon: Icons.photo_camera_outlined, color: AppColors.primary, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Adicionar Foto',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: InkWell(
            onTap: _pickVideo,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.onSurface.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppIcon(icon: Icons.videocam_outlined, color: AppColors.primary, size: 32),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Adicionar Vídeo',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedMediaPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_capturedMedia.length} arquivo(s) selecionado(s)',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _capturedMedia.clear()),
              child: const Text('Limpar todos', style: TextStyle(color: AppColors.error, fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _capturedMedia.asMap().entries.map((entry) {
            final idx = entry.key;
            final file = entry.value;
            final isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov') || file.name.endsWith('.mp4');

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: isVideo
                        ? const Center(
                            child: Icon(Icons.play_circle_fill, color: AppColors.primary, size: 36),
                          )
                        : FutureBuilder<Uint8List>(
                            future: file.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(snapshot.data!, fit: BoxFit.cover);
                              }
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            },
                          ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _capturedMedia.removeAt(idx);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            'Descreva detalhadamente o ocorrido (ex: barulho no motor, arranhão na porta traseira, etc)...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showSentConfirmation(String protocol) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 60),
            const SizedBox(height: AppSpacing.lg),
            Text('Relatório Enviado!', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sua ocorrência foi registrada com sucesso sob o protocolo $protocol. '
              'Nossos analistas da central de gestão foram notificados e entrarão em contato em breve.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'ENTENDIDO',
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
