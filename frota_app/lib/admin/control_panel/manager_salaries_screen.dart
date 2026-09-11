import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import 'package:intl/intl.dart';
import '../../core/repositories/manager_repository.dart';
import '../../models/manager.dart';
import '../../models/manager_payment.dart';

class ManagerSalariesScreen extends StatefulWidget {
  const ManagerSalariesScreen({super.key});

  @override
  State<ManagerSalariesScreen> createState() => _ManagerSalariesScreenState();
}

class _ManagerSalariesScreenState extends State<ManagerSalariesScreen> {
  final ManagerRepository _repository = ManagerRepository();
  List<Manager> _managers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _repository.getManagers();
    if (mounted) {
      setState(() {
        _managers = list.where((m) => m.status == ManagerStatus.active).toList();
        _isLoading = false;
      });
    }
  }

  double get _totalFolhaMensal {
    return _managers.fold(0.0, (sum, m) => sum + m.baseSalary);
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Salários dos Gestores',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.adminManagerSalaryHistory),
            tooltip: 'Ver Histórico',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        leading: const BackButton(color: AppColors.primary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_card_outlined),
        label: const Text('Lançar Pagamento'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestão de Remuneração',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Salary Summary Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL FOLHA MENSAL',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              formatCurrency.format(_totalFolhaMensal),
                              style: AppTextStyles.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Colaboradores',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.adminManagerSalaryHistory),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Histórico Completo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Managers List
                  if (_managers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Nenhum gestor ativo encontrado.')),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _managers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final manager = _managers[index];
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  manager.name.isNotEmpty ? manager.name[0].toUpperCase() : 'G',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      manager.name,
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Comissão: ${manager.commissionPercentage.toStringAsFixed(1)}%',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    formatCurrency.format(manager.baseSalary),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  InkWell(
                                    onTap: () => _showPaymentForm(
                                      context,
                                      manager: manager,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'LANÇAR',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
    );
  }

  void _showPaymentForm(BuildContext context, {Manager? manager}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SalaryPaymentBottomSheet(
        managers: _managers,
        initialManager: manager,
        repository: _repository,
        onPaymentAdded: () {
          // You could refresh a local history here if needed
        },
      ),
    );
  }
}

class _SalaryPaymentBottomSheet extends StatefulWidget {
  final List<Manager> managers;
  final Manager? initialManager;
  final ManagerRepository repository;
  final VoidCallback onPaymentAdded;

  const _SalaryPaymentBottomSheet({
    required this.managers,
    this.initialManager,
    required this.repository,
    required this.onPaymentAdded,
  });

  @override
  State<_SalaryPaymentBottomSheet> createState() =>
      _SalaryPaymentBottomSheetState();
}

class _SalaryPaymentBottomSheetState extends State<_SalaryPaymentBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  Manager? _selectedManager;
  
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _commissionController = TextEditingController();

  bool _isSubmitting = false;
  String _status = 'pendente';

  @override
  void initState() {
    super.initState();
    if (widget.managers.isNotEmpty) {
      _selectedManager = widget.initialManager ?? widget.managers[0];
      if (_selectedManager != null) {
        _salaryController.text = _selectedManager!.baseSalary.toStringAsFixed(2);
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedManager == null) return;
    
    final salary = double.tryParse(_salaryController.text.replaceAll(',', '.')) ?? 0.0;
    final commission = double.tryParse(_commissionController.text.replaceAll(',', '.')) ?? 0.0;
    
    if (salary <= 0 && commission <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insira um valor válido de salário ou comissão.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final monthStr = DateFormat('yyyy-MM').format(_selectedDate);

    final payment = ManagerPayment(
      id: '', // Supabase generated
      managerId: _selectedManager!.id,
      baseSalary: salary,
      commission: commission,
      referenceMonth: monthStr,
      status: _status,
    );

    try {
      await widget.repository.createManagerPayment(payment);
      
      if (!mounted) return;
      
      widget.onPaymentAdded();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pagamento registrado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao registrar pagamento: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.managers.isEmpty) {
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: const Text('Não há gestores cadastrados.'),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Registrar Pagamento',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Manager Selection
            Text('Gestor', style: AppTextStyles.labelMedium),
            DropdownButton<Manager>(
              value: _selectedManager,
              isExpanded: true,
              items: widget.managers.map((Manager manager) {
                return DropdownMenuItem<Manager>(
                  value: manager,
                  child: Text(manager.name),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedManager = val;
                  if (val != null) {
                    _salaryController.text = val.baseSalary.toStringAsFixed(2);
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date Selection
            Text('Mês de Referência', style: AppTextStyles.labelMedium),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.outlineVariant),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM / yyyy', 'pt_BR').format(_selectedDate).toUpperCase(),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amounts
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Salário', style: AppTextStyles.labelMedium),
                      TextField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: r'R$ '),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Comissão Extra', style: AppTextStyles.labelMedium),
                      TextField(
                        controller: _commissionController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixText: r'R$ ', hintText: '0.00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Status
            Text('Status', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pendente'),
                    selected: _status == 'pendente',
                    onSelected: (val) {
                      if (val) setState(() => _status = 'pendente');
                    },
                    selectedColor: AppColors.errorContainer.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _status == 'pendente' ? AppColors.error : AppColors.onSurfaceVariant,
                      fontWeight: _status == 'pendente' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Pago'),
                    selected: _status == 'pago',
                    onSelected: (val) {
                      if (val) setState(() => _status = 'pago');
                    },
                    selectedColor: Colors.green.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _status == 'pago' ? Colors.green : AppColors.onSurfaceVariant,
                      fontWeight: _status == 'pago' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirmar Pagamento',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
