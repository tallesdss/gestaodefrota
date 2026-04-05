import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/routes/app_routes.dart';

class DriverOnboardingContractScreen extends StatefulWidget {
  const DriverOnboardingContractScreen({super.key});

  @override
  State<DriverOnboardingContractScreen> createState() =>
      _DriverOnboardingContractScreenState();
}

class _DriverOnboardingContractScreenState
    extends State<DriverOnboardingContractScreen> {
  bool _accepted = false;
  bool _scrolledToEnd = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 10) {
        if (!_scrolledToEnd) {
          setState(() {
            _scrolledToEnd = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContractBody()),
            _buildActionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '02',
                style: AppTextStyles.displayMedium.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTRATO',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Assinatura Digital',
                    style: AppTextStyles.headlineSmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Termos de Locação e Uso do Veículo',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                '1. CLÁUSULA PRIMEIRA - DO OBJETO\n\nEste contrato tem como objeto a locação de veículo automotor para uso profissional do motorista parceiro, sob as condições de manutenção, seguro e pagamento semanal detalhadas neste termo.\n\n'
                '2. CLÁUSULA SEGUNDA - DAS OBRIGAÇÕES\n\nO locatário obriga-se a zelar pelo veículo como se fosse seu, realizando os check-ins diários e reportando qualquer avaria imediatamente através do aplicativo.\n\n'
                '3. CLÁUSULA TERCEIRA - DO PAGAMENTO\n\nO valor do aluguel semanal será debitado automaticamente ou pago via PIX até a data de vencimento. O atraso superior a 48h resultará em bloqueio do veículo.\n\n'
                '4. CLÁUSULA QUARTA - DO SEGURO\n\nO veículo possui seguro contra terceiros e roubo, com franquia a cargo do motorista em caso de sinistro com culpa comprovada.\n\n'
                '5. CLÁUSULA QUINTA - DA RESCISÃO\n\nA rescisão pode ser solicitada com 7 dias de antecedência sem multas, desde que o veículo seja entregue em perfeito estado.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (!_scrolledToEnd)
                Center(
                  child: Text(
                    'Continue lendo para liberar a assinatura...',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (_scrolledToEnd) {
                setState(() {
                  _accepted = !_accepted;
                });
              }
            },
            child: Row(
              children: [
                Checkbox(
                  value: _accepted,
                  activeColor: AppColors.primary,
                  onChanged: _scrolledToEnd
                      ? (value) {
                          setState(() {
                            _accepted = value!;
                          });
                        }
                      : null,
                ),
                Expanded(
                  child: Text(
                    'Li e concordo com todos os termos do contrato de locação.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _scrolledToEnd
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'ASSINAR DIGITALMENTE',
            isFullWidth: true,
            onPressed: _accepted
                ? () => context.push(AppRoutes.driverProfileSetup)
                : null,
          ),
        ],
      ),
    );
  }
}
