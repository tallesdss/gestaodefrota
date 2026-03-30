import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manager.dart';

class ManagerFormScreen extends StatefulWidget {
  final Manager? manager;
  const ManagerFormScreen({super.key, this.manager});

  @override
  State<ManagerFormScreen> createState() => _ManagerFormScreenState();
}

class _ManagerFormScreenState extends State<ManagerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cpfController;
  late ManagerStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.manager?.name ?? '');
    _emailController = TextEditingController(text: widget.manager?.email ?? '');
    _phoneController = TextEditingController(text: widget.manager?.phone ?? '');
    _cpfController = TextEditingController(text: widget.manager?.cpf ?? '');
    _selectedStatus = widget.manager?.status ?? ManagerStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.manager != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'EDITAR GESTOR' : 'NOVO GESTOR',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
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
                _buildTextField(_nameController, 'Nome Completo', Icons.person_outline),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(_emailController, 'E-mail', Icons.email_outlined),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_phoneController, 'Telefone', Icons.phone_outlined)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildTextField(_cpfController, 'CPF', Icons.badge_outlined)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('CONFIGURAÇÕES'),
                const SizedBox(height: AppSpacing.md),
                _buildDropdown<ManagerStatus>(
                  label: 'Status',
                  value: _selectedStatus,
                  items: ManagerStatus.values,
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('PERMISSÕES DE ACESSO'),
                const SizedBox(height: AppSpacing.md),
                _buildPermissionTile('Gestão de Veículos', true),
                _buildPermissionTile('Gestão de Motoristas', true),
                _buildPermissionTile('Fluxo Financeiro', false),
                _buildPermissionTile('Relatórios Avançados', false),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isEditing ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR GESTOR',
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

  Widget _buildPermissionTile(String title, bool initialValue) {
    bool value = initialValue;
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          title: Text(title, style: AppTextStyles.bodyMedium),
          value: value,
          onChanged: (val) => setState(() => value = val),
          contentPadding: EdgeInsets.zero,
        );
      },
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
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
      validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
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
