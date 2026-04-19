import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações Globais',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajuste os parâmetros de funcionamento de todo o ecossistema.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withAlpha(10))),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.white38,
              indicatorColor: AppColors.accent,
              tabs: const [
                Tab(text: 'Financeiro & Pagamentos'),
                Tab(text: 'Integrações e APIs'),
                Tab(text: 'Segurança e Acesso'),
                Tab(text: 'Aparência & White-Label'),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFinanceTab(),
                _buildIntegrationTab(),
                _buildSecurityTab(),
                _buildGeneralTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          _buildSettingsGroup(
            'Gateway de Pagamento',
            'Configure como o sistema processa as assinaturas dos tenants.',
            [
              _buildSwitchSetting('Produção (Live Mode)', true),
              _buildTextSetting('API Key Stripe', 'sk_live_********************', isPassword: true),
              _buildTextSetting('Webhook Secret', 'whsec_********************', isPassword: true),
              _buildDropdownSetting('Moeda Base', 'BRL (Real Brasileiro)', ['BRL (Real Brasileiro)', 'USD (US Dollar)', 'EUR (Euro)']),
            ],
          ),
          const SizedBox(height: 32),
          _buildSettingsGroup(
            'Regras de Inadimplência',
            'Defina o comportamento do sistema quando um pagamento falha.',
            [
              _buildTextSetting('Dias de tolerância', '5 dias'),
              _buildSwitchSetting('Bloqueio Automático', true),
              _buildSwitchSetting('Notificar Administrador do Sistema', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
           _buildSettingsGroup(
            'Google Maps Platform',
            'Necessário para o rastreio e roteirização.',
            [
              _buildTextSetting('API Key Maps', 'AIzaSy********************', isPassword: true),
              _buildTextSetting('Quota Diária (R\$)', '50.00'),
            ],
          ),
          const SizedBox(height: 32),
          _buildSettingsGroup(
            'Serviço de Email (SMTP/SendGrid)',
            'Envio de notificações de sistema e faturas.',
            [
              _buildTextSetting('SMTP Host', 'smtp.sendgrid.net'),
              _buildTextSetting('Porta', '587'),
              _buildTextSetting('Username', 'apikey'),
              _buildTextSetting('Password', '************************', isPassword: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          _buildSettingsGroup(
            'Autenticação Super Admin',
            'Configurações críticas de acesso master.',
            [
              _buildSwitchSetting('Forçar Autenticação em Duas Etapas (2FA)', true),
              _buildDropdownSetting('Expiração da Sessão', '2 horas', ['30 minutos', '1 hora', '2 horas', '24 horas']),
            ],
          ),
          const SizedBox(height: 32),
          _buildSettingsGroup(
            'Shadow Mode (Impersonation)',
            'Configurações de acesso do Super Admin às empresas.',
            [
              _buildSwitchSetting('Permitir Visualização de Dados Sensíveis', false),
              _buildSwitchSetting('Logar todas as ações no Shadow Mode', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          _buildSettingsGroup(
            'White-Label Defaults',
            'Valores padrão para novas empresas subindo na plataforma.',
            [
              _buildDropdownSetting('Fonte Padrão', 'Manrope', ['Manrope', 'Inter', 'Roboto', 'Outfit']),
              _buildColorSetting('Cor Primária Padrão', AppColors.accent),
              _buildSwitchSetting('Permitir remoção de "Powered by FleetCommand"', false),
            ],
          ),
          const SizedBox(height: 32),
          _buildSettingsGroup(
            'Controle de Infraestrutura',
            'Ações de sistema de alto impacto.',
            [
              _buildSwitchSetting('Modo Manutenção (System-wide)', false),
              _buildSwitchSetting('Permitir Novos Cadastros Públicos', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, String subtitle, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
          const SizedBox(height: 32),
          ...children.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: c,
          )),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String label, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
        Switch(
          value: value,
          onChanged: (v) {},
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildTextSetting(String label, String value, {bool isPassword = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
        ),
        Expanded(
          flex: 3,
          child: TextField(
            controller: TextEditingController(text: value),
            obscureText: isPassword,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white.withAlpha(5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(onPressed: () {}, icon: const Icon(Icons.check, color: AppColors.accent, size: 20)),
      ],
    );
  }

  Widget _buildDropdownSetting(String label, String value, List<String> items) {
     return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1E293B),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
            onChanged: (v) {},
          ),
        ),
      ],
    );
  }

  Widget _buildColorSetting(String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white24),
          ),
        ),
      ],
    );
  }
}
