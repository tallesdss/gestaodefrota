import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/driver.dart';
import '../../models/financial_entry.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final MockRepository _repository = MockRepository();
  List<Driver> _drivers = [];
  List<Driver> _filteredDrivers = [];
  bool _isLoading = true;
  String _selectedCity = 'Todas';
  List<String> _cities = ['Todas'];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final list = await _repository.getDrivers();
    setState(() {
      _drivers = list;
      _filteredDrivers = list;
      _isLoading = false;
      // Extract unique cities
      final citySet = list.map((d) => d.city).whereType<String>().toSet();
      _cities = ['Todas', ...citySet];
    });
  }

  void _applyFilter(String city) {
    setState(() {
      _selectedCity = city;
      if (city == 'Todas') {
        _filteredDrivers = _drivers;
      } else {
        _filteredDrivers = _drivers.where((d) => d.city == city).toList();
      }
    });
  }

  void _showPaymentModal(Driver driver) {
    final amountController = TextEditingController();

    AppDialogs.showBottomSheet(
      context: context,
      title: 'Informar Pagamento',
      content: Column(
        children: [
          Text(
            'Informe o valor pago por ${driver.name}',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Valor (R\$)',
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.attach_money,
            hintText: '0,00',
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Salvar Pagamento',
          onPressed: () async {
            final amount =
                double.tryParse(amountController.text.replaceAll(',', '.')) ??
                0;
            if (amount > 0) {
              final entry = FinancialEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                companyId: driver.companyId,
                type: FinancialType.income,
                category: 'aluguel',
                driverId: driver.id,
                vehicleId: driver.currentVehicleId,
                amount: amount,
                date: DateTime.now(),
                description: 'Pagamento informado de ${driver.name}',
                isPaid: true,
              );

              await _repository.addFinancialEntry(entry);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pagamento de R\$ ${amount.toStringAsFixed(2)} salvo com sucesso!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  void _showDebtModal(Driver driver) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController(text: 'Aluguel');

    AppDialogs.showBottomSheet(
      context: context,
      title: 'Informar Valor a Pagar',
      content: Column(
        children: [
          Text(
            'Informe o valor que ${driver.name} deve pagar',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Valor (R\$)',
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        ],
      ),
      actions: [
        AppButton(
          label: 'Salvar Débito',
          onPressed: () async {
            final amount =
                double.tryParse(amountController.text.replaceAll(',', '.')) ??
                0;
            if (amount > 0) {
              final entry = FinancialEntry(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                companyId: driver.companyId,
                type: FinancialType.expense,
                category: descriptionController.text.toLowerCase(),
                driverId: driver.id,
                vehicleId: driver.currentVehicleId,
                amount: amount,
                date: DateTime.now(),
                description:
                    'Valor a pagar informado: ${descriptionController.text}',
                isPaid: false,
              );

              await _repository.addFinancialEntry(entry);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Débito de R\$ ${amount.toStringAsFixed(2)} registrado com sucesso!',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'MOTORISTAS',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.onSurface),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // City Filter Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Cidade:', style: AppTextStyles.labelMedium),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCity,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              items: _cities.map((city) {
                                return DropdownMenuItem(
                                  value: city,
                                  child: Text(
                                    city,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) _applyFilter(value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Drivers List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _filteredDrivers[index];
                      final hasCar = driver.currentVehicleId != null;

                      return GestureDetector(
                        onTap: () {
                          if (driver.isApproved) {
                            context.push(
                              AppRoutes.adminDriverProfile.replaceFirst(
                                ':id',
                                driver.id,
                              ),
                            );
                          } else {
                            context.push(
                              '${AppRoutes.adminRegistrationAudit}?id=${driver.id}',
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.onSurface.withValues(
                                  alpha: 0.04,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Highlighted Driver Photo
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: hasCar
                                        ? AppColors.success.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.outlineVariant,
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
                                      child: const Icon(
                                        Icons.person,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          driver.name,
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (hasCar) ...[
                                          const SizedBox(width: 8),
                                          Tooltip(
                                            message: 'Ver Veículo',
                                            child: GestureDetector(
                                              onTap: () => context.push(
                                                AppRoutes.adminVehicleDetail
                                                    .replaceFirst(
                                                      ':id',
                                                      driver.currentVehicleId!,
                                                    ),
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .directions_car_filled_rounded,
                                                  size: 18,
                                                  color: AppColors.success,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${driver.city ?? 'Não info.'} • ${driver.email}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        StatusBadge(
                                          label: driver.isApproved
                                              ? 'APROVADO'
                                              : 'PENDENTE',
                                          type: driver.isApproved
                                              ? BadgeType.active
                                              : BadgeType.warning,
                                        ),
                                        const SizedBox(width: 8),
                                        StatusBadge(
                                          label: hasCar
                                              ? 'COM VEÍCULO'
                                              : 'SEM VEÍCULO',
                                          type: hasCar
                                              ? BadgeType.active
                                              : BadgeType.error,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              IconButton(
                                icon: const Icon(
                                  Icons.money_off_csred_outlined,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showDebtModal(driver),
                                tooltip: 'Informar Valor a Pagar',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.payments_outlined,
                                  color: Colors.green,
                                ),
                                onPressed: () => _showPaymentModal(driver),
                                tooltip: 'Informar Pagamento',
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.outlineVariant,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.adminDriverForm),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }
}
