import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

enum AppNotificationType { info, warning, danger, success }

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AppNotificationType type;
  final bool isRead;
  final String? category;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.category,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
      category: category,
    );
  }
}

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  final SupabaseClient _client = SupabaseConfig.client;
  RealtimeChannel? _fleetChannel;
  RealtimeChannel? _inspectionChannel;
  RealtimeChannel? _financeChannel;

  final ValueNotifier<List<AppNotification>> notificationsNotifier =
      ValueNotifier<List<AppNotification>>([]);

  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _loadInitialNotifications();
    _subscribeChannels();
  }

  Future<void> _loadInitialNotifications() async {
    try {
      final res = await _client
          .from('historico_atividades')
          .select()
          .order('data_hora', ascending: false)
          .limit(20);

      final List<AppNotification> list = [];
      for (final row in res) {
        list.add(_mapActivityToNotification(row));
      }

      notificationsNotifier.value = list;
      _updateUnreadCount();
    } catch (_) {
      notificationsNotifier.value = [];
      _updateUnreadCount();
    }
  }

  void _subscribeChannels() {
    try {
      // 1. Channel for Fleet Changes
      _fleetChannel = _client.channel('public:veiculos').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'veiculos',
        callback: (payload) {
          final eventType = payload.eventType.name.toUpperCase();
          final newRecord = payload.newRecord;
          final plate = newRecord['placa'] ?? 'Veículo';
          final status = newRecord['status'] ?? 'Atualizado';

          _addInAppNotification(
            title: 'ATUALIZAÇÃO DE FROTA ($eventType)',
            message: 'Veículo $plate agora está $status.',
            type: AppNotificationType.info,
            category: 'frota',
          );
        },
      )..subscribe();

      // 2. Channel for Inspections
      _inspectionChannel = _client.channel('public:vistorias').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'vistorias',
        callback: (payload) {
          final tipo = payload.newRecord['tipo'] ?? 'Vistoria';
          final status = payload.newRecord['status'] ?? 'Pendente';

          _addInAppNotification(
            title: 'NOVA VISTORIA ($tipo)',
            message: 'Status atualizado para: $status.',
            type: status == 'aprovado' ? AppNotificationType.success : AppNotificationType.warning,
            category: 'vistoria',
          );
        },
      )..subscribe();

      // 3. Channel for Financial entries
      _financeChannel = _client.channel('public:lancamentos_financeiros').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'lancamentos_financeiros',
        callback: (payload) {
          final desc = payload.newRecord['descricao'] ?? 'Lançamento';
          final valor = payload.newRecord['valor'] ?? 0;
          final status = payload.newRecord['status'] ?? 'pendente';

          _addInAppNotification(
            title: 'MOVIMENTAÇÃO FINANCEIRA',
            message: '$desc no valor de R\$ $valor ($status).',
            type: status == 'pago' ? AppNotificationType.success : AppNotificationType.danger,
            category: 'financeiro',
          );
        },
      )..subscribe();
    } catch (_) {}
  }

  void _addInAppNotification({
    required String title,
    required String message,
    required AppNotificationType type,
    String? category,
  }) {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
      category: category,
      isRead: false,
    );

    final current = List<AppNotification>.from(notificationsNotifier.value);
    current.insert(0, notif);
    notificationsNotifier.value = current;
    _updateUnreadCount();
  }

  void markAllAsRead() {
    final updated = notificationsNotifier.value
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notificationsNotifier.value = updated;
    _updateUnreadCount();
  }

  void markAsRead(String id) {
    final updated = notificationsNotifier.value
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    notificationsNotifier.value = updated;
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCountNotifier.value =
        notificationsNotifier.value.where((n) => !n.isRead).length;
  }

  AppNotification _mapActivityToNotification(Map<String, dynamic> row) {
    final tipo = row['tipo_evento']?.toString().toLowerCase() ?? '';
    AppNotificationType type = AppNotificationType.info;
    if (tipo.contains('manutencao') || tipo.contains('alerta')) {
      type = AppNotificationType.warning;
    } else if (tipo.contains('atraso') || tipo.contains('inadimplencia')) {
      type = AppNotificationType.danger;
    } else if (tipo.contains('aprov') || tipo.contains('pagamento')) {
      type = AppNotificationType.success;
    }

    return AppNotification(
      id: (row['id'] ?? DateTime.now().millisecondsSinceEpoch).toString(),
      title: (row['titulo'] ?? row['tipo_evento'] ?? 'Notificação').toString().toUpperCase(),
      message: (row['descricao'] ?? '').toString(),
      timestamp: DateTime.tryParse(row['data_hora']?.toString() ?? '') ?? DateTime.now(),
      type: type,
      category: tipo,
      isRead: false,
    );
  }

  void dispose() {
    _fleetChannel?.unsubscribe();
    _inspectionChannel?.unsubscribe();
    _financeChannel?.unsubscribe();
    _initialized = false;
  }
}
