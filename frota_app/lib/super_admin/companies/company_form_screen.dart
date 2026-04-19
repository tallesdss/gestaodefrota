import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/company.dart';
import '../models/saas_plan.dart';
import '../core/company_manager.dart';
import '../core/saas_financial_manager.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';

class CompanyFormScreen extends StatefulWidget {
  final Company? company;

  const CompanyFormScreen({super.key, this.company});

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cnpjController;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleLimitController;
  
  SaaSPlan? _selectedPlan;
  CompanyStatus _status = CompanyStatus.active;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameController = TextEditingController(text: c?.name ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _cnpjController = TextEditingController(text: c?.cnpj ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _vehicleLimitController = TextEditingController(text: c?.vehicleLimit.toString() ?? '10');
    _status = c?.status ?? CompanyStatus.active;
    
    final plans = SaaSFinancialManager().plans;
    if (c != null) {
      _selectedPlan = plans.firstWhere((p) => p.name == c.planName, orElse: () => plans.first);
    } else {
      _selectedPlan = plans.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _vehicleLimitController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.company != null;
      
      final company = Company(
        id: widget.company?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        cnpj: _cnpjController.text,
        phone: _phoneController.text,
        plan: _getPlanEnum(_selectedPlan?.name ?? 'Basic'),
        status: _status,
        vehicleLimit: int.tryParse(_vehicleLimitController.text) ?? 10,
        currentVehicles: widget.company?.currentVehicles ?? 0,
        createdAt: widget.company?.createdAt ?? DateTime.now(),
      );

      if (isEdit) {
        CompanyManager().updateCompany(company);
        AuditManager().logAction(
          action: AuditAction.companyModified,
          target: company.name,
          details: 'Dados da empresa atualizados.',
        );
      } else {
        CompanyManager().addCompany(company);
        AuditManager().logAction(
          action: AuditAction.companyCreated,
          target: company.name,
          details: 'Nova empresa integrada ao ecossistema no plano ${company.planName}.',
        );
      }

      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Empresa atualizada!' : 'Empresa cadastrada com sucesso!'),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = SaaSFinancialManager().plans;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.company == null ? 'Nova Empresa' : 'Editar Empresa',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('INFORMAÇÕES BÁSICAS'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'Nome da Empresa',
                              hint: 'Ex: Transportadora Silva',
                              icon: Icons.business,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: _cnpjController,
                              label: 'CNPJ',
                              hint: '00.000.000/0000-00',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _emailController,
                              label: 'Email do Administrador',
                              hint: 'admin@empresa.com',
                              icon: Icons.email_outlined,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: _phoneController,
                              label: 'Telefone de Contato',
                              hint: '(00) 00000-0000',
                              icon: Icons.phone_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildSectionHeader('PLANO & RECURSOS'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField<SaaSPlan>(
                              label: 'Plano de Assinatura',
                              value: _selectedPlan,
                              items: plans.map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name, style: const TextStyle(color: Colors.white)),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedPlan = v),
                              icon: Icons.layers_outlined,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              controller: _vehicleLimitController,
                              label: 'Limite de Veículos',
                              hint: 'Ex: 10',
                              icon: Icons.directions_car_filled_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildDropdownField<CompanyStatus>(
                              label: 'Status da Conta',
                              value: _status,
                              items: CompanyStatus.values.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
                              )).toList(),
                              onChanged: (v) => setState(() => _status = v!),
                              icon: Icons.info_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.inter(color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.company == null ? 'Cadastrar Empresa' : 'Salvar Alterações',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.accent,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.white24, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: const Color(0xFF0F172A),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }

  CompanyPlan _getPlanEnum(String planName) {
    if (planName.toLowerCase().contains('pro')) return CompanyPlan.pro;
    if (planName.toLowerCase().contains('enterprise')) return CompanyPlan.enterprise;
    return CompanyPlan.basic;
  }
}
