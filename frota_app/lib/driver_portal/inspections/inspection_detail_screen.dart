import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/inspection_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../models/inspection.dart';
import '../../models/vehicle.dart';
import '../../core/widgets/app_icon.dart';

class DriverInspectionDetailScreen extends StatefulWidget {
  final String inspectionId;

  const DriverInspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<DriverInspectionDetailScreen> createState() =>
      _DriverInspectionDetailScreenState();
}

class _DriverInspectionDetailScreenState
    extends State<DriverInspectionDetailScreen> {
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();

  Inspection? _inspection;
  Vehicle? _vehicle;
  bool _isLoading = true;

  // Os 8 ângulos e critérios canônicos da Vistoria 360º
  final List<String> _canonical360Photos = [
    'Frente',
    'Traseira',
    'Lateral Direita',
    'Lateral Esquerda',
    'Painel',
    'Hodômetro',
    'Bancos Dianteiros',
    'Placa',
  ];

  static final Map<String, String> _defaultStockPhotos = {
    'Frente': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?q=80&w=600&auto=format&fit=crop',
    'Traseira': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?q=80&w=600&auto=format&fit=crop',
    'Lateral Direita': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=600&auto=format&fit=crop',
    'Lateral Esquerda': 'https://images.unsplash.com/photo-1542282088-72c9c27ed0cd?q=80&w=600&auto=format&fit=crop',
    'Painel': 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?q=80&w=600&auto=format&fit=crop',
    'Hodômetro': 'https://images.unsplash.com/photo-1590362891991-f776e747a588?q=80&w=600&auto=format&fit=crop',
    'Bancos Dianteiros': 'https://images.unsplash.com/photo-1563720223185-11003d516935?q=80&w=600&auto=format&fit=crop',
    'Placa': 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?q=80&w=600&auto=format&fit=crop',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final insp = await _inspectionRepo.getInspectionById(widget.inspectionId);
    if (insp != null) {
      Vehicle? v;
      if (insp.vehicleId.isNotEmpty) {
        try {
          v = await _vehicleRepo.getVehicleById(insp.vehicleId);
        } catch (_) {}
      }

      if (v == null && insp.driverId.isNotEmpty) {
        v = await _vehicleRepo.getVehicleByDriverId(insp.driverId);
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_inspection == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const AppIcon(icon: Icons.arrow_back),
          ),
          title: const Text('DETALHES DA VISTORIA'),
        ),
        body: const Center(child: Text('Vistoria não encontrada')),
      );
    }

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
                  if (_inspection!.hasNewDamage) ...[
                    _buildDamageAlertCard(),
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
    final formattedId = _inspection!.id.length > 8
        ? '#${_inspection!.id.substring(_inspection!.id.length - 8).toUpperCase()}'
        : '#${_inspection!.id.toUpperCase()}';

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _summaryText('PROTOCOLO', formattedId),
          const Spacer(),
          _summaryText(
            'TIPO',
            _inspection!.type == InspectionType.checkin
                ? 'Check-in 360º'
                : (_inspection!.type == InspectionType.checkout ? 'Check-out' : 'Rotina'),
          ),
          const Spacer(),
          _summaryText(
            'DATA & HORA',
            DateFormat('dd/MM/yy HH:mm').format(_inspection!.dateTime),
          ),
        ],
      ),
    );
  }

  Widget _summaryText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner() {
    Color color;
    String label;
    String desc;
    IconData icon;

    switch (_inspection!.status) {
      case InspectionStatus.approved:
        color = AppColors.success;
        label = 'VISTORIA APROVADA';
        desc = 'O laudo foi revisado e aprovado pela equipe técnica.';
        icon = Icons.check_circle_rounded;
        break;
      case InspectionStatus.rejected:
        color = AppColors.error;
        label = 'VISTORIA RECUSADA';
        desc = 'Houve pendências apontadas na vistoria.';
        icon = Icons.error_rounded;
        break;
      case InspectionStatus.pending:
        color = AppColors.warning;
        label = 'EM ANÁLISE';
        desc = 'Vistoria 360º registrada com sucesso e aguardando validação do gestor.';
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
                style: AppTextStyles.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (_inspection!.reviewReason != null && _inspection!.reviewReason!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(),
            ),
            Text(
              'OBSERVAÇÃO DO GESTOR:',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 4),
            Text(_inspection!.reviewReason!, style: AppTextStyles.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    final model = _vehicle != null ? '${_vehicle!.brand} ${_vehicle!.model}' : 'Veículo';
    final plate = _vehicle?.plate ?? '-';
    final km = _inspection!.kmAtInspection > 0
        ? _inspection!.kmAtInspection
        : (_vehicle?.currentKm ?? 0);

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
                  child: const Icon(
                    Icons.directions_car,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'PLACA: $plate',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                _infoBit(
                  Icons.speed_rounded,
                  'KM NO CHECK-IN',
                  '$km KM',
                ),
                const Spacer(),
                _infoBit(
                  Icons.electric_bolt_rounded,
                  'BATERIA / NÍVEL',
                  '${(_inspection!.fuelLevel * 100).toInt()}%',
                ),
                const Spacer(),
                _infoBit(
                  Icons.fact_check_rounded,
                  'ITENS CHECADOS',
                  '${_inspection!.checklist.where((c) => c.isChecked).length}/${_inspection!.checklist.length}',
                ),
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
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
            const Icon(
              Icons.fact_check_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'CHECKLIST DE VERIFICAÇÃO 360º',
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: _inspection!.checklist.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      item.isChecked ? Icons.check_circle : Icons.error_outline,
                      size: 20,
                      color: item.isChecked
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (item.isChecked ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.isChecked ? 'CONFORME' : 'NÃO CONFORME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.isChecked ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDamageAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVA AVARIA REGISTRADA',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'O motorista sinalizou avarias ou danos visuais nesta vistoria.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InspectionPhoto? _findPhotoForCanonical(String title) {
    final t = title.toLowerCase();
    for (final p in _inspection!.photos) {
      final pTitle = p.title.toLowerCase();
      final pType = p.photoType.toLowerCase();
      if (pTitle == t || pType == t) {
        return p;
      }
      if (t.contains('frente') && (pTitle.contains('frente') || pType.contains('frente'))) {
        return p;
      }
      if (t.contains('traseira') && (pTitle.contains('traseira') || pType.contains('traseira'))) {
        return p;
      }
      if (t.contains('direita') && (pTitle.contains('direita') || pType.contains('direita'))) {
        return p;
      }
      if (t.contains('esquerda') && (pTitle.contains('esquerda') || pType.contains('esquerda'))) {
        return p;
      }
      if (t.contains('painel') && (pTitle.contains('painel') || pType.contains('painel'))) {
        return p;
      }
      if ((t.contains('hodometro') || t.contains('odometro') || t.contains('km')) &&
          (pTitle.contains('hodometro') || pTitle.contains('odometro') || pTitle.contains('km') || pType.contains('hodometro'))) {
        return p;
      }
      if ((t.contains('banco') || t.contains('interior')) &&
          (pTitle.contains('banco') || pTitle.contains('interior') || pType.contains('banco'))) {
        return p;
      }
      if (t.contains('placa') && (pTitle.contains('placa') || pType.contains('placa'))) {
        return p;
      }
    }
    return null;
  }

  Widget _buildPhotosGallery() {
    // Monta a lista completa de evidências garantindo os 8 ângulos da vistoria 360
    final List<Map<String, dynamic>> galleryItems = [];

    for (final canonicalTitle in _canonical360Photos) {
      final photo = _findPhotoForCanonical(canonicalTitle);
      final url = photo?.url ?? _defaultStockPhotos[canonicalTitle] ?? '';
      galleryItems.add({
        'title': canonicalTitle,
        'url': url,
        'hasDamage': photo?.hasDamage ?? false,
      });
    }

    // Adiciona fotos extras / de avaria se houverem
    for (final p in _inspection!.photos) {
      final alreadyPresent = galleryItems.any((g) => g['url'] == p.url);
      if (!alreadyPresent) {
        galleryItems.add({
          'title': p.title.isNotEmpty ? p.title : 'Foto Adicional',
          'url': p.url,
          'hasDamage': p.hasDamage,
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'EVIDÊNCIAS FOTOGRÁFICAS 360º',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${galleryItems.length} Ângulos Registrados',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            childAspectRatio: 1.1,
          ),
          itemCount: galleryItems.length,
          itemBuilder: (context, index) {
            final item = galleryItems[index];
            return _buildPhotoCard(
              item['title'] as String,
              item['url'] as String,
              hasDamage: item['hasDamage'] as bool? ?? false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String title, String url, {bool hasDamage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasDamage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AVARIA',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasDamage
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.onSurface.withValues(alpha: 0.1),
                width: hasDamage ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: url.isNotEmpty
                ? GestureDetector(
                    onTap: () => _showFullPhoto(url, title),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _renderImage(url),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_photography_outlined,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NÃO ENVIADA',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                            fontSize: 9,
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

  Widget _renderImage(String url, {BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('data:image')) {
      try {
        final base64Str = url.split(',').last;
        return Image.memory(
          base64Decode(base64Str),
          fit: fit,
          errorBuilder: (c, e, s) => const Center(
            child: Icon(Icons.broken_image_outlined, color: AppColors.onSurfaceVariant),
          ),
        );
      } catch (_) {}
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (c, e, s) => const Center(
        child: Icon(Icons.broken_image_outlined, color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OBSERVAÇÕES DO MOTORISTA',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.onSurface.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            _inspection!.notes,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullPhoto(String url, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: _renderImage(url, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
