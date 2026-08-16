import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/timeline_item.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para Histórico de Atividades e Linha do Tempo no Supabase
class TimelineRepository {
  final SupabaseClient _client;

  TimelineRepository({SupabaseClient? client}) : _client = client ?? supabase;

  /// Obter linha do tempo paginada de um motorista
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final from = (page - 1) * pageSize;
    final to = from + pageSize - 1;

    final response = await _client
        .from(SupabaseConfig.tabelaHistoricoAtividades)
        .select()
        .eq('motorista_id', driverId)
        .order('criado_em', ascending: false)
        .range(from, to);

    return (response as List)
        .map((t) => TimelineItem.fromMap(Map<String, dynamic>.from(t as Map)))
        .toList();
  }

  /// Registrar novo evento na timeline
  Future<TimelineItem> addTimelineItem(TimelineItem item, {String? defaultDriverId}) async {
    final payload = item.toDatabaseMap(defaultDriverId: defaultDriverId ?? '10000000-0000-0000-0000-000000000001');
    payload.remove('id');

    final response = await _client
        .from(SupabaseConfig.tabelaHistoricoAtividades)
        .insert(payload)
        .select()
        .single();

    return TimelineItem.fromMap(response);
  }
}
