import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/admin_pix_config.dart';
import '../../core/services/pix_service.dart';

class PixConfigScreen extends StatefulWidget {
  const PixConfigScreen({super.key});

  @override
  State<PixConfigScreen> createState() => _PixConfigScreenState();
}

class _PixConfigScreenState extends State<PixConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _keyController;
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  String _selectedType = 'telefone';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await PixService().initialize();
    final config = PixService().currentConfig;
    _keyController = TextEditingController(text: config.pixKey);
    _nameController = TextEditingController(text: config.merchantName);
    _cityController = TextEditingController(text: config.merchantCity);
    _selectedType = _getTypeFromKey(config.pixKey) ?? 'telefone';
    setState(() => _isLoading = false);
  }

  String? _getTypeFromKey(String key) {
    if (key.contains('@')) return 'email';
    if (key.length == 11 && !key.contains('-')) return 'cpf';
    if (key.length == 14 && !key.contains('-')) return 'cnpj';
    if (key.length >= 12 && key.startsWith('+')) return 'telefone';
    if (key.length >= 32) return 'aleatoria';
    return null;
  }

  @override
  void dispose() {
    _keyController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final newConfig = AdminPixConfig(
      pixKey: _keyController.text.trim(),
      merchantName: _nameController.text.trim(),
      merchantCity: _cityController.text.trim(),
      keyType: PixKeyType.values.firstWhere(
        (t) => t.name == _selectedType, 
        orElse: () => PixKeyType.aleatoria,
      ),
      updatedAt: DateTime.now(),
    );
    
    await PixService().updateConfig(newConfig);
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuração PIX salva com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'CONFIGURAÇÃO PIX',
          style: AppTextStyles.labelLarge.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dados de Recebimento',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Esta chave será exibida aos motoristas para pagamento via PIX.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Chave',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.vpn_key_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'cpf', child: Text('CPF')),
                        DropdownMenuItem(value: 'cnpj', child: Text('CNPJ')),
                        DropdownMenuItem(value: 'telefone', child: Text('Telefone (+55)')),
                        DropdownMenuItem(value: 'email', child: Text('E-mail')),
                        DropdownMenuItem(value: 'aleatoria', child: Text('Chave Aleatória (EVP)')),
                      ],
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _keyController,
                      decoration: InputDecoration(
                        labelText: 'Chave PIX',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.qr_code_2),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Informe a chave PIX' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Titular/Empresa',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Cidade (Sede)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_city_outlined),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'SALVAR CONFIGURAÇÃO',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
