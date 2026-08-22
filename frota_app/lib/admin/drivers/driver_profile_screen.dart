import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../core/repositories/financial_repository.dart';
import '../../core/repositories/inspection_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../models/driver.dart';
import '../../models/vehicle.dart';
import '../../models/financial_entry.dart';
import '../../models/timeline_item.dart';
import '../../models/inspection.dart';
import '../../models/contract.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/routes/app_routes.dart';

class DriverProfileScreen extends StatefulWidget {
  final String driverId;

  const DriverProfileScreen({super.key, required this.driverId});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final DriverRepository _driverRepository = DriverRepository();
  final VehicleRepository _vehicleRepository = VehicleRepository();
  final FinancialRepository _financialRepository = FinancialRepository();
  final InspectionRepository _inspectionRepository = InspectionRepository();
  final ContractRepository _contractRepository = ContractRepository();

  Driver? _driver;
  Vehicle? _currentVehicle;
  Contract? _activeContract;
  List<TimelineItem> _timelineItems = [];
  List<FinancialEntry> _financialEntries = [];
  List<Inspection> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final driver = await _driverRepository.getDriverById(widget.driverId);

      Vehicle? vehicle;
      Contract? activeContract;
      List<Contract> contracts = [];
      try {
        contracts = await _contractRepository.getContracts(driverId: widget.driverId);
        if (contracts.isNotEmpty) {
          final active = contracts.where((c) => c.status == ContractStatus.active).toList();
          if (active.isNotEmpty) {
            activeContract = active.first;
          }
        }
      } catch (_) {}

      final vehicleIdToFetch = driver?.currentVehicleId ?? activeContract?.vehicleId;
      if (vehicleIdToFetch != null && vehicleIdToFetch.isNotEmpty) {
        try {
          vehicle = await _vehicleRepository.getVehicleById(vehicleIdToFetch);
        } catch (_) {}
      }

      List<FinancialEntry> financials = [];
      try {
        financials = await _financialRepository.getFinancialEntries(driverId: widget.driverId);
      } catch (_) {}

      List<TimelineItem> timeline = [];
      try {
        timeline = await _driverRepository.getDriverTimeline(driverId: widget.driverId, page: 1, pageSize: 5);
      } catch (_) {}

