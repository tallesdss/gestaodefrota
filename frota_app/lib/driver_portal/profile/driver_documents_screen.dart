import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/repositories/contract_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../models/driver.dart';
import '../../models/contract.dart';
import '../../models/vehicle.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  final ImagePicker _picker = ImagePicker();

  Driver? _driver;
  Contract? _activeContract;
  Vehicle? _linkedVehicle;
  bool _isLoading = true;
  bool _isUploading = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    final uid = _authRepo.currentUserId;
    if (uid != null) {
      try {
        var driver = await _driverRepo.getDriverById(uid);
        if (driver == null) {
          final profile = await _authRepo.getCurrentProfile();
          driver = Driver(
            id: uid,
            name: profile?['nome']?.toString() ?? 'Motorista',
            email: profile?['email']?.toString() ?? '',
            phone: profile?['telefone']?.toString() ?? '',
            status: DriverStatus.pendingApproval,
            cnhExpiry: DateTime.now().add(const Duration(days: 365 * 5)),
            cnhCategory: 'B',
            cpf: '',
            cnhNumber: '',
            avatarUrl: '',
            type: DriverType.uber,
          );
        }
        final contract = await _contractRepo.getActiveContractByDriver(uid);
        Vehicle? vehicle;
        if (contract != null && contract.vehicleId.isNotEmpty) {
          vehicle = await _vehicleRepo.getVehicleById(contract.vehicleId);
        }
        vehicle ??= await _vehicleRepo.getVehicleByDriverId(uid);

        Vehicle? finalVehicle = vehicle;
        Contract? finalContract = contract;

        if (finalContract == null && finalVehicle != null) {
          finalContract = Contract(
            id: 'ctr-${finalVehicle.id}',
            contractNumber: 'CTR-${finalVehicle.plate}',
            driverId: uid,
            driverName: driver.name,
            vehicleId: finalVehicle.id,
            type: 'uber',
            startDate: DateTime(2026, 8, 22),
            endDate: DateTime(2027, 8, 22),
            weeklyValue: finalVehicle.rentalValue ?? 750.00,
            monthlyValue: (finalVehicle.rentalValue ?? 750.00) * 4,
            depositPaid: true,
            depositAmount: 1500.00,
            billingFrequency: 'semanal',
            dueDay: 5,
            status: ContractStatus.active,
          );
        }

        if (mounted) {
          setState(() {
            _driver = driver;
            _activeContract = finalContract;
            _linkedVehicle = finalVehicle;
            _isLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadDocument({
    required String docType,
    required String title,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enviar $title',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tire uma foto nítida do documento ou escolha da sua galeria.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: Text('Tirar Foto com a Câmera', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _processPickAndUpload(docType, ImageSource.camera, title);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Escolher da Galeria', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.pop(ctx);
                  _processPickAndUpload(docType, ImageSource.gallery, title);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPickAndUpload(
    String docType,
    ImageSource source,
    String title,
  ) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() => _isUploading = true);

      final uid = _authRepo.currentUserId;
      if (uid == null) throw Exception('Usuário não autenticado');

      final bytes = await file.readAsBytes();
      final documentUrl = await _driverRepo.uploadDriverDocument(
        driverId: uid,
        docType: docType,
        bytes: bytes,
        fileName: '${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (mounted) {
        setState(() {
          if (docType == 'cnh_frente') {
            _driver = (_driver ?? Driver(
              id: uid,
              name: 'Motorista',
              email: '',
              phone: '',
              status: DriverStatus.pendingApproval,
              cnhExpiry: DateTime.now().add(const Duration(days: 365 * 5)),
              cnhCategory: 'B',
              cpf: '',
              cnhNumber: '',
              avatarUrl: '',
              type: DriverType.uber,
            )).copyWith(cnhFrontUrl: documentUrl);
          } else if (docType == 'comprovante_residencia') {
            _driver = (_driver ?? Driver(
              id: uid,
              name: 'Motorista',
              email: '',
              phone: '',
              status: DriverStatus.pendingApproval,
              cnhExpiry: DateTime.now().add(const Duration(days: 365 * 5)),
              cnhCategory: 'B',
              cpf: '',
              cnhNumber: '',
              avatarUrl: '',
              type: DriverType.uber,
            )).copyWith(residenceProofUrl: documentUrl);
          }
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title enviado e armazenado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar documento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDocumentViewerDialog({
    required String title,
    required String imageUrl,
    required String docType,
    required String status,
    required Color statusColor,
    String? subtitle,
  }) {
    AppDialogs.showModal(
      context: context,
      title: title,
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (subtitle != null)
                  Expanded(
                    child: Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 320,
                color: AppColors.surfaceContainerLow,
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: _buildRenderedImage(imageUrl),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Substituir Documento',
                    icon: Icons.upload_file_outlined,
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      _uploadDocument(docType: docType, title: title);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Fechar',
                    variant: AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRenderedImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64Str = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
        return Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorImagePlaceholder(),
        );
      } catch (_) {
        return _buildErrorImagePlaceholder();
      }
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorImagePlaceholder(),
    );
  }

  Widget _buildErrorImagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 48, color: AppColors.outlineVariant),
          SizedBox(height: 8),
          Text(
            'Não foi possível carregar a imagem',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showContractDetailsDialog() {
    if (_activeContract == null) return;
    final c = _activeContract!;

    AppDialogs.showModal(
      context: context,
      title: 'Contrato de Locação',
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONTRATO ATIVO',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (c.contractNumber != null && c.contractNumber!.isNotEmpty)
                              ? c.contractNumber!
                              : 'CTR-${c.id.substring(0, c.id.length > 8 ? 8 : c.id.length).toUpperCase()}',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_linkedVehicle != null) ...[
              _buildContractInfoRow('Veículo em Posse', '${_linkedVehicle!.brand} ${_linkedVehicle!.model}'),
              _buildContractInfoRow('Placa', _linkedVehicle!.plate),
              _buildContractInfoRow('Km Atual', '${_linkedVehicle!.currentKm} km'),
            ],
            _buildContractInfoRow('Data de Início', _dateFormat.format(c.startDate)),
            _buildContractInfoRow('Data de Término', _dateFormat.format(c.endDate)),
            _buildContractInfoRow('Valor do Aluguel', 'R\$ ${(c.monthlyValue > 0 ? c.monthlyValue : c.weeklyValue).toStringAsFixed(2)}'),
            _buildContractInfoRow('Frequência de Cobrança', (c.billingFrequency ?? 'semanal').toUpperCase()),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Fechar',
              variant: AppButtonVariant.primary,
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cnhUrl = _driver?.cnhFrontUrl ?? _driver?.cnhBackUrl;
    final hasCnh = cnhUrl != null && cnhUrl.isNotEmpty;
    final residenceUrl = _driver?.residenceProofUrl;
    final hasResidence = residenceUrl != null && residenceUrl.isNotEmpty;
    final hasContract = _activeContract != null;

    final cnhStatus = hasCnh ? (_driver?.isApproved == true ? 'VALIDADO' : 'EM ANÁLISE') : 'NÃO ENVIADO';
    final cnhColor = hasCnh ? (_driver?.isApproved == true ? const Color(0xFF4CAF50) : AppColors.warning) : AppColors.error;
    final cnhExpiryStr = _driver?.cnhExpiry != null
        ? 'Validade: ${_dateFormat.format(_driver!.cnhExpiry)}'
        : 'Pendente de envio';

    final residenceStatus = hasResidence ? 'ENVIADO' : 'NÃO ENVIADO';
    final residenceColor = hasResidence ? const Color(0xFF4CAF50) : AppColors.error;

    final contractStatus = hasContract ? 'ATIVO' : 'NENHUM CONTRATO';
    final contractColor = hasContract ? AppColors.primary : AppColors.onSurfaceVariant;
    final contractDateStr = hasContract
        ? 'Contrato ${(_activeContract!.contractNumber != null && _activeContract!.contractNumber!.isNotEmpty) ? _activeContract!.contractNumber! : "Ativo"} - Início ${_dateFormat.format(_activeContract!.startDate)}'
        : 'Aguardando alocação pela gestão';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadDocuments,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildDocumentItem(
                            title: 'CNH Digital / Física',
                            subtitle: hasCnh ? '$cnhExpiryStr • Toque para visualizar' : 'Pendente de envio • Toque para enviar',
                            status: cnhStatus,
                            statusColor: cnhColor,
                            imageUrl: cnhUrl,
                            onTap: () {
                              if (hasCnh) {
                                _showDocumentViewerDialog(
                                  title: 'CNH Digital / Física',
                                  imageUrl: cnhUrl,
                                  docType: 'cnh_frente',
                                  status: cnhStatus,
                                  statusColor: cnhColor,
                                  subtitle: cnhExpiryStr,
                                );
                              } else {
                                _uploadDocument(
                                  docType: 'cnh_frente',
                                  title: 'CNH Digital / Física',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildDocumentItem(
                            title: 'Comprovante de Residência',
                            subtitle: hasResidence
                                ? 'Documento anexado • Toque para visualizar'
                                : 'Pendente de envio • Toque para enviar',
                            status: residenceStatus,
                            statusColor: residenceColor,
                            imageUrl: residenceUrl,
                            onTap: () {
                              if (hasResidence) {
                                _showDocumentViewerDialog(
                                  title: 'Comprovante de Residência',
                                  imageUrl: residenceUrl,
                                  docType: 'comprovante_residencia',
                                  status: residenceStatus,
                                  statusColor: residenceColor,
                                );
                              } else {
                                _uploadDocument(
                                  docType: 'comprovante_residencia',
                                  title: 'Comprovante de Residência',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildDocumentItem(
                            title: 'Contrato de Locação',
                            subtitle: hasContract
                                ? '$contractDateStr • Toque para ver detalhes'
                                : 'Aguardando alocação pela gestão',
                            status: contractStatus,
                            statusColor: contractColor,
                            onTap: _showContractDetailsDialog,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildInfoFooter(),
                        ],
                      ),
                    ),
                  ),
                  if (_isUploading)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Card(
                          color: AppColors.surface,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: AppSpacing.md),
                                Text('Enviando documento...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.onSurface,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'DOCUMENTAÇÃO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text('Central de Arquivos', style: AppTextStyles.headlineMedium),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
    String? imageUrl,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AppIcon(
                icon: Icons.file_present_outlined,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  color: AppColors.surfaceContainerLowest,
                  child: _buildRenderedImage(imageUrl),
                ),
              ),
            ],
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Mantenha seus documentos atualizados para evitar bloqueios automáticos no sistema.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
