import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/inspection.dart';
import '../../models/vehicle.dart';
import '../../models/driver.dart';
// import '../../core/widgets/status_badge.dart'; // Removed unused import

class InspectionDetailScreen extends StatefulWidget {
  final String inspectionId;

  const InspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  final MockRepository _repository = MockRepository();
  final TextEditingController _reasonController = TextEditingController();
  
  Inspection? _inspection;
  Vehicle? _vehicle;
  Driver? _driver;
  bool _isLoading = true;
  bool _isSubmitting = false;

  final List<String> _allRequiredPhotos = [
    'Frente do veículo',
    'Traseira',
    'Lateral direita',
    'Lateral esquerda',
    'Diagonal frontal',
    'Diagonal traseira',
    'Painel ligado (KM visível)',
    'Hodômetro (quilometragem)',
    'Volante e painel geral',
    'Bancos dianteiros',
    'Bancos traseiros',
    'Porta-malas',
    'Parabrisa (vidro dianteiro)',
    'Vidro traseiro',
    'Pneus',
    'Cofre do motor',
    'Placa do veículo',
    'Chassi',
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
      } catch (_) {}
      
      Driver? d;
      try {
        d = (await _repository.getDrivers()).firstWhere((d) => d.id == insp.driverId);
      } catch (_) {}

      setState(() {
        _inspection = insp;
        _vehicle = v;
        _driver = d;
        _isLoading = false;
        if (insp.reviewReason != null) {
          _reasonController.text = insp.reviewReason!;
        }
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleReview(InspectionStatus newStatus) async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o motivo da decisão.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updated = _inspection!.copyWith(
        status: newStatus,
        reviewReason: _reasonController.text.trim(),
        reviewerId: 'admin_1', // Mock admin ID
      );

      await _repository.updateInspection(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus == InspectionStatus.approved 
                ? 'Vistoria aprovada com sucesso!' 
                : 'Vistoria reprovada.'),
            backgroundColor: newStatus == InspectionStatus.approved ? AppColors.success : AppColors.error,
          ),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_inspection == null) return const Scaffold(body: Center(child: Text('Vistoria não encontrada')));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'DETALHES DA VISTORIA',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoCard(),
            const SizedBox(height: AppSpacing.xl),
            _buildChecklistSection(),
            const SizedBox(height: AppSpacing.xl),
            _buildPhotosGallery(),
            const SizedBox(height: AppSpacing.xl),
            _buildReviewSection(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ITENS DE VERIFICAÇÃO',
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.ambientShadow,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: _inspection!.checklist.map((item) {
              return CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                title: Text(item.title, style: AppTextStyles.bodyMedium),
                value: item.isChecked,
                activeColor: AppColors.primary,
                onChanged: _inspection!.status == InspectionStatus.pending
                  ? (val) {
                      setState(() {
                         final index = _inspection!.checklist.indexOf(item);
                         _inspection!.checklist[index] = item.copyWith(isChecked: val ?? false);
                      });
                    }
                  : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (_inspection!.status) {
      case InspectionStatus.approved:
        statusColor = AppColors.success;
        statusLabel = 'APROVADA';
        statusIcon = Icons.check_circle_rounded;
        break;
      case InspectionStatus.rejected:
        statusColor = AppColors.error;
        statusLabel = 'REPROVADA';
        statusIcon = Icons.cancel_rounded;
        break;
      case InspectionStatus.pending:
        statusColor = AppColors.warning;
        statusLabel = 'AGUARDANDO APROVAÇÃO';
        statusIcon = Icons.pending_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusLabel,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Vistoria de ${_inspection!.type == InspectionType.checkin ? "Check-in" : "Check-out"}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailItem('VEÍCULO', _vehicle?.plate ?? '-', Icons.directions_car_rounded)),
              Expanded(child: _buildDetailItem('MOTORISTA', _driver?.name ?? '-', Icons.person_rounded)),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(child: _buildDetailItem('DATA', dateFormat.format(_inspection!.dateTime), Icons.calendar_today_rounded)),
              Expanded(child: _buildDetailItem('HORA', timeFormat.format(_inspection!.dateTime), Icons.access_time_rounded)),
            ],
          ),
          const Divider(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(child: _buildDetailItem('QUILOMETRAGEM', '${_inspection!.kmAtInspection} km', Icons.speed_rounded)),
              Expanded(child: _buildDetailItem('COMBUSTÍVEL', '${(_inspection!.fuelLevel * 100).toInt()}%', Icons.local_gas_station_rounded)),
            ],
          ),
          if (_inspection!.notes.isNotEmpty) ...[
            const Divider(height: AppSpacing.xxl),
            _buildDetailItem('OBSERVAÇÕES DO MOTORISTA', _inspection!.notes, Icons.notes_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
              Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GALERIA DE FOTOS',
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
          ),
          itemCount: _allRequiredPhotos.length,
          itemBuilder: (context, index) {
            final title = _allRequiredPhotos[index];
            final photo = _inspection!.photos.cast<InspectionPhoto?>().firstWhere(
              (p) => p?.title.toLowerCase() == title.toLowerCase(),
              orElse: () => null,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: photo != null ? GestureDetector(
                    onTap: () => _showFullPhoto(photo.url),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(photo.url, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(Icons.zoom_in, color: Colors.white.withValues(alpha: 0.8), size: 18),
                          ),
                        ],
                      ),
                    ),
                  ) : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_photography_outlined, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 4),
                        Text(
                          'NÃO ENVIADA',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
                color: Colors.black.withValues(alpha: 0.9),
              ),
            ),
            Image.network(url, fit: BoxFit.contain),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    final bool isCompleted = _inspection!.status != InspectionStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DECISÃO FINAL',
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              TextField(
                controller: _reasonController,
                maxLines: 3,
                readOnly: isCompleted,
                decoration: InputDecoration(
                  hintText: 'Justifique a decisão para o motorista...',
                  labelText: 'Motivo da Aprovação/Reprovação',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
              ),
              if (!isCompleted) ...[
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => _handleReview(InspectionStatus.rejected),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('REPROVAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _handleReview(InspectionStatus.approved),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('APROVAR', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Auditado por: ${_inspection!.reviewerId ?? "Sistema"}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
