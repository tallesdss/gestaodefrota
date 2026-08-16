import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/inspection_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../models/inspection.dart';
import '../../models/vehicle.dart';

class InspectionFormScreen extends StatefulWidget {
  const InspectionFormScreen({super.key});

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // Checklist states
  final Map<String, bool> externalPhotos = {
    'Frente': true,
    'Traseira': true,
    'Lateral Direita': true,
    'Lateral Esquerda': true,
    'Diagonal Frontal': false,
    'Diagonal Traseira': false,
  };

  final Map<String, bool> internalPhotos = {
    'Painel (KM)': true,
    'Hodômetro': true,
    'Volante/Geral': false,
    'Bancos Dianteiros': true,
    'Bancos Traseiros': false,
    'Porta-malas': false,
  };

  final Map<String, bool> specificPhotos = {
    'Parabrisa': true,
    'Vidro Traseiro': false,
    'Pneus': true,
    'Cofre do Motor': false,
    'Placa': true,
    'Chassi': false,
  };

  final Map<String, bool> verifications = {
    'Lataria OK': true,
    'Pneus OK': true,
    'Faróis/Lanternas OK': true,
    'Vidros sem trincas': true,
    'Retrovisores OK': true,
    'Limpadores OK': true,
    'Combustível Registrado': true,
    'Painel Limpo (Sem Luzes)': true,
    'Ar-condicionado OK': true,
    'Interior Conservado': true,
  };

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final list = await _vehicleRepo.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = list;
          if (list.isNotEmpty) {
            _selectedVehicle = list.first;
            _mileageController.text = list.first.currentMileage.toString();
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveInspection() async {
    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione o veículo para a vistoria.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final km = int.tryParse(_mileageController.text.trim()) ?? _selectedVehicle!.currentMileage;

      final photos = <InspectionPhoto>[];
      externalPhotos.forEach((k, v) {
        if (v) {
          photos.add(InspectionPhoto(
            url: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?q=80&w=400&auto=format&fit=crop',
            title: k,
            photoType: k.toLowerCase(),
          ));
        }
      });
      internalPhotos.forEach((k, v) {
        if (v) {
          photos.add(InspectionPhoto(
            url: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=400&auto=format&fit=crop',
            title: k,
            photoType: k.toLowerCase(),
          ));
        }
      });

      final checklist = <ChecklistItem>[];
      verifications.forEach((k, v) {
        checklist.add(ChecklistItem(title: k, isChecked: v));
      });

      final inspection = Inspection(
        id: '',
        vehicleId: _selectedVehicle!.id,
        driverId: _selectedVehicle!.activeDriverId ?? '10000000-0000-0000-0000-000000000001',
        type: InspectionType.checkin,
        status: InspectionStatus.approved,
        dateTime: DateTime.now(),
        kmAtInspection: km,
        fuelLevel: 1.0,
        photos: photos,
        checklist: checklist,
        notes: _notesController.text.trim(),
        hasNewDamage: false,
      );

      await _inspectionRepo.createInspection(inspection);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vistoria registrada com sucesso no Supabase!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar vistoria: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Nova Vistoria',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 1: VEHICLE
            _buildSectionHeader(
              '1. Seleção do Veículo',
              Icons.directions_car_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildVehicleSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildMileageInput(),
            const SizedBox(height: AppSpacing.xxl),

            // STEP 2: EXTERNAL PHOTOS
            _buildSectionHeader('2. Fotos Externas', Icons.camera_alt_outlined),
            _buildPhotoGrid(externalPhotos),
            const SizedBox(height: AppSpacing.xxl),

            // STEP 3: INTERNAL PHOTOS
            _buildSectionHeader('3. Fotos Internas', Icons.chair_outlined),
            _buildPhotoGrid(internalPhotos),
            const SizedBox(height: AppSpacing.xxl),

            // STEP 4: SPECIFIC PHOTOS
            _buildSectionHeader(
              '4. Itens Específicos',
              Icons.grid_view_outlined,
            ),
            _buildPhotoGrid(specificPhotos),
            const SizedBox(height: AppSpacing.xxl),

            // STEP 5: VERIFICATIONS
            _buildSectionHeader(
              '5. Checklist de Verificações',
              Icons.fact_check_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildChecklistGrid(),
            const SizedBox(height: AppSpacing.xxl),

            // NOTE
            Text('Observações Adicionais', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Descreva avarias, detalhes técnicos ou observações gerais...',
                fillColor: AppColors.surfaceContainerLowest,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl * 2),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _handleSaveInspection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Salvar Vistoria no Supabase',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Vehicle>(
          value: _selectedVehicle,
          hint: const Text('Selecione o Veículo'),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: _vehicles.map((v) {
            return DropdownMenuItem<Vehicle>(
              value: v,
              child: Text(
                '${v.brand} ${v.model} (${v.plate})',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedVehicle = val;
                _mileageController.text = val.currentMileage.toString();
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMileageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quilometragem no Momento (KM)',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _mileageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 45200',
            fillColor: AppColors.surfaceContainerLowest,
            filled: true,
            suffixText: 'KM',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid(Map<String, bool> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final key = photos.keys.elementAt(index);
        final hasPhoto = photos[key]!;
        return InkWell(
          onTap: () {
            setState(() {
              photos[key] = !hasPhoto;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: hasPhoto
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto
                    ? AppColors.primary
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
                width: hasPhoto ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasPhoto ? Icons.check_circle : Icons.add_a_photo_outlined,
                  color: hasPhoto
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  key,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasPhoto
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChecklistGrid() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: verifications.keys.map((key) {
          return SwitchListTile(
            title: Text(key, style: AppTextStyles.bodyMedium),
            value: verifications[key]!,
            onChanged: (val) => setState(() => verifications[key] = val),
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}
