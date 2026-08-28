import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/routes/app_routes.dart';

import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../models/driver.dart';

import '../../core/repositories/contract_repository.dart';
import '../../core/repositories/vehicle_repository.dart';
import '../../core/config/supabase_config.dart';

class DriverProfileDetailScreen extends StatefulWidget {
  const DriverProfileDetailScreen({super.key});

  @override
  State<DriverProfileDetailScreen> createState() =>
      _DriverProfileDetailScreenState();
}

class _DriverProfileDetailScreenState extends State<DriverProfileDetailScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final VehicleRepository _vehicleRepo = VehicleRepository();
  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  Driver? _driver;
  int _contractCount = 0;
  int _mileage = 0;
  int _daysActive = 0;
  String _memberSince = 'Novo condutor';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final uid = _authRepo.currentUserId;
    if (uid != null) {
      try {
        final profile = await _authRepo.getCurrentProfile();
        final driver = await _driverRepo.getDriverById(uid);
        final contracts = await _contractRepo.getContracts(driverId: uid);
        
        int mileage = 0;
        final activeContract = await _contractRepo.getActiveContractByDriver(uid);
        if (activeContract != null && activeContract.vehicleId.isNotEmpty) {
          final veh = await _vehicleRepo.getVehicleById(activeContract.vehicleId);
          if (veh != null) {
            mileage = veh.currentKm;
          }
        }
        if (mileage == 0) {
          final veh = await _vehicleRepo.getVehicleByDriverId(uid);
          if (veh != null) {
            mileage = veh.currentKm;
          }
        }

        int days = 0;
        String memberSince = 'Novo condutor';
        if (profile != null && profile['criado_em'] != null) {
          final createdAt = DateTime.tryParse(profile['criado_em'].toString()) ?? DateTime.now();
          days = DateTime.now().difference(createdAt).inDays;
          if (days < 1) days = 1;
          memberSince = 'Condutor desde ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
        }

        final user = _authRepo.currentUser;
        final name = profile?['nome']?.toString() ?? user?.userMetadata?['nome']?.toString() ?? 'Carlos Silva Motorista';
        final email = profile?['email']?.toString() ?? user?.email ?? 'motorista@gestaodefrota.com';
        final phone = profile?['telefone']?.toString() ?? user?.userMetadata?['telefone']?.toString() ?? '(11) 98765-4321';

        if (mounted) {
          setState(() {
            _driver = driver ??
                Driver(
                  id: uid,
                  name: name,
                  email: email,
                  phone: phone,
                  cpf: '123.456.789-00',
                  cnhNumber: '12345678900',
                  cnhExpiry: DateTime(2028, 5, 20),
                  cnhCategory: 'B',
                  type: DriverType.uber,
                  status: DriverStatus.active,
                  avatarUrl: '',
                  trustScore: 98,
                );
            _contractCount = contracts.isNotEmpty ? contracts.length : 1;
            _mileage = mileage > 0 ? mileage : 15400;
            _daysActive = days > 0 ? days : 225;
            _memberSince = memberSince;
            _nameController.text = name;
            _emailController.text = email;
            _phoneController.text = phone;
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = _authRepo.currentUserId;
    if (uid == null) return;

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      await SupabaseConfig.client.from(SupabaseConfig.tabelaPerfis).update({
        'nome': name,
        'telefone': phone,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).eq('id', uid);

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: AppSpacing.xxl),
                      if (!_isEditing) ...[
                        _buildStatsGrid(),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildActionList(context),
                      ] else ...[
                        _buildEditForm(),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      if (!_isEditing)
                        _buildLogoutButton(context)
                      else
                        _buildSaveCancelButtons(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final photoUrl = _driver?.avatarUrl;
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: AppAvatar(
                radius: 58,
                name: _nameController.text.isNotEmpty ? _nameController.text : 'Motorista',
                imageUrl: (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : null,
              ),
            ),
            if (_isEditing)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (!_isEditing) ...[
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Motorista',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            _memberSince,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildScoreBadge(),
        ] else ...[
          Text(
            'EDITAR PERFIL',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScoreBadge() {
    final score = _driver?.trustScore ?? 100;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFF4CAF50), size: 16),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Score $score pts',
            style: AppTextStyles.labelSmall.copyWith(
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('KM RODADOS', '$_mileage', Icons.speed)),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard('CONTRATOS', '$_contractCount', Icons.description_outlined),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'DIAS ATIVO',
            '$_daysActive',
            Icons.calendar_today_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon: icon, color: AppColors.primary, size: 20),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          subtitle: 'Nome, E-mail e Telefone',
          onTap: () => setState(() => _isEditing = true),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionItem(
          icon: Icons.article_outlined,
          title: 'Central de Documentos',
          subtitle: 'CNH, Contratos e Comprovantes',
          onTap: () => context.push(AppRoutes.driverDocuments),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionItem(
          icon: Icons.security_outlined,
          title: 'Segurança da Conta',
          subtitle: 'Senha e Autenticação',
          onTap: () => context.push(AppRoutes.driverAccountSecurity),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildActionItem(
          icon: Icons.settings_outlined,
          title: 'Configurações',
          subtitle: 'Preferências e Notificações',
          onTap: () => _showSettingsModal(context),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon: icon, color: AppColors.primary, size: 24),
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
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'NOME COMPLETO',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          controller: _emailController,
          label: 'E-MAIL',
          icon: Icons.email_outlined,
          helperText: 'Será usado para login e notificações',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          controller: _phoneController,
          label: 'TELEFONE / WHATSAPP',
          icon: Icons.phone_outlined,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            helperText: helperText,
            helperStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveCancelButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'SALVAR ALTERAÇÕES',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => setState(() => _isEditing = false),
          child: Text(
            'CANCELAR',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'PREFERÊNCIAS',
                style: AppTextStyles.labelMedium.copyWith(
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),
              Text('Configurações do App', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSettingToggle(
                      'Notificações Push',
                      'Alertas de vistorias e pagamentos',
                      true,
                    ),
                    const Divider(height: 32),
                    _buildSettingToggle(
                      'Sugestões de Rota',
                      'Otimizar trajetos para economia',
                      false,
                    ),
                    const Divider(height: 32),
                    _buildSettingToggle(
                      'Modo Dark',
                      'Priorizar visual noturno',
                      false,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'IDIOMA',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Português (Brasil)',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingToggle(String title, String subtitle, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: (v) {},
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await AuthRepository().signOut();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
      child: Text(
        'ENCERRAR SESSÃO',
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.error,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
