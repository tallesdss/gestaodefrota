import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/driver.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;
  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cpfController;
  late TextEditingController _cnhNumberController;
  late TextEditingController _cnhCategoryController;
  late DriverType _selectedType;
  late DriverStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.driver?.name ?? '');
    _emailController = TextEditingController(text: widget.driver?.email ?? '');
    _phoneController = TextEditingController(text: widget.driver?.phone ?? '');
    _cpfController = TextEditingController(text: widget.driver?.cpf ?? '');
    _cnhNumberController = TextEditingController(
      text: widget.driver?.cnhNumber ?? '',
    );
    _cnhCategoryController = TextEditingController(
      text: widget.driver?.cnhCategory ?? '',
    );
    _selectedType = widget.driver?.type ?? DriverType.uber;
    _selectedStatus = widget.driver?.status ?? DriverStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _cnhNumberController.dispose();
    _cnhCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.driver != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDITAR MOTORISTA' : 'NOVO MOTORISTA',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('DADOS PESSOAIS'),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  _nameController,
                  'Nome Completo',
                  Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  _emailController,
                  'E-mail',
                  Icons.email_outlined,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _phoneController,
                        'Telefone',
                        Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        _cpfController,
                        'CPF',
                        Icons.badge_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('DADOS DA CNH'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _cnhNumberController,
                        'Número CNH',
                        Icons.card_membership_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        _cnhCategoryController,
                        'Categoria',
                        Icons.category_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('CONFIGURAÇÕES'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown<DriverType>(
                  label: 'Tipo de Motorista',
                  value: _selectedType,
                  items: DriverType.values,
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown<DriverStatus>(
                  label: 'Status',
                  value: _selectedStatus,
                  items: DriverStatus.values,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR MOTORISTA',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.onPrimary,
                      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Campo obrigatório' : null,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(e.toString().split('.').last.toUpperCase()),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
