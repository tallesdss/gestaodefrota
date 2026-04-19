import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/maintenance_entry.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/vehicle.dart';
import '../../models/workshop.dart';
import '../../models/expense_category.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  List<Workshop> _workshops = [];
  List<ExpenseCategory> _categories = [];
  bool _isLoading = true;

  String? _selectedVehicleId;
  String? _selectedWorkshopId;

  // Categorized selection
  String? _selectedCategory;
  String? _selectedSubgroup;
  String? _selectedItem;

  late MaintenanceStatus _selectedStatus;
  late TextEditingController _descriptionController;
  late TextEditingController _kmController;
  late DateTime _selectedDate;

  // Anexos
  final List<XFile> _attachments = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _invoiceNumberController = TextEditingController();

  // List of parts/services
  final List<MaintenancePart> _parts = [];

  @override
  void initState() {
    super.initState();
    _selectedVehicleId =
        widget.maintenance?.vehicleId ?? widget.initialVehicleId;
    _selectedWorkshopId = widget.maintenance?.workshopId;
    _selectedStatus = widget.maintenance?.status ?? MaintenanceStatus.pending;
    _descriptionController = TextEditingController(
      text: widget.maintenance?.description ?? '',
    );
    _kmController = TextEditingController(
      text: widget.maintenance?.kmAtMaintenance.toString() ?? '',
    );
    _selectedDate = widget.maintenance?.date ?? DateTime.now();

    if (widget.maintenance?.parts != null) {
      _parts.addAll(widget.maintenance!.parts);
    }
    _invoiceNumberController.text = widget.maintenance?.invoiceNumber ?? '';
    _fetchData();
  }

  Future<void> _fetchData() async {
    final v = await _repository.getVehicles();
    final w = await _repository.getWorkshops();
    final c = await _repository.getExpenseCategories();
    setState(() {
      _vehicles = v;
      _workshops = w;
      _categories = c;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _kmController.dispose();
    _invoiceNumberController.dispose();
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(() {
                    _parts.add(
                      MaintenancePart(
                        name: nameController.text,
                        quantity: 1,
                        unitPrice: double.parse(valueController.text),
                      ),
                    );
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
                    _buildWorkshopDropdown(),
                    const SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader(
                      'DETALHES DO SERVIÇO',
                      Icons.build_circle_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildCategoryCascadingDropdowns(),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      _descriptionController,
                      'Descrição do Problema/Serviço',
                      Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _kmController,
                            'Odômetro (KM)',
                            Icons.speed_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildDatePicker(
                            'Data',
                            _selectedDate,
                            (d) => setState(() => _selectedDate = d),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader(
                      'PEÇAS E VALORES',
                      Icons.payments_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildPartsList(),
                    const SizedBox(height: AppSpacing.md),
                    _buildStatusDropdown(),
                    const SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader(
                      'ANEXOS E DOCUMENTAÇÃO',
                      Icons.file_present_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildTextField(
                      _invoiceNumberController,
                      'Número da Nota/Recibo (Opcional)',
                      Icons.numbers_outlined,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildAttachmentSection(),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildSubmitButton(isEditing),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      children: [
        if (_attachments.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _attachments.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(_attachments[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => setState(() => _attachments.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        InkWell(
          onTap: () async {
            final images = await _picker.pickMultiImage();
            if (images.isNotEmpty) {
              setState(() => _attachments.addAll(images));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Fazer upload de Notais/Recibos',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildWorkshopDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedWorkshopId,
      hint: const Text('Selecione a Oficina'),
      items: _workshops.map((w) {
        return DropdownMenuItem<String>(value: w.id, child: Text(w.name));
      }).toList(),
      onChanged: (val) => setState(() => _selectedWorkshopId = val),
      decoration: _inputDecoration(
        'Oficina/Executante',
        Icons.business_outlined,
      ),
      validator: (val) => val == null ? 'Obrigatório' : null,
    );
  }

  Widget _buildCategoryCascadingDropdowns() {
    // Filtrar categorias conforme solicitado pelo usuário
    final allowedCategories = ['Manutenção', 'Abastecimento', 'Limpeza e Estética'];
    final filteredCategories = _categories.where((c) => allowedCategories.contains(c.name)).toList();

    final selectedCat = filteredCategories.any((c) => c.name == _selectedCategory)
        ? filteredCategories.firstWhere((c) => c.name == _selectedCategory)
        : null;

    final subgroups = selectedCat?.subgroups ?? [];
    final selectedSG = subgroups.any((sg) => sg.name == _selectedSubgroup)
        ? subgroups.firstWhere((sg) => sg.name == _selectedSubgroup)
        : null;

    final items = selectedSG?.items ?? [];

    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          hint: const Text('Selecione a Categoria'),
          items: filteredCategories.map((c) {
            return DropdownMenuItem<String>(
              value: c.name,
              child: Row(
                children: [
                  Icon(c.icon, size: 20, color: c.color),
                  const SizedBox(width: 8),
                  Text(c.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCategory = val;
              _selectedSubgroup = null;
              _selectedItem = null;
            });
          },
          decoration: _inputDecoration(
            'Categoria de Despesa',
            Icons.label_important_outline,
          ),
          validator: (val) => val == null ? 'Obrigatório' : null,
        ),
        if (_selectedCategory != null) ...[
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _selectedSubgroup,
            hint: const Text('Selecione o Subgrupo'),
            items: subgroups.map((sg) {
              return DropdownMenuItem<String>(
                value: sg.name,
                child: Text(sg.name),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedSubgroup = val;
                _selectedItem = null;
              });
            },
            decoration: _inputDecoration('Subgrupo', Icons.folder_outlined),
            validator: (val) => val == null ? 'Obrigatório' : null,
          ),
        ],
        if (_selectedSubgroup != null) ...[
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _selectedItem,
            hint: const Text('Selecione o Item/Serviço'),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item.name,
                child: Text(item.name),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedItem = val),
            decoration: _inputDecoration(
              'Item de Manutenção',
              Icons.list_alt_outlined,
            ),
            validator: (val) => val == null ? 'Obrigatório' : null,
          ),
        ],
      ],
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
      decoration: _inputDecoration(
        'Status de Pagamento',
        Icons.verified_outlined,
      ),
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
                child: Text(
                  'Nenhuma peça ou serviço adicionado',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _parts.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final part = _parts[index];
                return ListTile(
                  title: Text(part.name, style: AppTextStyles.bodyMedium),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'R\$ ${part.value.toStringAsFixed(2)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.error,
                        ),
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
                    Text(
                      'TOTAL ESTIMADO',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R\$ ${_totalCost.toStringAsFixed(2)}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label, icon),
      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    Function(DateTime) onSelected,
  ) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) {
          onSelected(d);
        }
      },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today_outlined),
        child: Text(
          '${date.day}/${date.month}/${date.year}',
          style: AppTextStyles.labelLarge,
        ),
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
            final workshop = _workshops.firstWhere(
              (w) => w.id == _selectedWorkshopId,
            );

            // Map selected category to MaintenanceType if possible, or use 'other'
            MaintenanceType mt = MaintenanceType.other;
            if (_selectedCategory == 'Manutenção') {
              // Try to match based on subgroups for more specific types
              if (_selectedSubgroup == 'Motor') {
                mt = MaintenanceType.motor;
              }
              if (_selectedSubgroup == 'Suspensão') {
                mt = MaintenanceType.suspension;
              }
              if (_selectedSubgroup == 'Freios') {
                mt = MaintenanceType.brakes;
              }
              if (_selectedSubgroup == 'Elétrica') {
                mt = MaintenanceType.electrical;
              }
              if (_selectedSubgroup == 'Pneus') {
                mt = MaintenanceType.tires;
              }
              if (_selectedSubgroup == 'Transmissão') {
                mt = MaintenanceType.transmission;
              }
            } else if (_selectedCategory == 'Limpeza e Estética') {
              if (_selectedSubgroup == 'Funilaria') {
                mt = MaintenanceType.bodywork;
              }
            }

            final finalDescription =
                '$_selectedItem - ${_descriptionController.text}';

            final selectedVehicle = _vehicles.firstWhere(
              (v) => v.id == _selectedVehicleId,
            );

            final newEntry = MaintenanceEntry(
              id:
                  widget.maintenance?.id ??
                  'MT-${DateTime.now().millisecondsSinceEpoch}',
              companyId: selectedVehicle.companyId,
              vehicleId: _selectedVehicleId!,
              type: mt,
              description: finalDescription,
              date: _selectedDate,
              cost: _totalCost,
              kmAtMaintenance: int.parse(_kmController.text),
              workshopId: _selectedWorkshopId,
              workshop: workshop.name,
              status: _selectedStatus,
              parts: _parts,
              invoiceNumber: _invoiceNumberController.text,
              invoiceUrl:
                  _attachments.isNotEmpty ? _attachments.first.path : null,
            );

            await _repository.addMaintenance(newEntry);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Manutenção salva com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: Text(
          isEditing ? 'SALVAR ALTERAÇÕES' : 'FINALIZAR REGISTRO',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
      ),
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
