import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/repositories/mock_repository.dart';
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
  List<dynamic> _pendingUsers = [];
  dynamic _selectedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    final drivers = await _repository.getDrivers();
    final managers = await _repository.getManagers();

    final pendingDrivers = drivers.where((d) => !d.isApproved).toList();
    final pendingManagers = managers.where((m) => !m.isApproved).toList();

    setState(() {
      _pendingUsers = [...pendingDrivers, ...pendingManagers];
      if (_pendingUsers.isNotEmpty) {
        if (widget.initialSelectedId != null) {
          _selectedUser = _pendingUsers.firstWhere(
            (u) => u.id == widget.initialSelectedId,
            orElse: () => _pendingUsers.first,
          );
        } else {
          _selectedUser = _pendingUsers.first;
        }
      }
      _isLoading = false;
    });
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
                  Text(
                    'Pendente Aprovação',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_pendingUsers.length} Users',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Analise os novos cadastros abaixo',
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

              return GestureDetector(
                onTap: () => setState(() => _selectedUser = user),
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
                                    user.name[0],
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
                                  user.name,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Applied 2 hours ago',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            label: 'REVIEWING',
                            type: BadgeType.warning,
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _miniBadge('CNH'),
                                const SizedBox(width: 4),
                                _miniBadge('Residência'),
                              ],
                            ),
                            Text(
                              'Open Details',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _miniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    if (_selectedUser == null) {
      return const Center(child: Text('Selecione um usuário para auditar'));
    }

    final user = _selectedUser;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                              user.name[0],
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
                        user.name,
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
                            'São Paulo, SP',
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
                            'ID: FC-4920',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
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
                    onPressed: () {},
                    icon: const Icon(Icons.check_circle, size: 18),
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

          // Document Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideDoc = constraints.maxWidth > 700;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWideDoc ? 2 : 1,
                childAspectRatio: 1.5,
                crossAxisSpacing: AppSpacing.xl,
                mainAxisSpacing: AppSpacing.xl,
                children: [
                  _buildDocCard(
                    title: 'CNH (MOTORISTA)',
                    icon: Icons.badge_outlined,
                    imageUrl:
                        'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?q=80&w=640&auto=format&fit=crop', // Placeholder for CNH
                    aiScore: '98% AI MATCH',
                    fieldLabel1: 'NOME NO DOC',
                    fieldValue1: user.name.toUpperCase(),
                    fieldLabel2: 'VALIDADE',
                    fieldValue2: '12/04/2026',
                    isExpiryWarning: true,
                  ),
                  _buildDocCard(
                    title: 'COMPROVANTE DE RESIDÊNCIA',
                    icon: Icons.home_outlined,
                    imageUrl:
                        'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=640&auto=format&fit=crop', // Placeholder for Proof
                    aiScore: 'CONTA RECENTE',
                    fieldLabel1: 'ENDEREÇO EXTRAÍDO',
                    fieldValue1:
                        'Av. Brigadeiro Faria Lima, 4500 - Itaim Bibi, SP',
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
          _buildTimelineItem(
            'Documentos enviados pelo motorista',
            'Hoje às 09:15 AM',
            isFirst: true,
          ),
          _buildTimelineItem(
            'Análise iniciada por Admin (Você)',
            'Hoje às 11:30 AM',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required IconData icon,
    required String imageUrl,
    required String aiScore,
    required String fieldLabel1,
    required String fieldValue1,
    String? fieldLabel2,
    String? fieldValue2,
    bool isExpiryWarning = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
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
            Text(
              aiScore,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                opacity: 0.8,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
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
