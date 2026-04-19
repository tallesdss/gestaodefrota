import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../models/company.dart';

class CompanyWizardScreen extends StatefulWidget {
  const CompanyWizardScreen({super.key});

  @override
  State<CompanyWizardScreen> createState() => _CompanyWizardScreenState();
}

class _CompanyWizardScreenState extends State<CompanyWizardScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _ownerController = TextEditingController();
  final _emailController = TextEditingController();
  CompanyPlan _selectedPlan = CompanyPlan.basic;
  int _vehicleLimit = 10;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _finishWizard();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _finishWizard() {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empresa Criada!'),
        content: Text('A empresa ${_nameController.text} foi registrada com sucesso no plano ${_selectedPlan.name.toUpperCase()}.'),
        actions: [
          AppButton(
            label: 'OK',
            onPressed: () {
              Navigator.pop(context); // Dialog
              Navigator.pop(context); // Wizard
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Novo Tenant (SaaS)', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: _buildCurrentStepView(),
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          bool isActive = index <= _currentStep;
          return Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 40,
                  height: 2,
                  color: index < _currentStep ? AppColors.primary : AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildCompanyInfoStep();
      case 1:
        return _buildPlanSelectionStep();
      case 2:
        return _buildConfigurationStep();
      default:
        return Container();
    }
  }

  Widget _buildCompanyInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações Básicas', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text('Dados cadastrais da nova empresa cliente.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        _buildTextField('Nome Fantasia', _nameController, 'Ex: TransLog Transportes'),
        const SizedBox(height: 20),
        _buildTextField('CNPJ', _cnpjController, '00.000.000/0001-00'),
        const SizedBox(height: 20),
        _buildTextField('Nome do Responsável', _ownerController, 'Ex: João da Silva'),
        const SizedBox(height: 20),
        _buildTextField('E-mail Administrativo', _emailController, 'admin@empresa.com.br'),
      ],
    );
  }

  Widget _buildPlanSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seleção de Plano', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text('Escolha o nível de serviço para este tenant.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        _buildPlanCard(CompanyPlan.basic, 'Plano Básico', 'Até 10 veículos', 'R$ 199/mês'),
        const SizedBox(height: 16),
        _buildPlanCard(CompanyPlan.pro, 'Plano Profissional', 'Até 50 veículos', 'R$ 499/mês'),
        const SizedBox(height: 16),
        _buildPlanCard(CompanyPlan.enterprise, 'Enterprise', 'Veículos Ilimitados', 'R$ 999/mês'),
      ],
    );
  }

  Widget _buildConfigurationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Configurações Finais', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text('Parâmetros técnicos do sistema.', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 32),
        AppCard(
          child: Column(
            children: [
              ListTile(
                title: Text('Limite de Veículos', style: AppTextStyles.bodyLarge),
                subtitle: Text('Máximo de veículos cadastrados na base.'),
                trailing: Text('$_vehicleLimit', style: AppTextStyles.h3),
              ),
              Slider(
                value: _vehicleLimit.toDouble(),
                min: 5,
                max: 200,
                divisions: 39,
                onChanged: (val) => setState(() => _vehicleLimit = val.toInt()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: Text('Módulo de Oficina Ativo', style: AppTextStyles.bodyLarge),
          subtitle: Text('Permite gestão completa de manutenções e peças.'),
          value: true,
          onChanged: (v) {},
        ),
        SwitchListTile(
          title: Text('Módulo Financeiro Ativo', style: AppTextStyles.bodyLarge),
          subtitle: Text('Controle de faturamento e fluxo de caixa.'),
          value: true,
          onChanged: (v) {},
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(CompanyPlan plan, String title, String limit, String price) {
    bool isSelected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Radio<CompanyPlan>(
              value: plan,
              groupValue: _selectedPlan,
              onChanged: (v) => setState(() => _selectedPlan = v!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLargeBold),
                  Text(limit, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Text(price, style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Voltar'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              label: _currentStep == 2 ? 'Finalizar Cadastro' : 'Próximo Passo',
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}
