import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/financial_entry.dart';
import '../../core/widgets/app_dialogs.dart';

class FinancialFlowDetailScreen extends StatefulWidget {
  final String? vehicleId;
  const FinancialFlowDetailScreen({super.key, this.vehicleId});

  @override
  State<FinancialFlowDetailScreen> createState() => _FinancialFlowDetailScreenState();
}

enum FinancialFilter { all, income, expense }

class _FinancialFlowDetailScreenState extends State<FinancialFlowDetailScreen> {
  final MockRepository _repository = MockRepository();
  List<FinancialEntry> _entries = [];
  List<FinancialEntry> _filteredEntries = [];
  bool _isLoading = true;
  String _searchQuery = '';
  FinancialFilter _selectedType = FinancialFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchFinancials();
  }

  Future<void> _fetchFinancials() async {
    final list = widget.vehicleId != null 
        ? await _repository.getFinancialEntriesByVehicle(widget.vehicleId!)
        : await _repository.getFinancialEntries();
    setState(() {
      _entries = list;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _entries.where((e) {
        final matchesQuery = _searchQuery.isEmpty || 
            e.description.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            e.category.toLowerCase().contains(_searchQuery.toLowerCase());
            
        final matchesType = _selectedType == FinancialFilter.all ||
            (_selectedType == FinancialFilter.income && e.type == FinancialType.income) ||
            (_selectedType == FinancialFilter.expense && e.type == FinancialType.expense);
            
        return matchesQuery && matchesType;
      }).toList();
    });
  }

  void _filterEntries(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _togglePaymentStatus(FinancialEntry entry) {
    setState(() {
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = _entries[index].copyWith(isPaid: !entry.isPaid);
        _applyFilters();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status de pagamento atualizado para: ${!entry.isPaid ? "PAGO" : "PENDENTE"}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: !entry.isPaid ? AppColors.success : AppColors.error,
      ),
    );
  }

  void _confirmDelete(FinancialEntry entry) {
    AppDialogs.showModal(
      context: context,
      title: 'Excluir Lançamento',
      content: Text('Tem certeza que deseja excluir o lançamento "${entry.description}"? Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _entries.removeWhere((e) => e.id == entry.id);
              _filterEntries(_searchQuery);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lançamento excluído com sucesso.'), behavior: SnackBarBehavior.floating),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  void _showEntryActions(FinancialEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(entry.isPaid ? Icons.pending_actions_outlined : Icons.check_circle_outline, color: AppColors.primary),
              title: Text(entry.isPaid ? 'Marcar como Pendente' : 'Marcar como Pago'),
              onTap: () {
                Navigator.pop(context);
                _togglePaymentStatus(entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant),
              title: const Text('Editar Lançamento'),
              onTap: () {
                Navigator.pop(context);
                // logic for edit form could be here
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Excluir Lançamento', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(entry);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'DETALHAMENTO DE FLUXO',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search & Filter Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: _filterEntries,
                        decoration: InputDecoration(
                          hintText: 'Buscar por categoria ou descrição...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLow,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _buildFilterChip('Tudo', FinancialFilter.all),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Ganho', FinancialFilter.income),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip('Gasto', FinancialFilter.expense),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                    itemCount: _filteredEntries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return _buildTransactionCard(entry);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTransactionCard(FinancialEntry entry) {
    final bool isIncome = entry.type == FinancialType.income;
    final String sign = isIncome ? 'R\$ ' : '- R\$ ';
    final Color amountColor = isIncome ? AppColors.primary : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.category.toLowerCase().contains('manutenção') ? Icons.build_outlined : entry.category.toLowerCase().contains('multa') ? Icons.report_problem_outlined : Icons.payments_outlined,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.description, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    Text(entry.category.toUpperCase(), style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              ),
              IconButton(onPressed: () => _showEntryActions(entry), icon: const Icon(Icons.more_vert)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VALOR', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  Text('$sign${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w900, color: amountColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('STATUS', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: entry.isPaid ? AppColors.successContainer : AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.isPaid ? 'PAGO' : 'PENDENTE',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: entry.isPaid ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(_formatDate(entry.date), style: AppTextStyles.bodySmall),
              const Spacer(),
              const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Corolla ABC-1234', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, FinancialFilter type) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
            _applyFilters();
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      showCheckmark: false,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
