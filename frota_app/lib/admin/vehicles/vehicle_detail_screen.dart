import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';
import '../../models/financial_entry.dart';
import '../../models/driver.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final MockRepository _repository = MockRepository();
  Vehicle? _vehicle;
  List<FinancialEntry> _financials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final v = await _repository.getVehicleById(widget.vehicleId);
      final f = await _repository.getFinancialEntriesByVehicle(widget.vehicleId);
      setState(() {
        _vehicle = v;
        _financials = f;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _vehicle = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_vehicle == null) return const Scaffold(body: Center(child: Text('Veículo não encontrado')));

    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_vehicle!.plate, style: AppTextStyles.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Header Card
            _buildSectionTitle('Informações do Veículo', onEdit: _showVehicleInfoModal),
            _buildVehicleHeader(),
            const SizedBox(height: AppSpacing.xxl),

            // Current Driver Section
            _buildSectionTitle('Motorista Atual', onEdit: _showDriverModal),
            _buildCurrentDriverCard(dateFormat, timeFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Kilometrage Update
            _buildSectionTitle('Última Atualização de KM', onEdit: _showKmUpdateModal),
            _buildKmUpdateCard(dateFormat, timeFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Documents Status
            _buildSectionTitle('Vencimento de Documentos', onEdit: _showDocumentsModal),
            _buildDocumentsCard(dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Rental Value History
            _buildSectionTitle(
              'Valor do Aluguel', 
              icon: Icons.payments_outlined,
              onEdit: _showRentalValueUpdateModal,
            ),
            _buildRentalHistoryCard(currencyFormat, dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Financial Summary (Gains and Expenses)
            _buildSectionTitle(
              'Ganhos e Gastos', 
              onEdit: () => _showFinancialModal(FinancialType.income),
              onAllTap: () => context.push('/admin/financial/flow?vehicleId=${_vehicle!.id}'),
              icon: Icons.add_circle_outline,
            ),
            _buildFinancialList(currencyFormat, dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Fines List
            _buildSectionTitle(
              'Multas', 
              onEdit: () => _showFinancialModal(FinancialType.expense, category: 'multa'),
              onAllTap: () => context.push('/admin/financial/flow?vehicleId=${_vehicle!.id}'),
              icon: Icons.add_circle_outline,
            ),
            _buildFinesList(currencyFormat, dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Usage History
            _buildSectionTitle(
              'Histórico de Motoristas',
              onAllTap: () => context.push('/admin/vehicles/${_vehicle!.id}/usage'),
            ),
            _buildUsageHistory(dateFormat),
            const SizedBox(height: AppSpacing.xxl),

            // Inspection History
            _buildSectionTitle(
              'Histórico de Vistorias',
              onAllTap: () => context.push('/admin/vehicles/${_vehicle!.id}/inspections'),
            ),
            _buildInspectionHistoryPreview(dateFormat),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onEdit, IconData icon = Icons.edit_outlined, VoidCallback? onAllTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, color: AppColors.onSurface),
          ),
          Row(
            children: [
              if (onAllTap != null)
                TextButton(
                  onPressed: onAllTap,
                  child: Text(
                    'VER TUDO', 
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(icon, size: 20, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(_vehicle!.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: InkWell(
                      onTap: _showPhotoModal,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_vehicle!.brand} ${_vehicle!.model}',
                      style: AppTextStyles.headlineSmall.copyWith(fontSize: 20),
                    ),
                    Text(
                      'Ano: ${_vehicle!.year} | ${_vehicle!.color}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    StatusBadge(label: _vehicle!.status.name, type: _getTypeByStatus(_vehicle!.status)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentDriverCard(DateFormat dateFormat, DateFormat timeFormat) {
    if (_vehicle!.currentDriverName == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('Nenhum motorista vinculado no momento', style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return InkWell(
      onTap: () => context.push('/admin/drivers/profile/${_vehicle!.currentDriverId}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_vehicle!.currentDriverName!, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      Text(
                        'Vinculado em: ${dateFormat.format(_vehicle!.usageHistory.firstWhere((h) => h.driverId == _vehicle!.currentDriverId).startDate)}',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKmUpdateCard(DateFormat dateFormat, DateFormat timeFormat) {
    if (_vehicle!.lastKmUpdateDate == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Sem registros de atualização')),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_vehicle!.currentKm} KM', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
              Text(
                'Atualizado em ${dateFormat.format(_vehicle!.lastKmUpdateDate!)} às ${timeFormat.format(_vehicle!.lastKmUpdateDate!)}',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Anterior', style: AppTextStyles.labelSmall),
              Text('${_vehicle!.lastKmValue ?? "-"} KM', style: AppTextStyles.labelLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDocRow('IPVA', _vehicle!.ipvaExpiry, dateFormat),
          _buildDocDivider(),
          _buildDocRow('Seguro', _vehicle!.insuranceExpiry, dateFormat),
          _buildDocDivider(),
          _buildDocRow('Licenciamento', _vehicle!.licensingExpiry, dateFormat),
        ],
      ),
    );
  }

  Widget _buildDocRow(String label, DateTime expiry, DateFormat dateFormat) {
    final isExpired = expiry.isBefore(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isExpired ? Icons.warning_amber_rounded : Icons.description_outlined,
              color: isExpired ? Colors.orange : AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.labelLarge),
          ],
        ),
        Text(
          dateFormat.format(expiry),
          style: AppTextStyles.labelLarge.copyWith(
            color: isExpired ? Colors.orange : AppColors.onSurface,
            fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDocDivider() => Divider(height: 24, color: AppColors.outlineVariant.withValues(alpha: 0.2));

  Widget _buildFinancialList(NumberFormat currencyFormat, DateFormat dateFormat) {
    final transactions = _financials.where((f) => f.category != 'multa').toList();
    if (transactions.isEmpty) {
      return _buildEmptyCard('Sem movimentações financeiras');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final f = transactions[index];
          final isIncome = f.type == FinancialType.income;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              child: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            title: Text(f.description, style: AppTextStyles.labelLarge),
            subtitle: Text(dateFormat.format(f.date), style: AppTextStyles.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormat.format(f.amount),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFinancialModal(f.type, entry: f),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinesList(NumberFormat currencyFormat, DateFormat dateFormat) {
    final fines = _financials.where((f) => f.category == 'multa').toList();
    if (fines.isEmpty) {
      return _buildEmptyCard('Nenhuma multa registrada');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: fines.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final f = fines[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: const Icon(Icons.gavel_outlined, color: Colors.orange, size: 18),
            ),
            title: Text(f.description, style: AppTextStyles.labelLarge),
            subtitle: Text(dateFormat.format(f.date), style: AppTextStyles.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(currencyFormat.format(f.amount), style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      f.isPaid ? 'PAGO' : 'PENDENTE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: f.isPaid ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showFinancialModal(FinancialType.expense, category: 'multa', entry: f),
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageHistory(DateFormat dateFormat) {
    if (_vehicle!.usageHistory.isEmpty) {
      return _buildEmptyCard('Sem histórico de uso');
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _vehicle!.usageHistory.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final h = _vehicle!.usageHistory[index];
          final isActive = h.endDate == null;
          return ListTile(
            leading: Icon(
              isActive ? Icons.timeline : Icons.history,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            title: Text(h.driverName, style: AppTextStyles.labelLarge.copyWith(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(
              '${dateFormat.format(h.startDate)} - ${h.endDate != null ? dateFormat.format(h.endDate!) : "Atual"}',
              style: AppTextStyles.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${h.startKm} KM', style: AppTextStyles.labelSmall),
                if (h.endKm != null) Text('${h.endKm} KM', style: AppTextStyles.labelSmall),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInspectionHistoryPreview(DateFormat dateFormat) {
    // Hardcoded preview for now, consistent with DriverProfile
    final inspections = [
      {'type': 'CHECK-IN', 'date': '12/03/2026', 'km': '15.420', 'status': 'APROVADO'},
    ];

    return Column(
      children: inspections.map((i) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              i['type'] == 'CHECK-IN' ? Icons.login_rounded : Icons.logout_rounded,
              color: i['type'] == 'CHECK-IN' ? AppColors.success : AppColors.secondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i['type']!, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
                  Text('KM: ${i['km']}', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(i['date']!, style: AppTextStyles.labelSmall),
                Text(
                  i['status']!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRentalHistoryCard(NumberFormat currencyFormat, DateFormat dateFormat) {
    if (_vehicle!.rentalHistory.isEmpty && _vehicle!.rentalValue == null) {
      return _buildEmptyCard('Sem histórico de aluguel');
    }

    final history = _vehicle!.rentalHistory.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Valor Atual', style: AppTextStyles.labelSmall),
                  Text(
                    _vehicle!.rentalValue != null ? currencyFormat.format(_vehicle!.rentalValue) : 'Não definido',
                    style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              AppButton(
                label: 'Alterar Valor',
                onPressed: _showRentalValueUpdateModal,
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
          if (history.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            Text('Histórico de Alterações', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length > 3 ? 3 : history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = history[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(currencyFormat.format(item.value), style: AppTextStyles.bodyMedium),
                    Text(dateFormat.format(item.date), style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                );
              },
            ),
            if (history.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Optionally implement a full history screen
                    },
                    child: Text('Ver Histórico Completo', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(text, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
      ),
    );
  }

  void _showVehicleInfoModal() {
    final brandController = TextEditingController(text: _vehicle!.brand);
    final modelController = TextEditingController(text: _vehicle!.model);
    final yearController = TextEditingController(text: _vehicle!.year.toString());
    final plateController = TextEditingController(text: _vehicle!.plate);
    final colorController = TextEditingController(text: _vehicle!.color);

    AppDialogs.showBottomSheet(
      context: context,
      title: 'Editar Informações',
      content: Column(
        children: [
          AppTextField(label: 'Marca', controller: brandController),
          const SizedBox(height: 16),
          AppTextField(label: 'Modelo', controller: modelController),
          const SizedBox(height: 16),
          AppTextField(label: 'Ano', controller: yearController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          AppTextField(label: 'Cor', controller: colorController),
          const SizedBox(height: 16),
          AppTextField(label: 'Placa', controller: plateController),
        ],
      ),
      actions: [
        AppButton(
          label: 'Salvar Alterações',
          onPressed: () {
            setState(() {
              _vehicle = _vehicle!.copyWith(
                brand: brandController.text,
                model: modelController.text,
                year: int.tryParse(yearController.text) ?? _vehicle!.year,
                plate: plateController.text,
                color: colorController.text,
              );
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showRentalValueUpdateModal() {
    final rentalController = TextEditingController(text: _vehicle!.rentalValue?.toString() ?? '');
    AppDialogs.showBottomSheet(
      context: context,
      title: 'Alterar Valor do Aluguel',
      content: Column(
        children: [
          AppTextField(
            label: 'Novo Valor do Aluguel',
            controller: rentalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money,
            hintText: '0,00',
          ),
          const SizedBox(height: 16),
          Text(
            'Ao alterar o valor, a data da mudança será registrada no histórico do veículo.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Confirmar Alteração',
          onPressed: () {
            final newValue = double.tryParse(rentalController.text.replaceAll(',', '.')) ?? 0;
            if (newValue > 0) {
              final newHistory = List<RentalValueHistory>.from(_vehicle!.rentalHistory);
              if (_vehicle!.rentalValue != null) {
                newHistory.add(RentalValueHistory(
                  value: _vehicle!.rentalValue!,
                  date: DateTime.now(),
                ));
              }
              
              setState(() {
                _vehicle = _vehicle!.copyWith(
                  rentalValue: newValue,
                  rentalHistory: newHistory,
                );
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Valor do aluguel atualizado com sucesso!')),
              );
            }
          },
        ),
      ],
    );
  }

  void _showKmUpdateModal() {
    final kmController = TextEditingController(text: _vehicle!.currentKm.toString());
    AppDialogs.showBottomSheet(
      context: context,
      title: 'Atualizar Quilometragem',
      content: Column(
        children: [
          AppTextField(
            label: 'KM Atual',
            controller: kmController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.speed,
          ),
          const SizedBox(height: 16),
          Text(
            'A quilometragem anterior era de ${_vehicle!.currentKm} KM. Certifique-se de que o novo valor seja maior.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Atualizar KM',
          onPressed: () {
            final newKm = int.tryParse(kmController.text) ?? _vehicle!.currentKm;
            setState(() {
              _vehicle = _vehicle!.copyWith(
                lastKmValue: _vehicle!.currentKm,
                currentKm: newKm,
                lastKmUpdateDate: DateTime.now(),
              );
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showPhotoModal() {
    final urlController = TextEditingController(text: _vehicle!.imageUrl);
    AppDialogs.showBottomSheet(
      context: context,
      title: 'Editar Foto do Veículo',
      content: Column(
        children: [
          AppTextField(label: 'URL da Imagem', controller: urlController, hintText: 'https://exemplo.com/foto.jpg'),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(_vehicle!.imageUrl, height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Atualizar Foto',
          onPressed: () {
            setState(() {
              _vehicle = _vehicle!.copyWith(imageUrl: urlController.text);
            });
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void _showDriverModal() async {
    final List<Driver> drivers = await _repository.getDrivers();
    if (!mounted) return;
    
    AppDialogs.showBottomSheet(
      context: context,
      title: 'Vincular Novo Motorista',
      content: SizedBox(
        height: 400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Selecione um motorista da lista abaixo para vincular a este veículo.', style: AppTextStyles.bodySmall),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: drivers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  final isCurrent = driver.id == _vehicle!.currentDriverId;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrent ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.person_outline, size: 20, color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driver.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                              Text('CPF: ${driver.cpf}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        AppButton(
                          label: isCurrent ? 'Atual' : 'Selecionar',
                          onPressed: isCurrent ? null : () {
                            setState(() {
                              _vehicle = _vehicle!.copyWith(
                                currentDriverId: driver.id,
                                currentDriverName: driver.name,
                              );
                            });
                            Navigator.pop(context);
                          },
                          variant: isCurrent ? AppButtonVariant.ghost : AppButtonVariant.primary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentsModal() {
    Future<void> selectDate(BuildContext context, DateTime initialDate, Function(DateTime) onSelected) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) onSelected(picked);
    }

    AppDialogs.showBottomSheet(
      context: context,
      title: 'Datas de Vencimento',
      content: Column(
        children: [
          _buildDateEditTile('IPVA', _vehicle!.ipvaExpiry, (date) => setState(() => _vehicle = _vehicle!.copyWith(ipvaExpiry: date)), selectDate),
          _buildDateEditTile('Seguro', _vehicle!.insuranceExpiry, (date) => setState(() => _vehicle = _vehicle!.copyWith(insuranceExpiry: date)), selectDate),
          _buildDateEditTile('Licenciamento', _vehicle!.licensingExpiry, (date) => setState(() => _vehicle = _vehicle!.copyWith(licensingExpiry: date)), selectDate),
        ],
      ),
      actions: [
        AppButton(label: 'Concluir', onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildDateEditTile(String label, DateTime date, Function(DateTime) onSelected, Function selectDate) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: AppTextStyles.labelLarge),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(date), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
      trailing: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
      onTap: () => selectDate(context, date, onSelected),
    );
  }

  void _showFinancialModal(FinancialType type, {String? category, FinancialEntry? entry}) {
    final descController = TextEditingController(text: entry?.description);
    final amountController = TextEditingController(text: entry?.amount.toString());
    bool isPaidLocal = entry?.isPaid ?? false;

    AppDialogs.showBottomSheet(
      context: context,
      title: entry != null 
          ? 'Editar Registro' 
          : (category == 'multa' ? 'Novo Lançamento de Multa' : 'Nova Movimentação'),
      content: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Descrição / Motivo', controller: descController, hintText: 'Ex: Troca de Óleo, Multa por velocidade...'),
              const SizedBox(height: 16),
              AppTextField(label: r'Valor (R$)', controller: amountController, keyboardType: TextInputType.number, prefixIcon: Icons.attach_money),
              const SizedBox(height: 24),
              Text('Status de Pagamento', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => isPaidLocal = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isPaidLocal ? AppColors.errorContainer.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: !isPaidLocal ? AppColors.error : AppColors.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(
                            'PENDENTE', 
                            style: AppTextStyles.labelMedium.copyWith(
                              color: !isPaidLocal ? AppColors.error : AppColors.onSurfaceVariant,
                              fontWeight: !isPaidLocal ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setModalState(() => isPaidLocal = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isPaidLocal ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isPaidLocal ? Colors.green : AppColors.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(
                            'PAGO', 
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isPaidLocal ? Colors.green : AppColors.onSurfaceVariant,
                              fontWeight: isPaidLocal ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
      actions: [
        AppButton(
          label: entry != null ? 'Salvar Edição' : 'Salvar Registro',
          onPressed: () {
            if (descController.text.isEmpty || amountController.text.isEmpty) return;
            
            final updatedAmount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
            
            setState(() {
              if (entry != null) {
                final index = _financials.indexWhere((f) => f.id == entry.id);
                if (index != -1) {
                  _financials[index] = entry.copyWith(
                    description: descController.text,
                    amount: updatedAmount,
                    isPaid: isPaidLocal,
                  );
                }
              } else {
                final newEntry = FinancialEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  vehicleId: widget.vehicleId,
                  description: descController.text,
                  amount: updatedAmount,
                  type: category == 'multa' ? FinancialType.expense : type,
                  category: category ?? 'manutenção',
                  date: DateTime.now(),
                  isPaid: isPaidLocal,
                );
                _financials.insert(0, newEntry);
              }
            });
            Navigator.pop(context);
          },
        ),
      ],
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
