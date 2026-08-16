import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/manager.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para Gestão de Equipe, Salários e Permissões no Supabase
class ManagerRepository {
  final SupabaseClient _client;

  ManagerRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar gestores com perfis e permissões associadas
  Future<List<Manager>> getManagers() async {
    final response = await _client.from(SupabaseConfig.tabelaGestores).select('''
      *,
      perfis!inner (
        id,
        nome,
        email,
        telefone,
        foto_url,
        cargo
      ),
      gestor_permissoes (
        permissao_id,
        permissoes (
          id,
          codigo,
          nome,
          modulo
        )
      )
    ''');

    return (response as List)
        .map((m) => Manager.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  /// Obter gestor por ID
  Future<Manager?> getManagerById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaGestores)
        .select('''
          *,
          perfis!inner (
            id,
            nome,
            email,
            telefone,
            foto_url,
            cargo
          ),
          gestor_permissoes (
            permissao_id,
            permissoes (
              id,
              codigo,
              nome,
              modulo
            )
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Manager.fromMap(Map<String, dynamic>.from(response));
  }

  /// Atualizar dados salariais e comissões do gestor
  Future<void> updateManagerSalary(
    String managerId,
    double baseSalary,
    double commissionPercentage,
  ) async {
    await _client.from(SupabaseConfig.tabelaGestores).upsert({
      'id': managerId,
      'salario_base': baseSalary,
      'percentual_comissao': commissionPercentage,
    });
  }

  /// Conceder permissão na tabela associativa gestor_permissoes
  Future<void> assignPermission(String managerId, String permissionId) async {
    await _client.from(SupabaseConfig.tabelaGestorPermissoes).upsert({
      'gestor_id': managerId,
      'permissao_id': permissionId,
    });
  }

  /// Revogar permissão
  Future<void> revokePermission(String managerId, String permissionId) async {
    await _client
        .from(SupabaseConfig.tabelaGestorPermissoes)
        .delete()
        .eq('gestor_id', managerId)
        .eq('permissao_id', permissionId);
  }

  /// Listar catálogo completo de permissões
  Future<List<Map<String, dynamic>>> getAllPermissions() async {
    final response = await _client
        .from(SupabaseConfig.tabelaPermissoes)
        .select()
        .order('modulo');

    return (response as List).map((p) => Map<String, dynamic>.from(p as Map)).toList();
  }
}
