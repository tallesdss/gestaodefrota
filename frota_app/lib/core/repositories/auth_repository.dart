import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../models/user_profile.dart';

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

  /// Cadastro de Novo Usuário (com metadados e flags booleanas que acionam o trigger no PostgreSQL)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String nome,
    String? telefone,
    String cargo = 'motorista',
    bool? isAdmin,
    bool? isGestor,
    bool? isMotorista,
  }) async {
    final effectiveAdmin = isAdmin ?? (cargo == 'admin');
    final effectiveGestor = isGestor ?? (cargo == 'gestor' || effectiveAdmin);
    final effectiveMotorista = isMotorista ?? (cargo == 'motorista');

    final res = await _client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'nome': nome.trim(),
        'telefone': telefone?.trim(),
        'cargo': cargo,
        'is_admin': effectiveAdmin,
        'is_gestor': effectiveGestor,
        'is_motorista': effectiveMotorista,
      },
    );

    // Garantir que o perfil existe em public.perfis se houver sessão
    if (res.user != null && res.session != null) {
      try {
        await _client.from(SupabaseConfig.tabelaPerfis).upsert({
          'id': res.user!.id,
          'nome': nome.trim(),
          'email': email.trim().toLowerCase(),
          'telefone': telefone?.trim(),
          'cargo': cargo,
          'is_admin': effectiveAdmin,
          'is_gestor': effectiveGestor,
          'is_motorista': effectiveMotorista,
        });
      } catch (_) {
        // O trigger no PostgreSQL já cuida da inserção com privilégios de SECURITY DEFINER
      }
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

  /// Obter Perfil do Usuário Autenticado como Map
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

  /// Obter Perfil Tipado do Usuário Autenticado (com flags isAdmin, isGestor, isMotorista)
  Future<UserProfile?> getCurrentUserProfile() async {
    final profileMap = await getCurrentProfile();
    if (profileMap == null) return null;
    return UserProfile.fromMap(profileMap);
  }

  /// Obter Cargo do Usuário Atual ('admin', 'gestor', 'motorista')
  Future<String> getCurrentUserRole() async {
    final profile = await getCurrentUserProfile();
    if (profile == null) return 'motorista';
    if (profile.isAdmin) return 'admin';
    if (profile.isGestor) return 'gestor';
    return profile.cargo;
  }
}
