import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/workshop.dart';

class WorkshopFormScreen extends StatefulWidget {
  final Workshop? workshop;

  const WorkshopFormScreen({super.key, this.workshop});

  @override
  State<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends State<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cnpjController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _bankInfoController;
  bool _isAccredited = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workshop?.name ?? '');
    _cnpjController = TextEditingController(text: widget.workshop?.cnpj ?? '');
    _phoneController = TextEditingController(
      text: widget.workshop?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.workshop?.email ?? '',
    );
    _addressController = TextEditingController(
      text: widget.workshop?.address ?? '',
    );
    _bankInfoController = TextEditingController(
      text: widget.workshop?.bankInfo ?? '',
    );
    _isAccredited = widget.workshop?.isAccredited ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bankInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.workshop != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Oficina' : 'Credenciar Nova Oficina',
          style: AppTextStyles.headlineSmall,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Dados Primários'),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                'Nome da Oficina / Razão Social',
                _nameController,
                Icons.storefront,
              ),
              const Row(
                children: [
                  // Expanded(child: _buildTextField('CNPJ', _cnpjController, Icons.badge_outlined)),
                  // const SizedBox(width: AppSpacing.md),
                  // Expanded(child: _buildTextField('Controle de Qualidade', TextEditingController(), Icons.star_border)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'CNPJ',
                      _cnpjController,
                      Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTextField(
                      'Telefone',
                      _phoneController,
                      Icons.phone_android_outlined,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                'E-mail de Contato',
                _emailController,
                Icons.email_outlined,
              ),
              _buildTextField(
                'Endereço Completo',
                _addressController,
                Icons.pin_drop_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.xl),
              _buildSectionTitle('Financeiro & Credenciamento'),
              const SizedBox(height: AppSpacing.md),
              _buildTextField(
                'Dados Bancários (Agência, Conta, Banco, PIX)',
                _bankInfoController,
                Icons.account_balance_outlined,
              ),

              SwitchListTile(
                title: Text(
                  'Oficina Credenciada',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: Text(
                  'Define se a oficina faz parte da rede oficial da frota',
                  style: AppTextStyles.bodySmall,
                ),
                value: _isAccredited,
                activeThumbColor: AppColors.primary,
                inactiveThumbColor: AppColors.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
                onChanged: (value) => setState(() => _isAccredited = value),
              ),

              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing
                        ? 'Atualizar Cadastro'
                        : 'Confirmar Credenciamento',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Mock saving logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oficina salva com sucesso!'),
          backgroundColor: Colors.teal,
        ),
      );
      Navigator.pop(context);
    }
  }
}
