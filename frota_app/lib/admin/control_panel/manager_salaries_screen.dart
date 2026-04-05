import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import 'package:intl/intl.dart';

class ManagerSalariesScreen extends StatefulWidget {
  const ManagerSalariesScreen({super.key});

  @override
  State<ManagerSalariesScreen> createState() => _ManagerSalariesScreenState();
}

class _ManagerSalariesScreenState extends State<ManagerSalariesScreen> {
  // Mock Data
  final managers = [
    {
      'name': 'Carlos Oliveira',
      'role': 'Gestor Operacional',
      'salary': r'R$ 5.500,00',
    },
    {
      'name': 'Ana Paula',
      'role': 'Gestora Financeira',
      'salary': r'R$ 6.200,00',
    },
    {
      'name': 'Roberto Silva',
      'role': 'Supervisor de Frota',
      'salary': r'R$ 4.800,00',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        leading: BackButton(color: AppColors.primary),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_card_outlined),
        label: const Text('Lançar Pagamento'),
      ),
      body: SingleChildScrollView(
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
                        r'R$ 16.500,00',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: managers.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final manager = managers[index];
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
                          manager['name']![0],
                          style: TextStyle(
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
                              manager['name']!,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              manager['role']!,
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
                            manager['salary']!,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _showPaymentForm(
                              context,
                              managerName: manager['name'],
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

  void _showPaymentForm(BuildContext context, {String? managerName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _SalaryPaymentBottomSheet(initialManager: managerName),
    );
  }
}

class _SalaryPaymentBottomSheet extends StatefulWidget {
  final String? initialManager;

  const _SalaryPaymentBottomSheet({this.initialManager});

  @override
  State<_SalaryPaymentBottomSheet> createState() =>
      _SalaryPaymentBottomSheetState();
}

class _SalaryPaymentBottomSheetState extends State<_SalaryPaymentBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedType = 'Adiantamento';
  late String _selectedManager;

  final List<String> _types = [
    'Adiantamento',
    'Saldo Salarial',
    'Bônus',
    'Outros',
  ];
  final List<String> _managers = [
    'Carlos Oliveira',
    'Ana Paula',
    'Roberto Silva',
  ];

  @override
  void initState() {
    super.initState();
    _selectedManager = widget.initialManager ?? _managers[0];
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
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

  @override
  Widget build(BuildContext context) {
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
            DropdownButton<String>(
              value: _selectedManager,
              isExpanded: true,
              items: _managers.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedManager = val!),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amount
            Text('Valor do Pagamento', style: AppTextStyles.labelMedium),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(prefixText: r'R$ ', hintText: '0,00'),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Date Selection (CORE REQUEST)
            Text('Data de Pagamento', style: AppTextStyles.labelMedium),
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
                      DateFormat('dd / MM / yyyy').format(_selectedDate),
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

            // Type
            Text('Tipo', style: AppTextStyles.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _types.map((type) {
                final isSelected = _selectedType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedType = type);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pagamento registrado com sucesso!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
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
