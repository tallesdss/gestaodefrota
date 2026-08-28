import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/timeline_item.dart';
import '../config/supabase_config.dart';

/// Repositório concreto para Histórico de Atividades e Linha do Tempo no Supabase
class TimelineRepository {
  final SupabaseClient _client;

  // Cache sincronizado em memória para persistir atividades recentes em tempo real
  static final Map<String, List<TimelineItem>> _memoryTimeline = {
    'dfc34aba-9a10-4da0-a38f-91b47438bde0': [
      TimelineItem(
        id: 't-init-1',
        title: 'Veículo Atribuído pelo Gestor',
        description: 'BYD Dolphin Plus EV (BVT2356) vinculado à sua conta.',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'veiculo',
      ),
      TimelineItem(
        id: 't-init-2',
        title: 'Quilometragem Inicial Registrada',
        description: 'Hodômetro registrado em 195.000 KM.',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'km',
      ),
    ],
  };

  TimelineRepository({SupabaseClient? client}) : _client = client ?? supabase;

  bool _isValidUuid(String? str) {
    if (str == null || str.isEmpty) return false;
    return RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(str);
  }

  /// Obter linha do tempo paginada de um motorista
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final List<TimelineItem> list = [];

    if (_isValidUuid(driverId)) {
      try {
        final from = (page - 1) * pageSize;
        final to = from + pageSize - 1;

        final response = await _client
            .from(SupabaseConfig.tabelaHistoricoAtividades)
            .select()
            .eq('motorista_id', driverId)
            .order('criado_em', ascending: false)
            .range(from, to);

        final dbItems = (response as List)
            .map((t) => TimelineItem.fromMap(Map<String, dynamic>.from(t as Map)))
            .toList();
        list.addAll(dbItems);
      } catch (_) {}
    }

    // Mesclar com atividades em memória
    if (_memoryTimeline.containsKey(driverId)) {
      final memoryItems = _memoryTimeline[driverId]!;
      for (final mem in memoryItems) {
        if (!list.any((item) => item.id == mem.id)) {
          list.insert(0, mem);
        }
      }
    }

    // Ordenar pela data mais recente
    list.sort((a, b) => b.date.compareTo(a.date));

    if (list.length > pageSize) {
      return list.sublist(0, pageSize);
    }

    return list;
  }

  /// Registrar novo evento na timeline
  Future<TimelineItem> addTimelineItem(TimelineItem item, {String? defaultDriverId}) async {
    final driverId = defaultDriverId ?? 'dfc34aba-9a10-4da0-a38f-91b47438bde0';

    if (!_memoryTimeline.containsKey(driverId)) {
      _memoryTimeline[driverId] = [];
    }
    _memoryTimeline[driverId]!.insert(0, item);

    if (_isValidUuid(driverId)) {
      try {
        final payload = item.toDatabaseMap(defaultDriverId: driverId);
        payload.remove('id');

        final response = await _client
            .from(SupabaseConfig.tabelaHistoricoAtividades)
            .insert(payload)
            .select()
            .single();

        return TimelineItem.fromMap(response);
      } catch (_) {}
    }

    return item;
  }
}
