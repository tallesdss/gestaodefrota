import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

class InspectionFormScreen extends StatefulWidget {
  const InspectionFormScreen({super.key});

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  String? selectedVehicle;
  final List<String> vehicles = [
    'Volkswagen Virtus - ABC-1D23',
    'Chevrolet Onix - XYZ-9A87',
    'Fiat Cronos - FGH-5J44',
    'Renault Kwid - QWE-2R34',
    'Toyota Corolla - TYU-0P12',
  ];

  final TextEditingController _mileageController = TextEditingController();

  // Checklist states
  final Map<String, bool> externalPhotos = {
    'Frente': false,
    'Traseira': false,
    'Lateral Direita': false,
    'Lateral Esquerda': false,
    'Diagonal Frontal': false,
    'Diagonal Traseira': false,
  };

  final Map<String, bool> internalPhotos = {
    'Painel (KM)': false,
    'Hodômetro': false,
    'Volante/Geral': false,
    'Bancos Dianteiros': false,
    'Bancos Traseiros': false,
    'Porta-malas': false,
  };

  final Map<String, bool> specificPhotos = {
    'Parabrisa': false,
    'Vidro Traseiro': false,
    'Pneus': false,
    'Cofre do Motor': false,
    'Placa': false,
    'Chassi': false,
  };

  final Map<String, bool> verifications = {
    'Lataria OK': true,
    'Pneus OK': true,
    'Faróis/Lanternas OK': true,
    'Vidros sem trincas': true,
    'Retrovisores OK': true,
    'Limpadores OK': true,
    'Combustível Registrado': false,
    'Painel Limpo (Sem Luzes)': true,
    'Ar-condicionado OK': true,
    'Interior Conservado': true,
  };

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
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
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vistoria enviada com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'FINALIZAR VISTORIA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
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
        const SizedBox(width: AppSpacing.sm),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVehicle,
          isExpanded: true,
          hint: const Text('Escolha o veículo'),
          items: vehicles.map((v) {
            return DropdownMenuItem(value: v, child: Text(v));
          }).toList(),
          onChanged: (val) => setState(() => selectedVehicle = val),
        ),
      ),
    );
  }

  Widget _buildMileageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kilometragem Atual',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _mileageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Ex: 45000',
            suffixText: 'KM',
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
      ],
    );
  }

  Widget _buildPhotoGrid(Map<String, bool> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        String key = photos.keys.elementAt(index);
        bool hasPhoto = photos[key]!;
        return InkWell(
          onTap: () => setState(() => photos[key] = !hasPhoto),
          child: Container(
            decoration: BoxDecoration(
              color: hasPhoto
                  ? AppColors.success.withValues(alpha: 0.05)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasPhoto
                    ? AppColors.success
                    : AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasPhoto ? Icons.check_circle : Icons.add_a_photo_outlined,
                  color: hasPhoto
                      ? AppColors.success
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  key,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasPhoto
                        ? AppColors.success
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
