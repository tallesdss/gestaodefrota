import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frota_app/core/routes/app_routes.dart';
import 'package:frota_app/core/repositories/auth_repository.dart';
import 'package:frota_app/core/repositories/contract_repository.dart';
import 'package:frota_app/core/repositories/inspection_repository.dart';
import 'package:frota_app/core/repositories/vehicle_repository.dart';
import 'package:frota_app/core/theme/app_colors.dart';
import 'package:frota_app/core/theme/app_spacing.dart';
import 'package:frota_app/core/theme/app_text_styles.dart';
import 'package:frota_app/models/contract.dart';
import 'package:frota_app/models/inspection.dart';
import 'package:frota_app/models/vehicle.dart';

class InspectionCheckOutScreen extends StatefulWidget {
  const InspectionCheckOutScreen({super.key});

  @override
  State<InspectionCheckOutScreen> createState() =>
      _InspectionCheckOutScreenState();
}

class _InspectionCheckOutScreenState extends State<InspectionCheckOutScreen> {
  final _authRepository = AuthRepository();
  final _contractRepository = ContractRepository();
  final _inspectionRepository = InspectionRepository();
  final _vehicleRepository = VehicleRepository();
  final _picker = ImagePicker();
  final _kmController = TextEditingController();
  final _notesController = TextEditingController();
  final Map<String, bool> _checklist = {
    'Pneus em bom estado': false,
    'Luzes funcionando': false,
    'Limpadores funcionando': false,
    'Freios sem anomalias': false,
    'Interior em condições adequadas': false,
  };
  final Set<String> _reviewedChecklist = {};
  final Map<String, XFile?> _photos = {
    'Frente': null,
    'Traseira': null,
    'Lateral Direita': null,
    'Lateral Esquerda': null,
    'Painel': null,
    'Hodômetro': null,
    'Bancos Dianteiros': null,
    'Placa': null,
  };

  Contract? _contract;
  Vehicle? _vehicle;
  Inspection? _approvedCheckin;
  String? _selectedFuelLevel;
  String? _loadError;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasNewDamage = false;

  @override
  void initState() {
    super.initState();
    _loadReturnContext();
  }

