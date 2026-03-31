import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/inspection.dart';
import '../../models/vehicle.dart';
import '../../core/widgets/app_icon.dart';

class DriverInspectionDetailScreen extends StatefulWidget {
  final String inspectionId;

  const DriverInspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<DriverInspectionDetailScreen> createState() => _DriverInspectionDetailScreenState();
}

class _DriverInspectionDetailScreenState extends State<DriverInspectionDetailScreen> {
  final MockRepository _repository = MockRepository();
  
  Inspection? _inspection;
  Vehicle? _vehicle;
  bool _isLoading = true;

  final List<String> _allRequiredPhotos = [
    'Frente do veículo',
    'Traseira',
    'Lateral direita',
    'Lateral esquerda',
    'Painel ligado (KM visível)',
    'Pneus',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final insp = await _repository.getInspectionById(widget.inspectionId);
    if (insp != null) {
      Vehicle? v;
      try {
        v = await _repository.getVehicleById(insp.vehicleId);
      } catch (_) {
        // Fallback vehicle info if not found
        v = Vehicle(
          id: insp.vehicleId,
          model: 'VEÍCULO #102',
          plate: 'BRA2E24',
          brand: 'VW',
          year: 2024,
          color: 'Preto',
          status: VehicleStatus.available,
          currentKm: insp.kmAtInspection,
          fuelLevel: insp.fuelLevel,
          contractType: ContractType.uber,
          imageUrl: '',
          ipvaExpiry: DateTime.now(),
          insuranceExpiry: DateTime.now(),
          licensingExpiry: DateTime.now(),
        );
      }
      
      if (mounted) {
        setState(() {
          _inspection = insp;
          _vehicle = v;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_inspection == null) return const Scaffold(body: Center(child: Text('Vistoria não encontrada')));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const AppIcon(icon: Icons.arrow_back),
        ),
        title: Text(
          'DETALHES DA VISTORIA',
          style: AppTextStyles.labelMedium.copyWith(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildQuickSummary(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildVehicleInfoCard(),
                  const SizedBox(height: AppSpacing.xl),
                  if (_inspection!.checklist.isNotEmpty) ...[
                    _buildChecklistSection(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  _buildPhotosGallery(),
                  if (_inspection!.notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildNotesSection(),
                  ],
                  const SizedBox(height: AppSpacing.xxl * 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSummary() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Row(
        children: [
          _summaryText('ID', '#${_inspection!.id.split('_').last}'),
          const Spacer(),
          _summaryText('DATA', DateFormat('dd/MM/yy').format(_inspection!.dateTime)),
          const SizedBox(width: AppSpacing.lg),
          _summaryText('HORA', DateFormat('HH:mm').format(_inspection!.dateTime)),
        ],
      ),
    );
  }

  Widget _summaryText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
        Text(value, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    String label;
    IconData icon;

    switch (_inspection!.status) {
      case InspectionStatus.approved:
        color = AppColors.success;
        label = 'VISTORIA APROVADA';
        icon = Icons.check_circle_rounded;
        break;
      case InspectionStatus.rejected:
        color = AppColors.error;
        label = 'VISTORIA REPROVADA';
        icon = Icons.error_rounded;
        break;
      case InspectionStatus.pending:
        color = AppColors.warning;
        label = 'EM ANÁLISE';
        icon = Icons.pending_rounded;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_inspection!.reviewReason != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(),
            ),
            Text(
              'OBSERVAÇÃO DO REVISOR:',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Text(_inspection!.reviewReason!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.directions_car, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_vehicle?.model ?? 'Carregando...', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(_vehicle?.plate ?? '...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _infoBit(Icons.speed_rounded, 'KM ATUAL', '${_inspection!.kmAtInspection} km'),
                const Spacer(),
                _infoBit(Icons.local_gas_station_rounded, 'COMBUST.', '${(_inspection!.fuelLevel * 100).toInt()}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBit(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 9)),
            Text(value, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fact_check_outlined, color: AppColors.onSurfaceVariant, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CHECKLIST DE VERIFICAÇÃO',
              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: _inspection!.checklist.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      item.isChecked ? Icons.check_circle : Icons.error_outline,
                      size: 18,
                      color: item.isChecked ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(item.title, style: AppTextStyles.bodyMedium)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library_outlined, color: AppColors.onSurfaceVariant, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'EVIDÊNCIAS FOTOGRÁFICAS',
                  style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ],
            ),
            Text(
              '${_inspection!.photos.length} fotos',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
          ),
          itemCount: _allRequiredPhotos.length,
          itemBuilder: (context, index) {
            final title = _allRequiredPhotos[index];
            final photo = _inspection!.photos.cast<InspectionPhoto?>().firstWhere(
              (p) => p?.title.toLowerCase() == title.toLowerCase(),
              orElse: () => null,
            );

            return _buildPhotoCard(title, photo);
          },
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String title, InspectionPhoto? photo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 9),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
            ),
            child: photo != null ? GestureDetector(
              onTap: () => _showFullPhoto(photo.url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error_outline)),
                ),
              ),
            ) : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_photography_outlined, color: AppColors.onSurfaceVariant.withValues(alpha: 0.2), size: 24),
                  const SizedBox(height: 4),
                  Text('NÃO ENVIADA', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.2), fontSize: 8)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSERVAÇÕES DO MOTORISTA',
          style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
          ),
          child: Text(_inspection!.notes, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }

  void _showFullPhoto(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
            ),
            InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
