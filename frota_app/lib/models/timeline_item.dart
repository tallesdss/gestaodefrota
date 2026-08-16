class TimelineItem {
  final String id;
  final String? driverId;
  final String? vehicleId;
  final String? authorId;
  final String title;
  final String description;
  final DateTime date;
  final String? type; // 'maintenance', 'document', 'vehicle', 'financial', 'multa', 'evento'

  TimelineItem({
    required this.id,
    this.driverId,
    this.vehicleId,
    this.authorId,
    required this.title,
    required this.description,
    required this.date,
    this.type,
  });

  factory TimelineItem.fromMap(Map<String, dynamic> map) {
    return TimelineItem(
      id: (map['id'] ?? '').toString(),
      driverId: (map['motorista_id'] ?? map['driverId'])?.toString(),
      vehicleId: (map['veiculo_id'] ?? map['vehicleId'])?.toString(),
      authorId: (map['autor_id'] ?? map['authorId'])?.toString(),
      title: (map['titulo'] ?? map['title'] ?? '').toString(),
      description: (map['descricao'] ?? map['description'] ?? '').toString(),
      date: DateTime.tryParse((map['criado_em'] ?? map['date'] ?? '').toString()) ?? DateTime.now(),
      type: (map['tipo_evento'] ?? map['type'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'driverId': driverId,
      'vehicleId': vehicleId,
      'authorId': authorId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  /// Mapeamento para a tabela `historico_atividades` do Supabase
  Map<String, dynamic> toDatabaseMap({required String defaultDriverId}) {
    final data = <String, dynamic>{
      'motorista_id': driverId ?? defaultDriverId,
      'tipo_evento': type ?? 'evento',
      'titulo': title.trim(),
      'descricao': description.trim(),
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (vehicleId != null && vehicleId!.isNotEmpty) {
      data['veiculo_id'] = vehicleId;
    }
    if (authorId != null && authorId!.isNotEmpty) {
      data['autor_id'] = authorId;
    }

    return data;
  }
}