  @override
  void dispose() {
    _kmController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadReturnContext() async {
    try {
      final driverId = _authRepository.currentUserId;
      if (driverId == null) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      final contract = await _contractRepository.getActiveContractByDriver(
        driverId,
      );
      if (contract == null) {
        throw StateError('Não há contrato ativo para devolver um veículo.');
      }
      final vehicle = await _vehicleRepository.getVehicleById(
        contract.vehicleId,
      );
      if (vehicle == null) {
        throw StateError('Não foi possível carregar o veículo do contrato.');
      }

      final inspections = await _inspectionRepository.getInspections(
        driverId: driverId,
        vehicleId: vehicle.id,
      );
      Inspection? approvedCheckin;
      var hasPendingCheckout = false;
      for (final inspection in inspections) {
        if (inspection.contractId != contract.id) continue;
        if (inspection.type == InspectionType.checkin &&
            inspection.status == InspectionStatus.approved) {
          approvedCheckin ??= inspection;
        }
        if (inspection.type == InspectionType.checkout &&
            inspection.status == InspectionStatus.pending) {
          hasPendingCheckout = true;
        }
      }
      if (approvedCheckin == null) {
        throw StateError(
          'A vistoria de recebimento precisa ser aprovada pelo administrador antes da devolução.',
        );
      }
      if (hasPendingCheckout) {
        throw StateError(
          'Sua devolução já foi enviada e aguarda análise do administrador.',
        );
      }

      if (!mounted) return;
      setState(() {
        _contract = contract;
        _vehicle = vehicle;
        _approvedCheckin = approvedCheckin;
        _kmController.text = vehicle.currentKm.toString();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'DEVOLVER VEÍCULO',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_loadError!, textAlign: TextAlign.center),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            )
          : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_vehicle!.brand} ${_vehicle!.model} · ${_vehicle!.plate}',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Recebimento aprovado: ${_approvedCheckin!.kmAtInspection} km, ${(100 * _approvedCheckin!.fuelLevel).round()}% de combustível.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('FOTOS DA DEVOLUÇÃO', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.15,
            children: _photos.keys.map(_buildPhotoTile).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('CHECKLIST DA DEVOLUÇÃO', style: AppTextStyles.labelLarge),
          ..._checklist.keys.map(
            (item) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _checklist[item] ?? false,
              title: Text(item),
              onChanged: (value) => setState(() {
                _checklist[item] = value ?? false;
                _reviewedChecklist.add(item);
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _kmController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Quilometragem final (KM)',
              prefixIcon: Icon(Icons.speed),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _selectedFuelLevel,
            decoration: const InputDecoration(
              labelText: 'Nível de combustível',
              prefixIcon: Icon(Icons.local_gas_station),
            ),
            items: ['Vazio', '1/4', '1/2', '3/4', 'Cheio']
                .map(
                  (level) => DropdownMenuItem(value: level, child: Text(level)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedFuelLevel = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _hasNewDamage,
            onChanged: (value) => setState(() => _hasNewDamage = value),
            title: const Text('Identifiquei nova avaria'),
          ),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observações da devolução',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _submitCheckout,
                    icon: const Icon(Icons.assignment_return_outlined),
                    label: const Text('ENVIAR DEVOLUÇÃO PARA ANÁLISE'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoTile(String label) {
    final captured = _photos[label] != null;
    return InkWell(
      onTap: () => _pickPhoto(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: captured ? AppColors.success : AppColors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              captured ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: captured ? AppColors.success : AppColors.primary,
              size: 30,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium,
            ),
            Text(
              captured ? 'Foto capturada' : 'Toque para fotografar',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(String label) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final photo = await _picker.pickImage(source: source, imageQuality: 80);
    if (photo != null && mounted) setState(() => _photos[label] = photo);
  }

  Future<void> _submitCheckout() async {
    if (_isSubmitting) return;
    final missingPhotos = _photos.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .toList();
    if (missingPhotos.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Capture todas as fotos: ${missingPhotos.join(', ')}.'),
        ),
      );
      return;
    }
    if (_reviewedChecklist.length != _checklist.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda todos os itens do checklist.')),
      );
      return;
    }
    if (_hasNewDamage && _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva a avaria identificada.')),
      );
      return;
    }

    final km = int.tryParse(_kmController.text.trim());
    if (km == null || km < (_vehicle?.currentKm ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Informe um KM válido, igual ou maior que ${_vehicle?.currentKm ?? 0} km.',
          ),
        ),
      );
      return;
    }
    if (_selectedFuelLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o nível de combustível.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final driverId = _authRepository.currentUserId;
      final contract = _contract;
      final vehicle = _vehicle;
      if (driverId == null || contract == null || vehicle == null) {
        throw StateError(
          'Não foi possível confirmar o contrato e o veículo ativos.',
        );
      }

      final existing = await _inspectionRepository.getInspections(
        driverId: driverId,
        vehicleId: vehicle.id,
      );
      if (existing.any(
        (inspection) =>
            inspection.contractId == contract.id &&
            inspection.type == InspectionType.checkout &&
            inspection.status == InspectionStatus.pending,
      )) {
        throw StateError('Já existe uma devolução aguardando análise.');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final photos = <InspectionPhoto>[];
      for (final entry in _photos.entries) {
        final file = entry.value!;
        final url = await _inspectionRepository.uploadInspectionPhoto(
          inspectionId: 'checkout_${contract.id}_$timestamp',
          position: entry.key.toLowerCase(),
          bytes: await file.readAsBytes(),
          fileName: '${entry.key.toLowerCase()}_$timestamp.jpg',
        );
        photos.add(
          InspectionPhoto(
            url: url,
            title: entry.key,
            photoType: entry.key.toLowerCase(),
          ),
        );
      }

      final fuelLevel = switch (_selectedFuelLevel) {
        'Vazio' => 0.0,
        '1/4' => 0.25,
        '1/2' => 0.5,
        '3/4' => 0.75,
        'Cheio' => 1.0,
        _ => throw StateError('Nível de combustível inválido.'),
      };
      await _inspectionRepository.createInspection(
        Inspection(
          id: '',
          contractId: contract.id,
          vehicleId: vehicle.id,
          driverId: driverId,
          type: InspectionType.checkout,
          status: InspectionStatus.pending,
          dateTime: DateTime.now(),
          kmAtInspection: km,
          fuelLevel: fuelLevel,
          photos: photos,
            checklist: _checklist.entries
              .map((entry) => ChecklistItem(title: entry.key, isChecked: entry.value))
              .toList(),
          notes: _notesController.text.trim(),
          hasNewDamage: _hasNewDamage,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devolução enviada para análise do administrador.'),
          ),
        );
        context.pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível registrar a devolução: $error'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
