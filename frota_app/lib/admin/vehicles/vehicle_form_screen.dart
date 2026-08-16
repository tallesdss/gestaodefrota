import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../models/vehicle.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final VehicleRepository _vehicleRepo = VehicleRepository();
  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Dados Básicos',
    'Especificações',
    'Financeiro',
    'Documentação',
  ];

  // Controllers
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _modelYearController = TextEditingController();
  final _chassiController = TextEditingController();
  final _renavamController = TextEditingController();
  final _colorController = TextEditingController();
  final _kmController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _purchaseValueController = TextEditingController();
  final _fipeValueController = TextEditingController();

  // Alienação
  bool _isEncumbered = false;
  final _bankController = TextEditingController();
  final _paidInstallmentsController = TextEditingController();
  final _totalInstallmentsController = TextEditingController();
  final _installmentValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      final v = widget.vehicle!;
      _plateController.text = v.plate;
      _brandController.text = v.brand;
      _modelController.text = v.model;
      _yearController.text = v.year.toString();
      _modelYearController.text = (v.modelYear ?? v.year).toString();
      _chassiController.text = v.chassis ?? '';
      _renavamController.text = v.renavam ?? '';
      _colorController.text = v.color;
      _kmController.text = v.currentMileage.toString();
      _dailyRateController.text = v.dailyRate.toStringAsFixed(2);
      _purchaseValueController.text = v.purchaseValue?.toStringAsFixed(2) ?? '';
      _fipeValueController.text = v.fipeValue?.toStringAsFixed(2) ?? '';
      _isEncumbered = v.isFinanced;
      _bankController.text = v.financeBank ?? '';
      _paidInstallmentsController.text = v.paidInstallments?.toString() ?? '';
      _totalInstallmentsController.text = v.totalInstallments?.toString() ?? '';
      _installmentValueController.text = v.installmentValue?.toStringAsFixed(2) ?? '';
    } else {
      _yearController.text = DateTime.now().year.toString();
      _modelYearController.text = DateTime.now().year.toString();
      _kmController.text = '0';
      _dailyRateController.text = '120.00';
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _modelYearController.dispose();
    _chassiController.dispose();
    _renavamController.dispose();
    _colorController.dispose();
    _kmController.dispose();
    _dailyRateController.dispose();
    _purchaseValueController.dispose();
    _fipeValueController.dispose();
    _bankController.dispose();
    _paidInstallmentsController.dispose();
    _totalInstallmentsController.dispose();
    _installmentValueController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveVehicle() async {
    final plate = _plateController.text.trim().toUpperCase();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();

    if (plate.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha a placa e o modelo do veículo.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final year = int.tryParse(_yearController.text.trim()) ?? now.year;
      final modelYear = int.tryParse(_modelYearController.text.trim()) ?? year;
      final km = int.tryParse(_kmController.text.trim()) ?? 0;
      final dailyRate = double.tryParse(_dailyRateController.text.replaceAll(',', '.')) ?? 100.0;
      final purchaseVal = double.tryParse(_purchaseValueController.text.replaceAll(',', '.'));
      final fipeVal = double.tryParse(_fipeValueController.text.replaceAll(',', '.'));

      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? '',
        plate: plate,
        brand: brand.isNotEmpty ? brand : 'Geral',
        model: model,
        year: year,
        modelYear: modelYear,
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : 'Branco',
        chassi: _chassiController.text.trim(),
        renavam: _renavamController.text.trim(),
        currentKm: km,
        status: widget.vehicle?.status ?? VehicleStatus.available,
        rentalValue: dailyRate,
        purchaseValue: purchaseVal,
        fipeValue: fipeVal,
        isEncumbered: _isEncumbered,
        encumberedBank: _bankController.text.trim(),
        financingInstallmentsPaid: int.tryParse(_paidInstallmentsController.text.trim()),
        financingTotalInstallments: int.tryParse(_totalInstallmentsController.text.trim()),
        financingInstallmentValue: double.tryParse(_installmentValueController.text.replaceAll(',', '.')),
        imageUrl: 'https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?q=80&w=400&auto=format&fit=crop',
      );

      if (widget.vehicle != null && widget.vehicle!.id.isNotEmpty) {
        await _vehicleRepo.updateVehicle(vehicle);
      } else {
        await _vehicleRepo.createVehicle(vehicle);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veículo $plate salvo com sucesso no banco de dados!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar veículo: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildHeader(),
          _buildStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxxl,
                vertical: AppSpacing.xxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          const SizedBox(width: 16),
          Text(
            widget.vehicle != null ? 'EDITAR VEÍCULO' : 'ADICIONAR NOVO VEÍCULO',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final bool isActive = index <= _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _stepTitles[index],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive
                        ? AppColors.onSurface
                        : AppColors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (index < _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: index < _currentStep
                          ? AppColors.primary
                          : AppColors.surfaceContainerHigh,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            AppTextField(
              label: 'Placa do Veículo *',
              hintText: 'Ex: BRA2E19 ou ABC1234',
              controller: _plateController,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Marca *',
                    hintText: 'Ex: Toyota, Fiat, VW',
                    controller: _brandController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    label: 'Modelo *',
                    hintText: 'Ex: Corolla XEi, Argo Drive',
                    controller: _modelController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Ano de Fabricação',
                    hintText: '2023',
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    label: 'Ano do Modelo',
                    hintText: '2024',
                    controller: _modelYearController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            AppTextField(
              label: 'Chassi (VIN)',
              hintText: '9BWZZZ...',
              controller: _chassiController,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Renavam',
              hintText: '0123456789',
              controller: _renavamController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Cor Predominante',
                    hintText: 'Prata Metálico',
                    controller: _colorController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    label: 'Quilometragem Atual (KM)',
                    hintText: '0',
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Valor de Diária Estimada (R\$)',
                    hintText: '120.00',
                    controller: _dailyRateController,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    label: 'Valor de Compra (R\$)',
                    hintText: '75000.00',
                    controller: _purchaseValueController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Valor da Tabela FIPE (R\$)',
              hintText: '82000.00',
              controller: _fipeValueController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Veículo Financiado / Gravame?',
                            style: AppTextStyles.labelLarge,
                          ),
                          Text(
                            'O veículo possui parcelas pendentes com banco?',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                      Switch(
                        value: _isEncumbered,
                        activeThumbColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isEncumbered = val),
                      ),
                    ],
                  ),
                  if (_isEncumbered) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Instituição Financeira / Banco',
                      hintText: 'Ex: Santander, BV, Banco do Brasil',
                      controller: _bankController,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Parcelas Pagas',
                            hintText: '12',
                            controller: _paidInstallmentsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Total de Parcelas',
                            hintText: '48',
                            controller: _totalInstallmentsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Valor da Parcela (R\$)',
                      hintText: '1450.00',
                      controller: _installmentValueController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _buildDocUploadCard('CRLV Digital (Documento do Veículo)'),
            const SizedBox(height: 16),
            _buildDocUploadCard('Apólice de Seguro / Rastreamento'),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDocUploadCard(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(label, style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Text('PDF, PNG ou JPG (Armazenamento seguro Supabase)', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep > 0)
            AppButton(
              label: 'Voltar',
              onPressed: () => setState(() => _currentStep--),
              variant: AppButtonVariant.ghost,
            ),
          const SizedBox(width: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : AppButton(
                  label: _currentStep == _stepTitles.length - 1
                      ? 'Finalizar e Salvar no Supabase'
                      : 'Continuar',
                  onPressed: () {
                    if (_currentStep < _stepTitles.length - 1) {
                      setState(() => _currentStep++);
                    } else {
                      _handleSaveVehicle();
                    }
                  },
                  variant: AppButtonVariant.primary,
                ),
        ],
      ),
    );
  }
}
