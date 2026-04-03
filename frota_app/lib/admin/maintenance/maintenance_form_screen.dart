import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/maintenance_entry.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';
import '../../models/driver.dart';

class MaintenanceFormScreen extends StatefulWidget {
  final MaintenanceEntry? maintenance;
  final String? initialVehicleId;

  const MaintenanceFormScreen({
    super.key,
    this.maintenance,
    this.initialVehicleId,
  });

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MockRepository _repository = MockRepository();

  List<Vehicle> _vehicles = [];
  List<Driver> _drivers = [];
  bool _isLoading = true;

  String? _selectedVehicleId;
  String? _selectedDriverId;
  late MaintenanceType _selectedType;
  late MaintenanceStatus _selectedStatus;
  late TextEditingController _descriptionController;
  late TextEditingController _kmController;
  late TextEditingController _workshopController;
  late DateTime _selectedDate;
  
  // List of parts/services
  final List<MaintenancePart> _parts = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    
    _selectedVehicleId = widget.maintenance?.vehicleId ?? widget.initialVehicleId;
    _selectedDriverId = widget.maintenance?.driverId;
    _selectedType = widget.maintenance?.type ?? MaintenanceType.oilChange;
    _selectedStatus = widget.maintenance?.status ?? MaintenanceStatus.pending;
    _descriptionController = TextEditingController(text: widget.maintenance?.description ?? '');
    _kmController = TextEditingController(text: widget.maintenance?.kmAtMaintenance.toString() ?? '');
    _workshopController = TextEditingController(text: widget.maintenance?.workshop ?? '');
    _selectedDate = widget.maintenance?.date ?? DateTime.now();
    
    if (widget.maintenance?.parts != null) {
      _parts.addAll(widget.maintenance!.parts);
    }
  }

  Future<void> _fetchData() async {
    final v = await _repository.getVehicles();
    final d = await _repository.getDrivers();
    setState(() {
      _vehicles = v;
      _drivers = d;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmController.dispose();
    _workshopController.dispose();
    super.dispose();
  }

  double get _totalCost => _parts.fold(0, (sum, part) => sum + part.value);

  void _addPart() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final valueController = TextEditingController();
        return AlertDialog(
          title: const Text('Adicionar Peça/Serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && valueController.text.isNotEmpty) {
                  setState(() {
                    _parts.add(MaintenancePart(
                      name: nameController.text,
                      quantity: 1,
                      unitPrice: double.parse(valueController.text),
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('IDENTIFICAÇÃO', Icons.fingerprint),
                    const SizedBox(height: AppSpacing.md),
                    _buildVehicleDropdown(),
                    const SizedBox(height: AppSpacing.md),
                    _buildDriverDropdown(),
                    const SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader('DETALHES DO SERVIÇO', Icons.build_circle_outlined),
                    const SizedBox(height: AppSpacing.md),
                    _buildTypeDropdown(),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(_descriptionController, 'Descrição do Problema/Serviço', Icons.description_outlined, maxLines: 3),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_kmController, 'Odômetro (KM)', Icons.speed_outlined, keyboardType: TextInputType.number)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _buildDatePicker('Data', _selectedDate, (d) => setState(() => _selectedDate = d))),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(_workshopController, 'Oficina/Executante', Icons.business_outlined),
                    const SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader('PEÇAS E VALORES', Icons.payments_outlined),
                    const SizedBox(height: AppSpacing.md),
                    _buildPartsList(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatusDropdown(),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildSubmitButton(isEditing),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedVehicleId,
      hint: const Text('Selecione o Veículo'),
      items: _vehicles.map((v) {
        return DropdownMenuItem<String>(
          value: v.id,
          child: Text('${v.brand} ${v.model} (${v.plate})'),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedVehicleId = val),
      decoration: _inputDecoration('Veículo', Icons.directions_car_outlined),
      validator: (val) => val == null ? 'Obrigatório' : null,
    );
  }

  Widget _buildDriverDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDriverId,
      hint: const Text('Selecione o Motorista Responsável'),
      items: _drivers.map((d) {
        return DropdownMenuItem<String>(
          value: d.id,
          child: Text(d.name),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedDriverId = val),
      decoration: _inputDecoration('Motorista', Icons.person_outline),
      validator: (val) => val == null ? 'Obrigatório' : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<MaintenanceType>(
      initialValue: _selectedType,
      items: MaintenanceType.values.map((e) {
        return DropdownMenuItem<MaintenanceType>(
          value: e,
          child: Text(e.label),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedType = val!),
      decoration: _inputDecoration('Tipo de Manutenção', Icons.category_outlined),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<MaintenanceStatus>(
      initialValue: _selectedStatus,
      items: MaintenanceStatus.values.map((e) {
        return DropdownMenuItem<MaintenanceStatus>(
          value: e,
          child: Text(e.label),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedStatus = val!),
      decoration: _inputDecoration('Status de Pagamento', Icons.verified_outlined),
    );
  }

  Widget _buildPartsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          if (_parts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text('Nenhuma peça ou serviço adicionado', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parts.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final part = _parts[index];
                return ListTile(
                  title: Text(part.name, style: AppTextStyles.bodyMedium),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('R\$ ${part.value.toStringAsFixed(2)}', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                        onPressed: () => setState(() => _parts.removeAt(index)),
                      ),
                    ],
                  ),
                );
              },
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL ESTIMADO', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                    Text('R\$ ${_totalCost.toStringAsFixed(2)}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _addPart,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('ADICIONAR PEÇA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.onSecondaryContainer,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildSubmitButton(bool isEditing) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final driverName = _drivers.firstWhere((d) => d.id == _selectedDriverId).name;
            final workshop = _workshopController.text;

            final newEntry = MaintenanceEntry(
              id: widget.maintenance?.id ?? 'MT-${DateTime.now().millisecondsSinceEpoch}',
              vehicleId: _selectedVehicleId!,
              type: _selectedType,
              description: _descriptionController.text,
              date: _selectedDate,
              cost: _totalCost,
              kmAtMaintenance: int.parse(_kmController.text),
              workshopId: 'WORK-001', // Mock workshop ID
              workshop: workshop,
              status: _selectedStatus,
              driverId: _selectedDriverId!,
              driverName: driverName,
              parts: _parts,
              invoiceUrl: 'https://example.com/invoice.pdf',
            );

            await _repository.addMaintenance(newEntry);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manutenção salva com sucesso!'), backgroundColor: Colors.green),
              );
              Navigator.pop(context, true);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: Text(
          isEditing ? 'SALVAR ALTERAÇÕES' : 'FINALIZAR REGISTRO',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
      filled: true,
      fillColor: AppColors.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
