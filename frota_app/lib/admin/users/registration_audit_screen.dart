import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../models/driver.dart';
import '../../models/manager.dart';
import '../../models/timeline_item.dart';
import '../../core/widgets/status_badge.dart';

class RegistrationAuditScreen extends StatefulWidget {
  final String? initialSelectedId;
  const RegistrationAuditScreen({super.key, this.initialSelectedId});

  @override
  State<RegistrationAuditScreen> createState() =>
      _RegistrationAuditScreenState();
}

class _RegistrationAuditScreenState extends State<RegistrationAuditScreen> {
  final MockRepository _repository = MockRepository();
  final DriverRepository _driverRepo = DriverRepository();

  List<dynamic> _pendingUsers = [];
  dynamic _selectedUser;
  List<TimelineItem> _timelineItems = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    setState(() => _isLoading = true);
    try {
      final drivers = await _repository.getDrivers();
      final managers = await _repository.getManagers();

      final pendingDrivers = drivers.where((d) => !d.isApproved).toList();
      final pendingManagers = managers.where((m) => !m.isApproved).toList();

      final List<dynamic> allPending = <dynamic>[
        ...pendingDrivers,
        ...pendingManagers,
      ];

      dynamic selected;
      if (allPending.isNotEmpty) {
        if (widget.initialSelectedId != null) {
          selected = allPending.firstWhere(
            (dynamic u) => u.id == widget.initialSelectedId,
            orElse: () => allPending.first,
          );
        } else if (_selectedUser != null) {
          selected = allPending.firstWhere(
            (dynamic u) => u.id == _selectedUser.id,
            orElse: () => allPending.first,
          );
        } else {
          selected = allPending.first;
        }
      }

      setState(() {
        _pendingUsers = allPending;
        _selectedUser = selected;
        _isLoading = false;
      });

      if (selected != null) {
        _loadUserTimeline(selected);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserTimeline(dynamic user) async {
    if (user is Driver) {
      try {
        final items = await _driverRepo.getDriverTimeline(
          driverId: user.id,
          page: 1,
          pageSize: 5,
        );
        if (mounted) {
          setState(() {
            _timelineItems = items;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _timelineItems = [];
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _timelineItems = [];
        });
      }
    }
  }

  Future<void> _approveUser(dynamic user) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Aprovar Cadastro', style: AppTextStyles.titleMedium),
          ],
        ),
        content: Text(
          'Deseja aprovar o cadastro de ${user.name}? O usuário passará para o status ATIVO e terá acesso liberado ao sistema.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('APROVAR'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    try {
      if (user is Driver) {
        await _driverRepo.updateDriverStatus(user.id, DriverStatus.active);
      } else if (user is Manager) {
        // Se for gestor
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro de ${user.name} aprovado com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        await _fetchPendingUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar cadastro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _requestCorrection(dynamic user) async {
    final reasonController = TextEditingController();
    bool cnhProblem = false;
    bool residenceProblem = false;
    bool dataProblem = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Solicitar Correção', style: AppTextStyles.titleMedium),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecione os itens que precisam de revisão por parte de ${user.name}:',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  title: const Text('CNH ilegível, vencida ou divergente'),
                  value: cnhProblem,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) =>
                      setModalState(() => cnhProblem = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text(
                    'Comprovante de residência inválido (> 90 dias)',
                  ),
                  value: residenceProblem,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) =>
                      setModalState(() => residenceProblem = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Dados cadastrais incompletos'),
                  value: dataProblem,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) =>
                      setModalState(() => dataProblem = val ?? false),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Instruções / Motivo adicional',
                    hintText:
                        'Explique detalhadamente o que o condutor deve reenviar...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ENVIAR SOLICITAÇÃO'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Solicitação de correção enviada para ${user.name} com sucesso!',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showInspectDialog({
    required String title,
    required String? imageUrl,
    required Map<String, String> metadata,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.zoom_in,
                            color: AppColors.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'INSPEÇÃO: $title',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Image / Viewer Section
              Expanded(
                child: Container(
                  color: Colors.black.withAlpha(240),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? InteractiveViewer(
                          panEnabled: true,
                          boundaryMargin: const EdgeInsets.all(20),
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Center(
                            child: _buildRenderedImage(imageUrl, fit: BoxFit.contain),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.file_present_outlined,
                                size: 64,
                                color: Colors.white54,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum arquivo enviado para este documento.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Metadata Footer
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: metadata.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(dynamic user) {
    if (user is Driver) {
      final parts = <String>[];
      if (user.street != null && user.street!.trim().isNotEmpty) {
        String streetPart = user.street!.trim();
        if (user.number != null && user.number!.trim().isNotEmpty) {
          streetPart += ', ${user.number!.trim()}';
        }
        parts.add(streetPart);
      }
      if (user.neighborhood != null && user.neighborhood!.trim().isNotEmpty) {
        parts.add(user.neighborhood!.trim());
      }
      if (user.city != null && user.city!.trim().isNotEmpty) {
        String cityPart = user.city!.trim();
        if (user.state != null && user.state!.trim().isNotEmpty) {
          cityPart += ' - ${user.state!.trim()}';
        }
        parts.add(cityPart);
      }
      if (user.zip != null && user.zip!.trim().isNotEmpty) {
        parts.add('CEP: ${user.zip!.trim()}');
      }

      if (parts.isNotEmpty) {
        return parts.join(', ');
      }
    }
    return 'Endereço não informado';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingUsers.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master: List of Pending Users
              SizedBox(width: 380, child: _buildMasterList()),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppColors.surfaceContainerLow,
              ),
              // Detail: Audit View
              Expanded(child: _buildDetailView()),
            ],
          );
        } else {
          // Narrow layout (Mobile-like)
          return _buildMasterList();
        }
      },
    );
  }

  Widget _buildMasterList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pendente Aprovação',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_pendingUsers.length} Cadastros',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Analise os documentos e aprove os motoristas',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: _pendingUsers.length,
            itemBuilder: (context, index) {
              final user = _pendingUsers[index];
              final isSelected =
                  _selectedUser != null && _selectedUser.id == user.id;

              final hasCnh = user is Driver &&
                  ((user.cnhFrontUrl != null && user.cnhFrontUrl!.isNotEmpty) ||
                      (user.cnhBackUrl != null && user.cnhBackUrl!.isNotEmpty));
              final hasResidence = user is Driver &&
                  user.residenceProofUrl != null &&
                  user.residenceProofUrl!.isNotEmpty;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedUser = user);
                  _loadUserTimeline(user);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceContainerLowest
                        : AppColors.surfaceContainerLow.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(color: Colors.transparent),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            backgroundImage: user.avatarUrl.isNotEmpty
                                ? NetworkImage(user.avatarUrl)
                                : null,
                            child: user.avatarUrl.isEmpty
                                ? Text(
                                    user.name.isNotEmpty ? user.name[0] : '?',
                                    style: AppTextStyles.labelLarge,
                                  )
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : 'Sem Nome',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  user.email.isNotEmpty
                                      ? user.email
                                      : 'Pendente de análise',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: 'PENDENTE',
                            type: BadgeType.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _docStatusBadge('CNH', hasCnh),
                              const SizedBox(width: 4),
                              _docStatusBadge('Residência', hasResidence),
                            ],
                          ),
                          if (isSelected)
                            Text(
                              'Visualizando',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _docStatusBadge(String label, bool isUploaded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isUploaded
            ? AppColors.success.withAlpha(25)
            : AppColors.error.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isUploaded
              ? AppColors.success.withAlpha(80)
              : AppColors.error.withAlpha(60),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 10,
            color: isUploaded ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isUploaded ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedUser == null) {
      return const Center(child: Text('Selecione um usuário para auditar'));
    }

    final user = _selectedUser;
    final isDriver = user is Driver;

    final String? cnhUrl = isDriver
        ? (user.cnhFrontUrl != null && user.cnhFrontUrl!.isNotEmpty
            ? user.cnhFrontUrl
            : (user.cnhBackUrl != null && user.cnhBackUrl!.isNotEmpty
                ? user.cnhBackUrl
                : null))
        : null;

    final String? residenceUrl = isDriver
        ? (user.residenceProofUrl != null && user.residenceProofUrl!.isNotEmpty
            ? user.residenceProofUrl
            : null)
        : null;

    final String cnhExpiryStr = isDriver
        ? DateFormat('dd/MM/yyyy').format(user.cnhExpiry)
        : 'Não informada';

    final bool isCnhExpired = isDriver &&
        user.cnhExpiry.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        );

    final String addressStr = _formatAddress(user);
    final String cityStateStr = isDriver && user.city != null && user.city!.isNotEmpty
        ? '${user.city}${user.state != null ? ', ${user.state}' : ''}'
        : 'São Paulo, SP';

    final String idShort = user.id.length > 8
        ? user.id.substring(0, 8).toUpperCase()
        : user.id.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumbs
          Row(
            children: [
              Text(
                'FLEET MANAGEMENT',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              Text(
                'AUDITORIA DE CADASTRO',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Detail Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.md,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 4,
                      ),
                      image: user.avatarUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user.avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.avatarUrl.isEmpty
                        ? Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0] : '?',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isNotEmpty ? user.name : 'Sem Nome',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cityStateStr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '|',
                            style: TextStyle(color: AppColors.outlineVariant),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ID: $idShort',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          if (isDriver && user.phone.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            const Text(
                              '|',
                              style: TextStyle(color: AppColors.outlineVariant),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              user.phone,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _requestCorrection(user),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('CORREÇÃO'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: const BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _approveUser(user),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle, size: 18),
                    label: const Text('APROVAR CADASTRO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Document Grid (CNH e Comprovante de Residência)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideDoc = constraints.maxWidth > 700;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWideDoc ? 2 : 1,
                childAspectRatio: 1.45,
                crossAxisSpacing: AppSpacing.xl,
                mainAxisSpacing: AppSpacing.xl,
                children: [
                  _buildDocCard(
                    title: 'CNH (MOTORISTA)',
                    icon: Icons.badge_outlined,
                    imageUrl: cnhUrl,
                    statusBadge: cnhUrl != null && cnhUrl.isNotEmpty
                        ? 'DOCUMENTO ANEXADO'
                        : 'NÃO ENVIADO',
                    isUploaded: cnhUrl != null && cnhUrl.isNotEmpty,
                    fieldLabel1: 'NOME NO DOC / CPF',
                    fieldValue1:
                        '${user.name.toUpperCase()} • ${isDriver && user.cpf.isNotEmpty ? user.cpf : "Sem CPF"}',
                    fieldLabel2: 'VALIDADE / CAT',
                    fieldValue2:
                        '$cnhExpiryStr (${isDriver ? user.cnhCategory : "B"})',
                    isExpiryWarning: isCnhExpired,
                    onInspect: () {
                      _showInspectDialog(
                        title: 'CNH DO MOTORISTA',
                        imageUrl: cnhUrl,
                        metadata: {
                          'Motorista': user.name,
                          'CPF': isDriver ? user.cpf : '-',
                          'Número CNH':
                              isDriver && user.cnhNumber.isNotEmpty
                                  ? user.cnhNumber
                                  : 'Não informado',
                          'Categoria': isDriver ? user.cnhCategory : 'B',
                          'Validade': cnhExpiryStr,
                          'Status': cnhUrl != null && cnhUrl.isNotEmpty
                              ? 'Anexado no Supabase'
                              : 'Pendente',
                        },
                      );
                    },
                  ),
                  _buildDocCard(
                    title: 'COMPROVANTE DE RESIDÊNCIA',
                    icon: Icons.home_outlined,
                    imageUrl: residenceUrl,
                    statusBadge: residenceUrl != null && residenceUrl.isNotEmpty
                        ? 'DOCUMENTO ANEXADO'
                        : 'NÃO ENVIADO',
                    isUploaded:
                        residenceUrl != null && residenceUrl.isNotEmpty,
                    fieldLabel1: 'ENDEREÇO CADASTRADO',
                    fieldValue1: addressStr,
                    fieldLabel2: 'CIDADE / ESTADO',
                    fieldValue2: cityStateStr,
                    onInspect: () {
                      _showInspectDialog(
                        title: 'COMPROVANTE DE RESIDÊNCIA',
                        imageUrl: residenceUrl,
                        metadata: {
                          'Titular': user.name,
                          'Endereço Extraído': addressStr,
                          'Cidade/UF': cityStateStr,
                          'Status':
                              residenceUrl != null && residenceUrl.isNotEmpty
                                  ? 'Anexado no Supabase'
                                  : 'Pendente',
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // History Section
          const Divider(),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'HISTÓRICO DE AUDITORIA',
            style: AppTextStyles.labelSmall.copyWith(
              letterSpacing: 2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (_timelineItems.isNotEmpty)
            ..._timelineItems.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(item.date);
              return _buildTimelineItem(
                item.description,
                dateStr,
                isFirst: idx == 0,
                isLast: idx == _timelineItems.length - 1,
              );
            })
          else ...[
            _buildTimelineItem(
              'Cadastro iniciado e documentos anexados',
              'Cadastrado recentemente',
              isFirst: true,
            ),
            _buildTimelineItem(
              'Em análise pela equipe de gestão de frotas',
              'Aguardando aprovação final',
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required IconData icon,
    required String? imageUrl,
    required String statusBadge,
    required bool isUploaded,
    required String fieldLabel1,
    required String fieldValue1,
    String? fieldLabel2,
    String? fieldValue2,
    bool isExpiryWarning = false,
    required VoidCallback onInspect,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isUploaded ? AppColors.primary : AppColors.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.success.withAlpha(20)
                    : AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusBadge,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isUploaded ? AppColors.success : AppColors.error,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GestureDetector(
            onTap: onInspect,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUploaded
                      ? AppColors.primary.withAlpha(40)
                      : AppColors.outlineVariant.withAlpha(60),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: isUploaded && imageUrl != null && imageUrl.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildRenderedImage(imageUrl, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(120),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(220),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.zoom_in,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'INSPECIONAR',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              size: 44,
                              color: AppColors.onSurfaceVariant.withAlpha(100),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhum documento anexado',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Aguardando envio pelo condutor',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant.withAlpha(
                                  150,
                                ),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fieldLabel1,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 8,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      fieldValue1,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (fieldLabel2 != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fieldLabel2,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 8,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        fieldValue2!,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isExpiryWarning
                              ? AppColors.error
                              : AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isFirst ? AppColors.primary : AppColors.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.surfaceContainerLow,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRenderedImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: AppColors.outlineVariant,
                ),
                const SizedBox(height: 8),
                Text('Imagem indisponível', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        );
      } catch (_) {}
    }
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text('Imagem indisponível', style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.primary.withAlpha(100),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhum cadastro pendente',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
