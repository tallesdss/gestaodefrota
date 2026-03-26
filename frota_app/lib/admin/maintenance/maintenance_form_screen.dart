import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/maintenance_entry.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';

class MaintenanceFormScreen extends StatefulWidget {
  final MaintenanceEntry? maintenance;
  const MaintenanceFormScreen({super.key, this.maintenance});

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockRepository _repository = MockRepository();

  List<Vehicle> _vehicles = [];
  bool _isLoadingVehicles = true;

  String? _selectedVehicleId;
  late MaintenanceType _selectedType;
  late TextEditingController _descriptionController;
  late TextEditingController _kmController;
  late TextEditingController _costController;
  late TextEditingController _workshopController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
    _selectedVehicleId = widget.maintenance?.vehicleId;
    _selectedType = widget.maintenance?.type ?? MaintenanceType.oilChange;
    _descriptionController = TextEditingController(text: widget.maintenance?.description ?? '');
    _kmController = TextEditingController(text: widget.maintenance?.kmAtMaintenance.toString() ?? '');
    _costController = TextEditingController(text: widget.maintenance?.cost.toString() ?? '');
    _workshopController = TextEditingController(text: widget.maintenance?.workshop ?? '');
    _selectedDate = widget.maintenance?.date ?? DateTime.now();
  }

  Future<void> _fetchVehicles() async {
    final v = await _repository.getVehicles();
    setState(() {
      _vehicles = v;
      _isLoadingVehicles = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.maintenance != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDITAR MANUTENÇÃO' : 'REGISTRAR MANUTENÇÃO',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingVehicles
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('IDENTIFICAÇÃO'),
                      const SizedBox(height: AppSpacing.md),
                      _buildVehicleDropdown(),
                      const SizedBox(height: AppSpacing.md),
                      _buildDropdown<MaintenanceType>(
                        label: 'Tipo de Serviço',
                        initialValue: _selectedType,
                        items: MaintenanceType.values,
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('DETALHES TÉCNICOS'),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(_descriptionController, 'Descrição do Serviço', Icons.description_outlined, maxLines: 3),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(child: _buildTextField(_kmController, 'KM Atual', Icons.speed_outlined, keyboardType: TextInputType.number)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: _buildTextField(_costController, 'Custo (R\$)', Icons.payments_outlined, keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildTextField(_workshopController, 'Oficina/Parceiro', Icons.business_outlined),
                      const SizedBox(height: AppSpacing.md),
                      _buildDatePicker('Data da Execução', _selectedDate, (d) => setState(() => _selectedDate = d)),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _selectedVehicleId != null) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            isEditing ? 'SALVAR ALTERAÇÕES' : 'CONFIRMAR REGISTRO',
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
        child: Text('${date.day}/${date.month}/${date.year}', style: AppTextStyles.labelLarge),
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
      decoration: _inputDecoration(label, Icons.category_outlined),
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
