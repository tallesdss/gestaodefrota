import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/driver_repository.dart';
import '../../models/driver.dart';

class DriverFormScreen extends StatefulWidget {
  final Driver? driver;
  const DriverFormScreen({super.key, this.driver});

  @override
  State<DriverFormScreen> createState() => _DriverFormScreenState();
}

class _DriverFormScreenState extends State<DriverFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DriverRepository _driverRepo = DriverRepository();
  bool _isLoading = false;

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
      text: widget.driver?.cnhCategory ?? 'B',
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

  Future<void> _handleSaveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final driver = Driver(
        id: widget.driver?.id ?? '',
        name: _nameController.text.trim(),
        cpf: _cpfController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        cnhNumber: _cnhNumberController.text.trim(),
        cnhExpiry: widget.driver?.cnhExpiry ?? DateTime.now().add(const Duration(days: 365 * 4)),
        cnhCategory: _cnhCategoryController.text.trim().isNotEmpty
            ? _cnhCategoryController.text.trim().toUpperCase()
            : 'B',
        avatarUrl: widget.driver?.avatarUrl ?? '',
        cnhFrontUrl: widget.driver?.cnhFrontUrl,
        cnhBackUrl: widget.driver?.cnhBackUrl,
        residenceProofUrl: widget.driver?.residenceProofUrl,
        currentVehicleId: widget.driver?.currentVehicleId,
        street: widget.driver?.street,
        number: widget.driver?.number,
        complement: widget.driver?.complement,
        neighborhood: widget.driver?.neighborhood,
        city: widget.driver?.city,
        state: widget.driver?.state,
        zip: widget.driver?.zip,
        isApproved: _selectedStatus == DriverStatus.active,
        trustScore: widget.driver?.trustScore ?? 100,
        outstandingBalance: widget.driver?.outstandingBalance ?? 0.0,
        totalGenerated: widget.driver?.totalGenerated ?? 0.0,
      );

      if (widget.driver != null && widget.driver!.id.isNotEmpty) {
        await _driverRepo.updateDriver(driver);
      } else {
        await _driverRepo.createDriver(driver);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Motorista ${_nameController.text} salvo com sucesso no banco de dados!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar motorista: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                  'Nome Completo *',
                  Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(
                  _emailController,
                  'E-mail *',
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _phoneController,
                        'Telefone *',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        _cpfController,
                        'CPF *',
                        Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildSectionTitle('HABILITAÇÃO (CNH)'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        _cnhNumberController,
                        'Número da CNH *',
                        Icons.credit_card_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        _cnhCategoryController,
                        'Categoria *',
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleSaveDriver,
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
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
