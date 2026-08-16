import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Repositório de Autenticação e Gestão de Sessões no Supabase
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Usuário atualmente autenticado
  User? get currentUser => _client.auth.currentUser;

  /// ID do usuário autenticado
  String? get currentUserId => currentUser?.id;

  /// Verifica se há sessão ativa
  bool get isAuthenticated => currentUser != null;

  /// Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Login com Email e Senha
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  /// Cadastro de Novo Usuário (com metadados que acionam o trigger no PostgreSQL)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nome,
    String? telefone,
    String cargo = 'motorista',
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'nome': nome.trim(),
        'telefone': telefone?.trim(),
        'cargo': cargo,
      },
    );

    // Garantir que o perfil existe em public.perfis
    if (res.user != null) {
      await _client.from(SupabaseConfig.tabelaPerfis).upsert({
        'id': res.user!.id,
        'nome': nome.trim(),
        'email': email.trim().toLowerCase(),
        'telefone': telefone?.trim(),
        'cargo': cargo,
      });
    }

    return res;
  }

  /// Logout
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Recuperação de Senha por E-mail
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email.trim().toLowerCase());
  }

  /// Obter Perfil do Usuário Autenticado
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;

    final data = await _client
        .from(SupabaseConfig.tabelaPerfis)
        .select()
        .eq('id', uid)
        .maybeSingle();

    return data;
  }

  /// Obter Cargo do Usuário Atual ('admin', 'gestor', 'motorista')
  Future<String> getCurrentUserRole() async {
    final profile = await getCurrentProfile();
    return (profile?['cargo'] ?? 'motorista').toString();
  }
}
