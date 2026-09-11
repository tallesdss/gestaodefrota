import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_icon.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/routes/app_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/app_avatar.dart';

class DriverProfileSetupScreen extends StatefulWidget {
  const DriverProfileSetupScreen({super.key});

  @override
  State<DriverProfileSetupScreen> createState() =>
      _DriverProfileSetupScreenState();
}

class _DriverProfileSetupScreenState extends State<DriverProfileSetupScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authRepo.getCurrentProfile();
      if (mounted && profile != null) {
        setState(() {
          _nameController.text = profile['nome']?.toString() ?? '';
          _phoneController.text = profile['telefone']?.toString() ?? '';
          _fotoUrl = profile['foto_url']?.toString();
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAndFinish() async {
    final uid = _authRepo.currentUserId;
    if (uid != null) {
      try {
        final phone = _phoneController.text.trim();
        final name = _nameController.text.trim();
        
        final updateData = <String, dynamic>{
          if (phone.isNotEmpty) 'telefone': phone,
          if (name.isNotEmpty) 'nome': name,
          'atualizado_em': DateTime.now().toIso8601String(),
        };
        
        if (_fotoUrl != null) {
           updateData['foto_url'] = _fotoUrl;
        }

        if (updateData.length > 1) {
          await SupabaseConfig.client.from(SupabaseConfig.tabelaPerfis).update(updateData).eq('id', uid);
        }
      } catch (e) {
         print('Erro ao salvar perfil: $e');
      }
    }

    _showSuccessDialog();
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildScoreCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildProfileForm(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildActionArea(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIGURAÇÃO',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        Text('Perfil do Condutor', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Confirme seus dados para finalizar seu cadastro.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
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
                    'SCORE DE CONFIANÇA',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '100',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'pts',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const AppIcon(
                  icon: Icons.shield_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 1.0,
              child: Container(color: Colors.white),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Você inicia com pontuação máxima. Mantenha os pagamentos e vistorias em dia para ganhar benefícios exclusivos!',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final uid = _authRepo.currentUserId;
    if (uid == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      final file = File(pickedFile.path);
      final fileExt = pickedFile.name.split('.').last;
      final fileName = 'profile_$uid.$fileExt';
      final path = 'avatars/$uid/$fileName';

      final storage = SupabaseConfig.client.storage.from('documentos-motoristas');
      
      await storage.upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = await storage.createSignedUrl(path, 60 * 60 * 24 * 365 * 10); // 10 anos

      if (mounted) {
        setState(() {
          _fotoUrl = publicUrl;
          _isUploadingPhoto = false;
        });
      }
    } catch (e) {
      print('Erro no upload: $e');
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar foto. Tente novamente.')),
        );
      }
    }
  }

  Widget _buildAvatarArea() {
    return Center(
      child: Stack(
        children: [
          AppAvatar(
            imageUrl: _fotoUrl,
            name: _nameController.text.isNotEmpty ? _nameController.text : 'Motorista',
            radius: 50,
          ),
          if (_isUploadingPhoto)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                child: const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploadingPhoto ? null : _pickAndUploadImage,
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatarArea(),
        const SizedBox(height: AppSpacing.lg),
        _buildInputField(
          label: 'NOME COMPLETO',
          controller: _nameController,
          enabled: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInputField(
          label: 'CELULAR (WHATSAPP)',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const AppIcon(
                icon: Icons.verified_outlined,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Seus documentos foram enviados para auditoria digital.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceContainerLowest
                : AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea() {
    return Column(
      children: [
        AppButton(
          label: 'CONCLUIR CADASTRO',
          isFullWidth: true,
          onPressed: _saveAndFinish,
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'VOLTAR',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Tudo pronto!', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Seu perfil foi configurado com sucesso. Agora é só aguardar a vinculação do seu veículo!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'IR PARA HOME',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  context.go(AppRoutes.driverHome);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
