import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/contract.dart';
import '../../models/vehicle.dart';
import '../../models/driver.dart';

class ContractFormScreen extends StatefulWidget {
  final Contract? contract;
  const ContractFormScreen({super.key, this.contract});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockRepository _repository = MockRepository();

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  bool _isLoadingLists = true;

  String? _selectedVehicleId;
  String? _selectedDriverId;
  late TextEditingController _weeklyValueController;
  late TextEditingController _monthlyValueController;
  late DateTime _startDate;
  late DateTime _endDate;
  late ContractStatus _selectedStatus;
  late bool _depositPaid;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _fetchLists();
    _selectedVehicleId = widget.contract?.vehicleId;
    _selectedDriverId = widget.contract?.driverId;
    _weeklyValueController = TextEditingController(text: widget.contract?.weeklyValue.toString() ?? '');
    _monthlyValueController = TextEditingController(text: widget.contract?.monthlyValue.toString() ?? '');
    _startDate = widget.contract?.startDate ?? DateTime.now();
    _endDate = widget.contract?.endDate ?? DateTime.now().add(const Duration(days: 365));
    _selectedStatus = widget.contract?.status ?? ContractStatus.active;
    _depositPaid = widget.contract?.depositPaid ?? false;
    _selectedType = widget.contract?.type ?? 'UBER';
  }

  Future<void> _fetchLists() async {
    final v = await _repository.getVehicles();
    final d = await _repository.getDrivers();
    setState(() {
      _vehicles = v;
      _drivers = d;
      _isLoadingLists = false;
    });
  }

  @override
  void dispose() {
    _weeklyValueController.dispose();
    _monthlyValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contract != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDITAR CONTRATO' : 'NOVO CONTRATO',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingLists
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('VÍNCULO OPERACIONAL'),
                      const SizedBox(height: AppSpacing.md),
                      _buildVehicleDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDriverDropdown(),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('REGRAS FINANCEIRAS'),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_weeklyValueController, 'Valor Semanal', Icons.payments_outlined, keyboardType: TextInputType.number)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildTextField(_monthlyValueController, 'Valor Mensal', Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildDropdown<String>(
                        label: 'Tipo de Contrato',
                        initialValue: _selectedType,
                        items: ['UBER', 'PREFEITURA'],
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('DATAS E VIGÊNCIA'),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _buildDatePicker('Data Início', _startDate, (d) => setState(() => _startDate = d))),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildDatePicker('Data Fim', _endDate, (d) => setState(() => _endDate = d))),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('CONFIGURAÇÕES'),
                      const SizedBox(height: AppSpacing.md),
                      _buildDropdown<ContractStatus>(
                        label: 'Status do Contrato',
                        initialValue: _selectedStatus,
                        items: ContractStatus.values,
                        onChanged: (val) => setState(() => _selectedStatus = val!),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SwitchListTile(
                        title: Text('Caução Pago?', style: AppTextStyles.labelLarge),
                        value: _depositPaid,
                        onChanged: (val) => setState(() => _depositPaid = val),
                        activeThumbColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _selectedVehicleId != null && _selectedDriverId != null) {
                              Navigator.pop(context);
                            } else if (_selectedVehicleId == null || _selectedDriverId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Selecione um veículo e um motorista')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'SALVAR CONTRATO' : 'CRIAR CONTRATO',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedVehicleId,
      hint: const Text('Selecione um Veículo'),
      items: _vehicles.map((v) {
        return DropdownMenuItem<String>(
          value: v.id,
          child: Text('${v.brand} ${v.model} (${v.plate})'),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedVehicleId = val),
      decoration: _inputDecoration('Veículo', Icons.directions_car_outlined),
    );
  }

  Widget _buildDriverDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDriverId,
      hint: const Text('Selecione um Motorista'),
      items: _drivers.map((d) {
        return DropdownMenuItem<String>(
          value: d.id,
          child: Text(d.name),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedDriverId = val),
      decoration: _inputDecoration('Motorista', Icons.person_outline),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) onSelected(d);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today_outlined),
        child: Text(DateFormat('dd/MM/yyyy').format(date), style: AppTextStyles.labelLarge),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T initialValue,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(e.toString().split('.').last.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(label, Icons.settings_outlined),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
