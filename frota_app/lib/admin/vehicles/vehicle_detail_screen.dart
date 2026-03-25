import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';
import '../../core/widgets/status_badge.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final MockRepository _repository = MockRepository();
  Vehicle? _vehicle;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicle();
  }

  Future<void> _fetchVehicle() async {
    final v = await _repository.getVehicleById(widget.vehicleId);
    setState(() {
      _vehicle = v;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_vehicle == null) return const Scaffold(body: Center(child: Text('Veículo não encontrado')));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_vehicle!.plate),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Vehicle Visual Header
            Container(
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Image.network(
                      _vehicle!.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, size: 100, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatusBadge(label: _vehicle!.status.name, type: _getTypeByStatus(_vehicle!.status)),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _vehicle!.contractType.name.toUpperCase(),
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_vehicle!.brand} ${_vehicle!.model}',
                    style: AppTextStyles.displayMedium.copyWith(fontSize: 28),
                  ),
                  Text(
                    'Ano: ${_vehicle!.year} | ${_vehicle!.color}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  _TechnicalData(),
                  const SizedBox(height: AppSpacing.xxl),
                  
                  _StatusOverview(vehicle: _vehicle!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeType _getTypeByStatus(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available: return BadgeType.active;
      case VehicleStatus.rented: return BadgeType.neutral;
      case VehicleStatus.maintenance: return BadgeType.error;
    }
  }
}

class _TechnicalData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações Técnicas', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _InfoTile(icon: Icons.speed_outlined, label: 'Quilometragem', value: '15.420 KM')),
            Expanded(child: _InfoTile(icon: Icons.local_gas_station_outlined, label: 'Combustível', value: '80%')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _InfoTile(icon: Icons.calendar_month_outlined, label: 'Próximo IPVA', value: '10 Mai 2025')),
            Expanded(child: _InfoTile(icon: Icons.shield_outlined, label: 'Seguro', value: 'Ativo')),
          ],
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
          Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusOverview extends StatelessWidget {
  final Vehicle vehicle;
  const _StatusOverview({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Histórico e Vistorias', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _HistoryItem(
                title: 'Vistoria de Saída',
                date: '02 Mar 2024',
                description: 'Realizado por Motorista Maria Santos (98% ok)',
                icon: Icons.check_circle_outlined,
                iconColor: Colors.green,
              ),
              _DividerLine(),
              _HistoryItem(
                title: 'Manutenção Preditiva',
                date: '15 Fev 2024',
                description: 'Troca de óleo e filtro realizada',
                icon: Icons.build_circle_outlined,
                iconColor: AppColors.primary,
              ),
              _DividerLine(),
              _HistoryItem(
                title: 'Vistoria de Entrada',
                date: '01 Dez 2023',
                description: 'Novo veículo na frota',
                icon: Icons.add_circle_outline,
                iconColor: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final IconData icon;
  final Color iconColor;

  const _HistoryItem({
    required this.title,
    required this.date,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(date, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                Text(description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 16, color: AppColors.outlineVariant.withAlpha((0.1 * 255).toInt()));
  }
}
