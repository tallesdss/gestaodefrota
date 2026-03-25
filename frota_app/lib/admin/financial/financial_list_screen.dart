import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../models/financial_entry.dart';
import '../../core/utils/report_generator.dart';

class FinancialListScreen extends StatefulWidget {
  const FinancialListScreen({super.key});

  @override
  State<FinancialListScreen> createState() => _FinancialListScreenState();
}

class _FinancialListScreenState extends State<FinancialListScreen> {
  final MockRepository _repository = MockRepository();
  List<FinancialEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFinancials();
  }

  Future<void> _fetchFinancials() async {
    final list = await _repository.getFinancialEntries();
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'HISTÓRICO FINANCEIRO',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
            onPressed: () => ReportGenerator.generateFinancialReport(_entries),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  final isIncome = entry.type == FinancialType.income;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isIncome ? Colors.green : Colors.red).withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isIncome ? Colors.green : Colors.red,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.description, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                              Text(
                                '${entry.category} • ${_formatDate(entry.date)}',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isIncome ? "+ " : "- "}R\$ ${entry.amount.toStringAsFixed(2)}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
