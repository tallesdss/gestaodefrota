import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../core/repositories/financial_repository.dart';
import '../../core/repositories/timeline_repository.dart';
import '../../models/driver.dart';
import '../../models/contract.dart';
import '../../models/financial_entry.dart';
import '../../models/timeline_item.dart';

import '../../core/repositories/vehicle_repository.dart';
import '../../models/vehicle.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final FinancialRepository _financialRepo = FinancialRepository();
  final TimelineRepository _timelineRepo = TimelineRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();

  Driver? _driver;
  Contract? _activeContract;
  Vehicle? _vehicle;
  List<FinancialEntry> _pendingDebts = [];
  List<TimelineItem> _timeline = [];
  bool _isLoading = true;
  String _driverName = 'Motorista';

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);
    try {
      final uid = _authRepo.currentUserId;
      if (uid != null) {
        final profile = await _authRepo.getCurrentProfile();
        if (profile != null && profile['nome'] != null) {
          _driverName = profile['nome'].toString();
        }

        final driver = await _driverRepo.getDriverById(uid);
        final contract = await _contractRepo.getActiveContractByDriver(uid);
        Vehicle? vehicle;
        final vehicleId = (contract != null && contract.vehicleId.isNotEmpty)
            ? contract.vehicleId
            : driver?.currentVehicleId;
        if (vehicleId != null && vehicleId.isNotEmpty) {
          vehicle = await _vehicleRepo.getVehicleById(vehicleId);
        }
        final debts = await _financialRepo.getFinancialEntries(driverId: uid, status: 'pendente');
        final timeline = await _timelineRepo.getDriverTimeline(driverId: uid, page: 1, pageSize: 4);

        if (mounted) {
          setState(() {
            _driver = driver;
            _activeContract = contract;
            _vehicle = vehicle;
            _pendingDebts = debts;
            _timeline = timeline;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPending = _pendingDebts.fold(0.0, (acc, item) => acc + item.amount);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDriverData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) const LinearProgressIndicator(),
              if (_isLoading) const SizedBox(height: AppSpacing.md),
              _buildHeader(context),
              const SizedBox(height: AppSpacing.xl),
              _buildVehicleStatusCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildFinancialSummaryCard(context, totalPending),
              const SizedBox(height: AppSpacing.lg),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.lg),
              _buildActivityTimeline(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BEM-VINDO,',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            Text(_driver?.name.isNotEmpty == true ? _driver!.name : _driverName, style: AppTextStyles.headlineMedium),
          ],
        ),
        GestureDetector(
          onTap: () => context.push(AppRoutes.driverNotifications),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: const AppIcon(
              icon: Icons.notifications_active_outlined,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleStatusCard() {
    final hasVehicle = _vehicle != null;
    final modelName = hasVehicle ? '${_vehicle!.brand} ${_vehicle!.model}' : 'Nenhum Veículo Vinculado';
    final plateStr = hasVehicle
        ? 'PLACA: ${_vehicle!.plate}'
        : (_activeContract != null
            ? 'Contrato: ${_activeContract!.contractNumber}'
            : 'Sem Contrato Ativo');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VEÍCULO EM POSSE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modelName,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: hasVehicle ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plateStr,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: hasVehicle ? AppColors.primary : AppColors.onSurfaceVariant.withAlpha(150),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                icon: Icons.directions_car_outlined,
                color: hasVehicle ? AppColors.primary : AppColors.onSurfaceVariant.withAlpha(120),
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Quilometragem',
                  hasVehicle ? '${_vehicle!.currentKm} KM' : '--',
                  Icons.speed_outlined,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Pontuação Confiança',
                  '${_driver?.trustScore ?? 100} pts',
                  Icons.shield_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Row(
      children: [
        AppIcon(icon: icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialSummaryCard(BuildContext context, double totalPending) {
    final hasPending = totalPending > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SITUAÇÃO FINANCEIRA',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasPending ? AppColors.error : AppColors.success).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasPending ? 'Pendente' : 'Em Dia',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasPending ? AppColors.error : AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'R\$ ${totalPending.toStringAsFixed(2)}',
            style: AppTextStyles.headlineMedium.copyWith(
              color: hasPending ? AppColors.error : AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Pagar com PIX',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    if (_pendingDebts.isNotEmpty) {
                      context.push(
                        AppRoutes.driverPixCheckout,
                        extra: _pendingDebts.first,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Você não possui débitos pendentes no momento.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: 'Extrato',
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.push(AppRoutes.driverFinancialStatement),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AÇÕES RÁPIDAS',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              'Vistoria 360',
              Icons.camera_alt_outlined,
              () => context.push(AppRoutes.driverInspectionCheckIn),
            ),
            _buildActionButton(
              'Documentos',
              Icons.folder_shared_outlined,
              () => context.push(AppRoutes.driverDocuments),
            ),
            _buildActionButton(
              'Ocorrência',
              Icons.warning_amber_outlined,
              () => context.push(AppRoutes.driverOccurrenceReport),
            ),
            _buildActionButton(
              'Suporte',
              Icons.help_outline,
              () => context.push(AppRoutes.driverSupport),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AppIcon(icon: icon, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ATIVIDADE RECENTE',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.driverActivityTimeline),
              child: Text(
                'Ver tudo',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_timeline.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Nenhuma atividade recente registrada.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._timeline.map(
            (t) => _buildTimelineItem(
              t.title,
              t.description,
              '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')} às ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}',
              Icons.notifications_active_outlined,
              AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon: icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
