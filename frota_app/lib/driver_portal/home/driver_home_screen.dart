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
import '../payments/widgets/receipt_upload_dialog.dart';

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
  List<FinancialEntry> _allDebts = [];
  List<FinancialEntry> _pendingDebts = [];
  List<TimelineItem> _timeline = [];
  bool _isLoading = true;
  String _driverName = 'Motorista';

  @override
  void initState() {
    super.initState();
    FinancialRepository.entriesChangedNotifier.addListener(_onFinancialUpdated);
    _loadDriverData();
  }

  @override
  void dispose() {
    FinancialRepository.entriesChangedNotifier.removeListener(_onFinancialUpdated);
    super.dispose();
  }

  void _onFinancialUpdated() {
    if (mounted) {
      _loadDriverData();
    }
  }

  Future<void> _loadDriverData() async {
    setState(() => _isLoading = true);
    try {
      final uid = _authRepo.currentUserId;
      if (uid == null || uid.isEmpty) {
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      final profile = await _authRepo.getCurrentProfile();
      final driver = await _driverRepo.getDriverById(uid);
      final contract = await _contractRepo.getActiveContractByDriver(uid);

      if (driver != null && driver.name.isNotEmpty) {
        _driverName = driver.name;
      } else if (profile != null && profile['nome'] != null) {
        _driverName = profile['nome'].toString();
      }

      Vehicle? vehicle;
      final vehicleId = (contract != null && contract.vehicleId.isNotEmpty)
          ? contract.vehicleId
          : driver?.currentVehicleId;
      if (vehicleId != null && vehicleId.isNotEmpty) {
        vehicle = await _vehicleRepo.getVehicleById(vehicleId);
      }
      vehicle ??= await _vehicleRepo.getVehicleByDriverId(uid);

      List<FinancialEntry> debts = await _financialRepo.getFinancialEntries(driverId: uid);
      if (debts.isEmpty && contract != null) {
        debts = await _financialRepo.getFinancialEntries(driverId: contract.driverId);
      }
      final timeline = await _timelineRepo.getDriverTimeline(driverId: uid, page: 1, pageSize: 4);

      if (mounted) {
        setState(() {
          _driver = driver;
          _activeContract = contract;
          _vehicle = vehicle;
          _allDebts = debts;
          _pendingDebts = debts.where((e) => !e.isPaid).toList();
          _timeline = timeline;
          _isLoading = false;
        });
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
              _buildPaymentHistorySection(context),
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
    final lateDebts = _allDebts.where((e) => !e.isPaid && e.isLate).toList();
    final upcomingDebts = _allDebts.where((e) => !e.isPaid && !e.isLate).toList();
    final totalLate = lateDebts.fold(0.0, (acc, item) => acc + item.amount);
    final hasLate = lateDebts.isNotEmpty;
    final hasPending = totalPending > 0;

    if (hasLate) {
      final firstLate = lateDebts.first;
      final daysOverdue = DateTime.now().difference(firstLate.date).inDays;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFC92A2A), Color(0xFFE03131)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ALUGUEL EM ATRASO!',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${lateDebts.length} FATURA(S) ATRASADA(S)',
                    style: const TextStyle(
                      color: Color(0xFFC92A2A),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'R\$ ${totalLate.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vencimento: ${firstLate.date.day.toString().padLeft(2, '0')}/${firstLate.date.month.toString().padLeft(2, '0')}/${firstLate.date.year} (${daysOverdue > 0 ? "$daysOverdue dias de atraso" : "venceu hoje"}). Regularize para evitar bloqueio.',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await context.push(
                        AppRoutes.driverPixCheckout,
                        extra: firstLate,
                      );
                      if (res == true) _loadDriverData();
                    },
                    icon: const Icon(Icons.qr_code_scanner, color: Color(0xFFC92A2A)),
                    label: const Text(
                      'PAGAR PARCELA ATRASADA',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC92A2A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_pendingDebts.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final res = await context.push(
                      AppRoutes.driverPixCheckout,
                      extra: _pendingDebts,
                    );
                    if (res == true) _loadDriverData();
                  },
                  icon: const Icon(Icons.all_inclusive, color: Colors.white, size: 18),
                  label: Text(
                    'QUITAR TUDO DE UMA VEZ (R\$ ${totalPending.toStringAsFixed(2)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (hasPending) {
      final nextEntry = upcomingDebts.isNotEmpty ? upcomingDebts.first : _pendingDebts.first;
      final daysToDue = nextEntry.date.difference(DateTime.now()).inDays;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
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
                  'PRÓXIMO VENCIMENTO DO ALUGUEL',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daysToDue <= 0 ? 'VENCE HOJE' : 'EM $daysToDue DIA(S)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'R\$ ${nextEntry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${nextEntry.description} • Vencimento: ${nextEntry.date.day.toString().padLeft(2, '0')}/${nextEntry.date.month.toString().padLeft(2, '0')}/${nextEntry.date.year}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final res = await context.push(
                        AppRoutes.driverPixCheckout,
                        extra: nextEntry,
                      );
                      if (res == true) _loadDriverData();
                    },
                    icon: const Icon(Icons.qr_code, color: AppColors.primary),
                    label: const Text(
                      'PAGAR PARCELA COM PIX',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_pendingDebts.length > 1) ...[
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final res = await context.push(
                      AppRoutes.driverPixCheckout,
                      extra: _pendingDebts,
                    );
                    if (res == true) _loadDriverData();
                  },
                  icon: const Icon(Icons.payments_outlined, color: Colors.white, size: 18),
                  label: Text(
                    'PAGAR TUDO DE UMA VEZ (R\$ ${totalPending.toStringAsFixed(2)})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Todas as parcelas pagas
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
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
                'SITUAÇÃO DO ALUGUEL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '100% EM DIA',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tudo em Dia!',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Você não possui parcelas de aluguel pendentes ou em atraso.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Ver Histórico Completo',
            variant: AppButtonVariant.ghost,
            onPressed: () => context.push(AppRoutes.driverFinancialStatement),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistorySection(BuildContext context) {
    if (_allDebts.isEmpty) return const SizedBox.shrink();

    final rentalCycle = _activeContract?.billingFrequency?.toUpperCase() ?? 'SEMANAL';
    final rentalVal = _activeContract?.weeklyValue ?? 750.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HISTÓRICO DE PAGAMENTO DO ALUGUEL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$rentalCycle • R\$ ${rentalVal.toStringAsFixed(2)} / período',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.driverFinancialStatement),
              child: const Text('Ver Extrato', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _allDebts.length.clamp(0, 6),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = _allDebts[index];
            final dateStr =
                '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';

            final statusColor = item.isPaid
                ? Colors.green
                : (item.isLate ? AppColors.error : AppColors.secondary);

            final statusLabel = item.isPaid
                ? 'PAGO'
                : (item.isUnderReview
                    ? 'EM ANÁLISE'
                    : (item.isLate ? 'ATRASADO' : 'A VENCER'));

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: item.isLate && !item.isPaid
                      ? AppColors.error.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (item.isPaid
                                  ? Colors.green
                                  : (item.isLate ? AppColors.error : AppColors.primary))
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.isPaid
                              ? Icons.check
                              : (item.isLate ? Icons.warning : Icons.calendar_today),
                          color: item.isPaid
                              ? Colors.green
                              : (item.isLate ? AppColors.error : AppColors.primary),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Vencimento: $dateStr',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: item.isLate && !item.isPaid
                                    ? AppColors.error
                                    : AppColors.onSurfaceVariant,
                                fontWeight: item.isLate && !item.isPaid
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${item.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              color: item.isLate && !item.isPaid
                                  ? AppColors.error
                                  : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (item.isUnderReview ? Colors.blue : statusColor)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: item.isUnderReview ? Colors.blue : statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!item.isPaid) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final res = await context.push(
                                AppRoutes.driverPixCheckout,
                                extra: item,
                              );
                              if (res == true) _loadDriverData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.isLate ? AppColors.error : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Pagar (PIX)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ReceiptUploadDialog.show(
                                context,
                                entry: item,
                                onUploaded: _loadDriverData,
                              );
                            },
                            icon: const Icon(Icons.attach_file, size: 14),
                            label: Text(
                              item.isUnderReview ? 'Comprovante' : 'Anexar Comprovante',
                              style: const TextStyle(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
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
              isEnabled: _activeContract != null,
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

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, {bool isEnabled = true}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ação bloqueada. Requer contrato ativo.')),
        );
      },
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
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
          ..._timeline.take(4).map(
            (t) {
              IconData icon = Icons.notifications_active_outlined;
              Color color = AppColors.primary;

              final type = t.type?.toLowerCase() ?? '';
              final title = t.title.toLowerCase();

              if (type == 'vistoria' || title.contains('vistoria')) {
                icon = Icons.camera_alt_outlined;
                color = const Color(0xFF00897B); // Teal
              } else if (type == 'ocorrencia' || title.contains('ocorr')) {
                icon = Icons.warning_amber_rounded;
                color = AppColors.warning;
              } else if (type == 'veiculo' || title.contains('veículo') || title.contains('veiculo')) {
                icon = Icons.directions_car_filled_outlined;
                color = AppColors.primary;
              } else if (type == 'km' || title.contains('km') || title.contains('hodômetro')) {
                icon = Icons.speed_outlined;
                color = const Color(0xFF1976D2); // Blue
              } else if (type == 'pagamento' || title.contains('pagamento') || title.contains('pix')) {
                icon = Icons.check_circle_outline;
                color = AppColors.success;
              }

              return _buildTimelineItem(
                t.title,
                t.description,
                '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')} às ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}',
                icon,
                color,
              );
            },
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
