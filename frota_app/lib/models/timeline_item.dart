class TimelineItem {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? type; // 'maintenance', 'document', 'vehicle', 'financial'

  TimelineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.type,
  });

  factory TimelineItem.fromMap(Map<String, dynamic> map) {
    return TimelineItem(
      id: (map['id'] ?? '').toString(),
      title: map['titulo'] ?? map['title'] ?? '',
      description: map['descricao'] ?? map['description'] ?? '',
      date: DateTime.tryParse(map['criado_em'] ?? map['date'] ?? '') ?? DateTime.now(),
      type: map['tipo_evento'] ?? map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'titulo': title,
      'descricao': description,
      'tipo_evento': type ?? 'evento',
    };
  }
}
