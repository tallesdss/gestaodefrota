import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração central de conexão e constantes do Supabase (PostgreSQL Relacional).
class SupabaseConfig {
  /// URL do Projeto Supabase (Região sa-east-1 / São Paulo)
  static const String supabaseUrl = 'https://rwksrejrmjqnuspqnokp.supabase.co';

  /// Chave pública anônima (Anon Key)
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3a3NyZWpybWpxbnVzcHFub2twIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4NDQ3NTUsImV4cCI6MjEwMjQyMDc1NX0.Yrd5UKfAM925jo7tpFQ08soDrcjkyCfGBQJ0qSmLPRc';

  /// Inicialização do SDK Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }

  /// Instância global do cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Usuário atualmente autenticado
  static User? get currentUser => client.auth.currentUser;

  /// ID do usuário autenticado (ou null)
  static String? get currentUserId => currentUser?.id;

  /// Verifica se há sessão ativa
  static bool get isAuthenticated => currentUser != null;

  // --- BUCKETS DE STORAGE ---
  static const String bucketDocumentosMotoristas = 'documentos-motoristas';
  static const String bucketFotosVistorias = 'fotos-vistorias';
  static const String bucketDocumentosVeiculos = 'documentos-veiculos';
  static const String bucketNotasFiscaisOficinas = 'notas-fiscais-oficinas';
  static const String bucketComprovantesPagamento = 'comprovantes-pagamento';

  // --- NOMES DAS TABELAS RELACIONAIS (Português) ---
  static const String tabelaPerfis = 'perfis';
  static const String tabelaMotoristas = 'motoristas';
  static const String tabelaGestores = 'gestores';
  static const String tabelaPermissoes = 'permissoes';
  static const String tabelaGestorPermissoes = 'gestor_permissoes';
  static const String tabelaVeiculos = 'veiculos';
  static const String tabelaContratos = 'contratos';
  static const String tabelaVistorias = 'vistorias';
  static const String tabelaFotosVistoria = 'fotos_vistoria';
  static const String tabelaItensChecklistVistoria = 'itens_checklist_vistoria';
  static const String tabelaOficinas = 'oficinas';
  static const String tabelaManutencoes = 'manutencoes';
  static const String tabelaItensManutencao = 'itens_manutencao';
  static const String tabelaCategoriasDespesa = 'categorias_despesa';
  static const String tabelaLancamentosFinanceiros = 'lancamentos_financeiros';
  static const String tabelaHistoricoAtividades = 'historico_atividades';

  // --- VIEWS RELACIONAIS ANALÍTICAS ---
  static const String viewKpisDashboard = 'vw_kpis_dashboard_master';
  static const String viewExtratoMotorista = 'vw_extrato_completo_motorista';

  // --- FUNÇÕES RPC TRANSACIONAIS ---
  static const String rpcCriarContratoLocacao = 'fn_criar_contrato_locacao';
}

/// Helper global de acesso rápido ao cliente Supabase
SupabaseClient get supabase => SupabaseConfig.client;
