import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/workshop.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para o Módulo de Oficinas Credenciadas no Supabase
class WorkshopRepository {
  final SupabaseClient _client;

  WorkshopRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Listar oficinas com filtros de busca e status
  Future<List<Workshop>> getWorkshops({
    String? search,
    bool? isAccredited,
  }) async {
    var query = _client.from(SupabaseConfig.tabelaOficinas).select('''
      *,
      manutencoes (
        id,
        custo_total,
        status
      )
    ''');

    if (isAccredited != null) {
      query = query.eq('status', isAccredited ? 'ativo' : 'inativo');
    }

    if (search != null && search.trim().isNotEmpty) {
      final s = search.trim();
      query = query.or('nome_fantasia.ilike.%$s%,cnpj.ilike.%$s%');
    }

    final response = await query.order('nome_fantasia');

    return (response as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);

      // Calcular totais gastos e pendências com a oficina
      if (map['manutencoes'] is List) {
        double total = 0.0;
        double pending = 0.0;
        for (var m in (map['manutencoes'] as List)) {
          final cost = (m['custo_total'] ?? 0.0) is num ? (m['custo_total'] as num).toDouble() : 0.0;
          total += cost;
          if (m['status'] != 'concluido' && m['status'] != 'pago') {
            pending += cost;
          }
        }
        map['totalSpent'] = total;
        map['pendingPayment'] = pending;
      }

      return Workshop.fromMap(map);
    }).toList();
  }

  /// Obter oficina por ID
  Future<Workshop?> getWorkshopById(String id) async {
    final response = await _client
        .from(SupabaseConfig.tabelaOficinas)
        .select('''
          *,
          manutencoes (
            id,
            custo_total,
            status
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    final map = Map<String, dynamic>.from(response);

    if (map['manutencoes'] is List) {
      double total = 0.0;
      double pending = 0.0;
      for (var m in (map['manutencoes'] as List)) {
        final cost = (m['custo_total'] ?? 0.0) is num ? (m['custo_total'] as num).toDouble() : 0.0;
        total += cost;
        if (m['status'] != 'concluido' && m['status'] != 'pago') {
          pending += cost;
        }
      }
      map['totalSpent'] = total;
      map['pendingPayment'] = pending;
    }

    return Workshop.fromMap(map);
  }

  /// Cadastrar nova oficina credenciada
  Future<Workshop> createWorkshop(Workshop workshop) async {
    final payload = workshop.toDatabaseMap();
    payload.remove('id');

    final response = await _client
        .from(SupabaseConfig.tabelaOficinas)
        .insert(payload)
        .select()
        .single();

    return Workshop.fromMap(response);
  }

  /// Atualizar oficina existente
  Future<Workshop> updateWorkshop(Workshop workshop) async {
    final payload = workshop.toDatabaseMap();

    final response = await _client
        .from(SupabaseConfig.tabelaOficinas)
        .update(payload)
        .eq('id', workshop.id)
        .select()
        .single();

    return Workshop.fromMap(response);
  }

  /// Inativar oficina
  Future<void> deleteWorkshop(String id) async {
    await _client
        .from(SupabaseConfig.tabelaOficinas)
        .update({'status': 'inativo'})
        .eq('id', id);
  }
}
