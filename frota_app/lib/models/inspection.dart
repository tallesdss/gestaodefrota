enum InspectionType { checkin, checkout }

enum InspectionStatus { pending, approved, rejected }

class InspectionPhoto {
  final String url;
  final String title;

  InspectionPhoto({required this.url, required this.title});

  factory InspectionPhoto.fromMap(Map<String, dynamic> map) {
    return InspectionPhoto(
      url: map['url'] ?? '',
      title: map['title'] ?? 'Foto da Vistoria',
    );
  }

  Map<String, dynamic> toMap() {
    return {'url': url, 'title': title};
  }
}

class ChecklistItem {
  final String title;
  final bool isChecked;

  ChecklistItem({required this.title, this.isChecked = false});

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      title: map['title'] ?? '',
      isChecked: map['isChecked'] ?? map['checado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isChecked': isChecked};
  }

  ChecklistItem copyWith({String? title, bool? isChecked}) {
    return ChecklistItem(
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class Inspection {
  final String id;
  final String vehicleId;
  final String driverId;
  final InspectionType type;
  final InspectionStatus status;
  final DateTime dateTime;
  final int kmAtInspection;
  final double fuelLevel;
  final List<InspectionPhoto> photos;
  final List<ChecklistItem> checklist;
  final String notes;
  final bool hasNewDamage;
  final String? reviewReason;
  final String? reviewerId;

  Inspection({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.type,
    this.status = InspectionStatus.pending,
    required this.dateTime,
    required this.kmAtInspection,
    required this.fuelLevel,
    required this.photos,
    required this.checklist,
    required this.notes,
    required this.hasNewDamage,
    this.reviewReason,
    this.reviewerId,
  });

  factory Inspection.fromMap(Map<String, dynamic> map) {
    InspectionType parseType(dynamic val) {
      if (val == null) return InspectionType.checkin;
      final s = val.toString().toLowerCase();
      if (s == 'checkout' || s == 'check_out') return InspectionType.checkout;
      return InspectionType.checkin;
    }

    InspectionStatus parseStatus(dynamic val) {
      if (val == null) return InspectionStatus.pending;
      final s = val.toString().toLowerCase();
      if (s == 'aprovado' || s == 'approved') return InspectionStatus.approved;
      if (s == 'rejeitado' || s == 'rejected') return InspectionStatus.rejected;
      return InspectionStatus.pending;
    }

    List<InspectionPhoto> photosList = [];
    if (map['photos'] is List) {
      photosList = (map['photos'] as List)
          .map(
            (p) => p is String
                ? InspectionPhoto(url: p, title: 'Foto')
                : InspectionPhoto.fromMap(p as Map<String, dynamic>),
          )
          .toList();
    } else {
      // Direct columns from Supabase vistorias table
      if (map['foto_frente_url'] != null) photosList.add(InspectionPhoto(url: map['foto_frente_url'], title: 'Frente'));
      if (map['foto_traseira_url'] != null) photosList.add(InspectionPhoto(url: map['foto_traseira_url'], title: 'Traseira'));
      if (map['foto_lateral_esquerda_url'] != null) photosList.add(InspectionPhoto(url: map['foto_lateral_esquerda_url'], title: 'Lateral Esquerda'));
      if (map['foto_lateral_direita_url'] != null) photosList.add(InspectionPhoto(url: map['foto_lateral_direita_url'], title: 'Lateral Direita'));
      if (map['foto_painel_url'] != null) photosList.add(InspectionPhoto(url: map['foto_painel_url'], title: 'Painel'));
      if (map['foto_pneus_url'] != null) photosList.add(InspectionPhoto(url: map['foto_pneus_url'], title: 'Pneus'));
    }

    return Inspection(
      id: (map['id'] ?? '').toString(),
      vehicleId: map['veiculo_id'] ?? map['vehicleId'] ?? '',
      driverId: map['motorista_id'] ?? map['driverId'] ?? '',
      type: parseType(map['tipo'] ?? map['type']),
      status: parseStatus(map['status']),
      dateTime: DateTime.tryParse(map['criado_em'] ?? map['dateTime'] ?? '') ?? DateTime.now(),
      kmAtInspection: (map['odometro_km'] ?? map['kmAtInspection'] ?? 0) as int,
      fuelLevel: (map['fuelLevel'] ?? 1.0).toDouble(),
      photos: photosList,
      checklist: map['checklist'] != null
          ? (map['checklist'] as List)
                .map((c) => ChecklistItem.fromMap(c))
                .toList()
          : [],
      notes: map['observacoes'] ?? map['notes'] ?? '',
      hasNewDamage: (map['hasNewDamage'] ?? (map['danos_json'] != null)) as bool? ?? false,
      reviewReason: map['reviewReason'],
      reviewerId: map['vistoriador_id'] ?? map['reviewerId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'type': type.name,
      'status': status.name,
      'dateTime': dateTime.toIso8601String(),
      'kmAtInspection': kmAtInspection,
      'fuelLevel': fuelLevel,
      'photos': photos.map((p) => p.toMap()).toList(),
      'checklist': checklist.map((c) => c.toMap()).toList(),
      'notes': notes,
      'hasNewDamage': hasNewDamage,
      'reviewReason': reviewReason,
      'reviewerId': reviewerId,
    };
  }

  Map<String, dynamic> toDatabaseMap() {
    return {
      'id': id,
      'veiculo_id': vehicleId,
      'motorista_id': driverId,
      'tipo': type == InspectionType.checkin ? 'check_in' : 'check_out',
      'status': status == InspectionStatus.approved
          ? 'aprovado'
          : (status == InspectionStatus.rejected ? 'rejeitado' : 'pendente_revisao'),
      'odometro_km': kmAtInspection,
      'observacoes': notes,
      'danos_json': {'hasNewDamage': hasNewDamage},
    };
  }

  Inspection copyWith({
    String? id,
    String? vehicleId,
    String? driverId,
    InspectionType? type,
    InspectionStatus? status,
    DateTime? dateTime,
    int? kmAtInspection,
    double? fuelLevel,
    List<InspectionPhoto>? photos,
    List<ChecklistItem>? checklist,
    String? notes,
    bool? hasNewDamage,
    String? reviewReason,
    String? reviewerId,
  }) {
    return Inspection(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      status: status ?? this.status,
      dateTime: dateTime ?? this.dateTime,
      kmAtInspection: kmAtInspection ?? this.kmAtInspection,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      photos: photos ?? this.photos,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      hasNewDamage: hasNewDamage ?? this.hasNewDamage,
      reviewReason: reviewReason ?? this.reviewReason,
      reviewerId: reviewerId ?? this.reviewerId,
    );
  }
}