      List<Inspection> inspections = [];
      try {
        inspections = await _inspectionRepository.getInspections(driverId: widget.driverId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _driver = driver;
          _currentVehicle = vehicle;
          _activeContract = activeContract;
          _financialEntries = financials;
          _timelineItems = timeline;
          _inspections = inspections;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _driver = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_driver == null) {
      return const Scaffold(
        body: Center(child: Text('Motorista não encontrado')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'PERFIL DO MOTORISTA',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),

            _buildFinanceStats(),
            const SizedBox(height: AppSpacing.xl),

            _buildVehicleUsage(),
            const SizedBox(height: AppSpacing.xl),

            _buildDocumentsAndContracts(),
            const SizedBox(height: AppSpacing.xl),

            _buildActivityTimeline(),
            const SizedBox(height: AppSpacing.xl),

            _buildInspectionHistory(),
            const SizedBox(height: AppSpacing.xl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hasAvatar = _driver!.avatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: hasAvatar ? NetworkImage(_driver!.avatarUrl) : null,
            backgroundColor: AppColors.surfaceContainerLow,
            child: !hasAvatar
                ? const Icon(Icons.person, size: 40, color: AppColors.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _driver!.name.isNotEmpty ? _driver!.name : _driver!.email,
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  _driver!.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (_driver!.phone.isNotEmpty)
                  Text(
                    _driver!.phone,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    StatusBadge(
                      label: _driver!.status == DriverStatus.active
                          ? 'ATIVO'
                          : (_driver!.status == DriverStatus.pendingApproval
                              ? 'PENDENTE'
                              : 'INATIVO'),
                      type: _driver!.status == DriverStatus.active
                          ? BadgeType.active
                          : (_driver!.status == DriverStatus.pendingApproval
                              ? BadgeType.warning
                              : BadgeType.error),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(
                      label: _driver!.type.name.toUpperCase(),
                      type: BadgeType.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _showEditProfileDialog(),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('EDITAR PERFIL'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              side: const BorderSide(color: AppColors.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceStats() {
    final totalReceived = _financialEntries
        .where((e) => e.type == FinancialType.income && e.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);

    final pendingDebts = _financialEntries
        .where((e) => e.type == FinancialType.income && !e.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);

    final saldoDevedor = _driver!.outstandingBalance > 0
        ? _driver!.outstandingBalance
        : pendingDebts;

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DESEMPENHO FINANCEIRO'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showPaymentHistoryModal(),
                  child: StatCard(
                    title: 'TOTAL RENDIDO',
                    value: currencyFormat.format(totalReceived),
                    icon: Icons.payments_outlined,
                    iconColor: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'SALDO DEVEDOR',
                value: currencyFormat.format(saldoDevedor),
                icon: Icons.warning_amber_rounded,
                iconColor: saldoDevedor > 0 ? AppColors.error : AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'VALOR A PAGAR',
                icon: Icons.money_off_csred_outlined,
                onPressed: () => _showDebtModal(),
                variant: AppButtonVariant.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: 'PAGAMENTO',
                icon: Icons.add_card,
                onPressed: () => _showPaymentModal(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showPaymentModal() {
    final amountController = TextEditingController();
    bool isLate = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Informar Pagamento', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Informe o valor pago por ${_driver!.name.isNotEmpty ? _driver!.name : _driver!.email}',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Valor (R\$)',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.attach_money,
                hintText: '0,00',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Pago com atraso?',
                  style: AppTextStyles.bodyMedium,
                ),
                value: isLate,
                onChanged: (val) {
                  setModalState(() {
                    isLate = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancelar',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Salvar',
                      onPressed: () async {
                        final amountText = amountController.text.replaceAll(
                          ',',
                          '.',
                        );
                        final amount = double.tryParse(amountText) ?? 0.0;
                        if (amount > 0) {
                          final entry = FinancialEntry(
                            id: '',
                            type: FinancialType.income,
                            category: 'aluguel',
                            driverId: _driver!.id,
                            vehicleId: _driver!.currentVehicleId ?? _currentVehicle?.id,
                            amount: amount,
                            date: DateTime.now(),
                            description:
                                'Pagamento de ${isLate ? "aluguel com atraso" : "aluguel"}',
                            isPaid: true,
                            isLate: isLate,
                          );

                          try {
                            await _financialRepository.createFinancialEntry(entry);
                          } catch (_) {}

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Pagamento de R\$ ${amount.toStringAsFixed(2)} salvo com sucesso!',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadData();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDebtModal() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController(text: 'Aluguel');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informar Valor a Pagar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Informe o valor que ${_driver!.name.isNotEmpty ? _driver!.name : _driver!.email} deve pagar',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: 'Valor (R\$)',
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.attach_money,
                hintText: '0,00',
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descrição',
                controller: descriptionController,
                prefixIcon: Icons.description_outlined,
                hintText: 'Ex: Aluguel, Multa, Manutenção...',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancelar',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Salvar',
                      onPressed: () async {
                        final amountText = amountController.text.replaceAll(
                          ',',
                          '.',
                        );
                        final amount = double.tryParse(amountText) ?? 0.0;
                        if (amount > 0) {
                          final entry = FinancialEntry(
                            id: '',
                            type: FinancialType.income,
                            category: descriptionController.text.toLowerCase(),
                            driverId: _driver!.id,
                            vehicleId: _driver!.currentVehicleId ?? _currentVehicle?.id,
                            amount: amount,
                            date: DateTime.now(),
                            description:
                                'Valor a pagar informado: ${descriptionController.text}',
                            isPaid: false,
                          );

                          try {
                            await _financialRepository.createFinancialEntry(entry);
                          } catch (_) {}

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Débito de R\$ ${amount.toStringAsFixed(2)} registrado com sucesso!',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            _loadData();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentHistoryModal() {
    final paidEntries = _financialEntries
        .where((e) => e.type == FinancialType.income && e.isPaid)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    AppDialogs.showBottomSheet(
      context: context,
      title: 'Histórico de Pagamentos',
      content: paidEntries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('Nenhum pagamento registrado.'),
              ),
            )
          : SizedBox(
              height: 400,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: paidEntries.length,
                itemBuilder: (context, index) {
                  final entry = paidEntries[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: entry.isLate
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            entry.isLate
                                ? Icons.history
                                : Icons.check_circle_outline,
                            color: entry.isLate
                                ? AppColors.error
                                : AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(entry.amount)}',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(entry.date),
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (entry.isLate)
                          StatusBadge(label: 'ATRASO', type: BadgeType.error)
                        else
                          StatusBadge(label: 'OK', type: BadgeType.success),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildVehicleUsage() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'VEÍCULO ATUAL & HISTÓRICO'),
        const SizedBox(height: AppSpacing.md),
        if (_currentVehicle != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.push(
                AppRoutes.adminVehicleDetail.replaceFirst(
                  ':id',
                  _currentVehicle!.id,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.onPrimaryContainer,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentVehicle!.brand} ${_currentVehicle!.model}',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Placa: ${_currentVehicle!.plate}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (_activeContract != null) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'CONTRATO ATIVO',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            dateFormat.format(_activeContract!.startDate),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Nenhum veículo vinculado atualmente',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentsAndContracts() {
    final cnhUrl = _driver!.cnhFrontUrl ?? _driver!.cnhBackUrl;
    final residenceUrl = _driver!.residenceProofUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'DOCUMENTAÇÃO & CONTRATOS'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildDocItem(
              'CNH Digital',
              Icons.badge_outlined,
              onTap: cnhUrl != null && cnhUrl.isNotEmpty
                  ? () => _showDocumentDialog('CNH Digital', cnhUrl, isEditable: true)
                  : null,
            ),
            _buildDocItem(
              'Comprovante Residência',
              Icons.home_outlined,
              onTap: residenceUrl != null && residenceUrl.isNotEmpty
                  ? () => _showDocumentDialog('Comprovante Residência', residenceUrl, isEditable: true)
                  : null,
            ),
            _buildDocItem(
              'Contrato Assinado',
              Icons.description_outlined,
              onTap: _activeContract != null && _activeContract!.signatureUrl != null
                  ? () => _showDocumentDialog('Contrato Assinado', _activeContract!.signatureUrl!)
                  : null,
            ),
            _buildDocItem(
              'Termos de Uso',
              Icons.gavel_outlined,
              onTap: () => _showTermsOfUseDialog(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocItem(String label, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width:
            (MediaQuery.of(context).size.width -
                (AppSpacing.xl * 2) -
                AppSpacing.md) /
            2,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap != null
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onTap != null
                      ? AppColors.onSurface
                      : AppColors.outlineVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.outlineVariant,
              ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDialog(
    String title,
    String imageUrl, {
    bool isEditable = false,
  }) {
    AppDialogs.showModal(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: AppColors.surfaceContainerLow,
              child: imageUrl.startsWith('data:image')
                  ? Image.memory(
                      base64Decode(imageUrl.split(',').last),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 48,
                            color: AppColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Arquivo do documento cadastrado.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _driver!.name);
    final emailController = TextEditingController(text: _driver!.email);
    final phoneController = TextEditingController(text: _driver!.phone);
    final cityController = TextEditingController(text: _driver!.city);
    final cnhController = TextEditingController(text: _driver!.cnhNumber);
    final categoryController = TextEditingController(
      text: _driver!.cnhCategory,
    );

    AppDialogs.showModal(
      context: context,
      title: 'Editar Perfil',
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              'Nome Completo',
              nameController,
              Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField('E-mail', emailController, Icons.email_outlined),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Telefone',
                    phoneController,
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTextField(
                    'Cidade',
                    cityController,
                    Icons.location_city_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Nº CNH',
                    cnhController,
                    Icons.badge_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildTextField(
                    'Categoria',
                    categoryController,
                    Icons.fact_check_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '⚠️ Alterações serão salvas no Supabase.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final updatedDriver = _driver!.copyWith(
              name: nameController.text,
              email: emailController.text,
              phone: phoneController.text,
              city: cityController.text,
              cnhNumber: cnhController.text,
              cnhCategory: categoryController.text,
            );

            setState(() {
              _driver = updatedDriver;
            });
            Navigator.pop(context);

            try {
              await _driverRepository.updateDriver(updatedDriver);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil atualizado com sucesso!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            } catch (_) {}
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  void _showTermsOfUseDialog() {
    AppDialogs.showModal(
      context: context,
      title: 'Termos de Uso',
      content: SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: Text(
            'Ao utilizar a plataforma Architect Fleet, o motorista concorda com os seguintes termos:\n\n'
            '1. Responsabilidade pelo Veículo: O motorista é integralmente responsável pela conservação, limpeza e manutenção básica do veículo locado.\n\n'
            '2. Pagamentos e Repasses: As mensalidades e seguros devem ser quitados rigorosamente nas datas previstas no contrato de locação.\n\n'
            '3. Uso do Aplicativo: O motorista compromete-se a manter seus dados cadastrais, documentos e vistorias sempre atualizados.\n\n'
            '4. Conduta Ética: Espera-se do motorista uma conduta profissional e respeitosa com os gestores e demais usuários da rede.\n\n'
            '5. Monitoramento: O veículo poderá estar equipado com dispositivos de telemetria e geolocalização para fins de segurança e gestão de frota.\n\n'
            'Qualquer violação destes termos poderá resultar no bloqueio de acesso ao sistema e rescisão contratual.',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Estou de acordo'),
        ),
      ],
    );
  }

  Widget _buildActivityTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'LINHA DO TEMPO',
          actionLabel: 'VER TUDO',
          onActionTap: () => context.push(
            AppRoutes.adminDriverTimeline.replaceFirst(':id', widget.driverId),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_timelineItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhuma atividade recente',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._timelineItems.map(
            (a) => _buildTimelineItem(
              DateFormat('dd/MM/yyyy').format(a.date),
              a.title,
              a.description,
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineItem(String date, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                desc,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionHistory() {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'HISTÓRICO DE VISTORIAS',
          actionLabel: 'VER TUDO',
          onActionTap: () =>
              context.push('/admin/drivers/${widget.driverId}/inspections'),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_inspections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nenhuma vistoria registrada',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ..._inspections.take(3).map(
            (i) {
              final isCheckin = i.type == InspectionType.checkin;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCheckin
                          ? Icons.login_rounded
                          : Icons.logout_rounded,
                      color: isCheckin
                          ? AppColors.success
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCheckin ? 'CHECK-IN' : 'CHECK-OUT',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('KM: ${i.kmAtInspection}', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(dateFormat.format(i.dateTime), style: AppTextStyles.labelSmall),
                        Text(
                          i.status.name.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: i.status == InspectionStatus.approved
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
