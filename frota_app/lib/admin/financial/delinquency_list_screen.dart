import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/driver.dart';
import '../../core/widgets/status_badge.dart';

class DelinquencyListScreen extends StatefulWidget {
  const DelinquencyListScreen({super.key});

  @override
  State<DelinquencyListScreen> createState() => _DelinquencyListScreenState();
}

class _DelinquencyListScreenState extends State<DelinquencyListScreen> {
  final MockRepository _repository = MockRepository();
  List<Map<String, dynamic>> _delinquentDrivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDelinquentDrivers();
  }

  Future<void> _fetchDelinquentDrivers() async {
    final drivers = await _repository.getDrivers();
    final financials = await _repository.getFinancialEntries();

    final List<Map<String, dynamic>> result = [];

    for (var driver in drivers) {
      final unpaidEntries = financials.where((f) => f.driverId == driver.id && !f.isPaid).toList();
      if (unpaidEntries.isNotEmpty) {
        final totalDebt = unpaidEntries.fold(0.0, (sum, item) => sum + item.amount);
        result.add({
          'driver': driver,
          'totalDebt': totalDebt,
          'unpaidCount': unpaidEntries.length,
          'lastUnpaidDate': unpaidEntries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b),
        });
      }
    }

    // Sort by largest debt
    result.sort((a, b) => (b['totalDebt'] as double).compareTo(a['totalDebt'] as double));

    setState(() {
      _delinquentDrivers = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'MOTORISTAS EM ATRASO',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _delinquentDrivers.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  itemCount: _delinquentDrivers.length,
                  itemBuilder: (context, index) {
                    final data = _delinquentDrivers[index];
                    final Driver driver = data['driver'];
                    final double totalDebt = data['totalDebt'];
                    final int unpaidCount = data['unpaidCount'];
                    final DateTime lastDate = data['lastUnpaidDate'];

                    return _buildDelinquentCard(driver, totalDebt, unpaidCount, lastDate);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tudo em dia!',
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
          ),
          Text(
            'Nenhum motorista com pendência financeira.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDelinquentCard(Driver driver, double totalDebt, int unpaidCount, DateTime lastDate) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.adminDriverProfile.replaceFirst(':id', driver.id)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        driver.avatarUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.person, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$unpaidCount pendência(s) • Última em ${_formatDate(lastDate)}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                         StatusBadge(
                          label: driver.currentVehicleId != null ? 'COM VEÍCULO' : 'SEM VEÍCULO',
                          type: driver.currentVehicleId != null ? BadgeType.active : BadgeType.error,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Dívida Total',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        'R\$ ${totalDebt.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
