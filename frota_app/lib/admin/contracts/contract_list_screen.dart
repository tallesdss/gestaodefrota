import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/contract.dart';
import '../../core/widgets/status_badge.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  final MockRepository _repository = MockRepository();
  List<Contract> _contracts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchContracts();
  }

  Future<void> _fetchContracts() async {
    final list = await _repository.getContracts();
    setState(() {
      _contracts = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'CONTRATOS',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ListView.builder(
                itemCount: _contracts.length,
                itemBuilder: (context, index) {
                  final contract = _contracts[index];
                  return GestureDetector(
                    onTap: () => context.push(AppRoutes.adminContractForm, extra: contract),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.article_outlined, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Vínculo: ${contract.vehicleId} - ${contract.driverId}', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                                    Text(contract.type, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: _getStatusLabel(contract.status),
                                type: _getBadgeType(contract.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo('INÍCIO', _formatDate(contract.startDate)),
                              _buildInfo('FIM', _formatDate(contract.endDate)),
                              _buildInfo('VALOR/MES', 'R\$ ${contract.monthlyValue.toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.adminContractForm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusLabel(ContractStatus status) {
    switch (status) {
      case ContractStatus.active: return 'VIGENTE';
      case ContractStatus.expired: return 'EXPIRADO';
      case ContractStatus.cancelled: return 'CANCELADO';
    }
  }

  BadgeType _getBadgeType(ContractStatus status) {
    switch (status) {
      case ContractStatus.active: return BadgeType.active;
      case ContractStatus.expired: return BadgeType.warning;
      case ContractStatus.cancelled: return BadgeType.error;
    }
  }
}
