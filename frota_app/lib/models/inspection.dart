enum InspectionType { checkin, checkout }

enum InspectionStatus { pending, approved, rejected }

class InspectionPhoto {
  final String? id;
  final String? vistoriaId;
  final String url;
  final String title;
  final String photoType;
  final bool hasDamage;
  final String? damageDescription;

  InspectionPhoto({
    this.id,
    this.vistoriaId,
    required this.url,
    required this.title,
    this.photoType = 'outro',
    this.hasDamage = false,
    this.damageDescription,
  });

  factory InspectionPhoto.fromMap(Map<String, dynamic> map) {
    return InspectionPhoto(
      id: map['id']?.toString(),
      vistoriaId: map['vistoria_id']?.toString(),
      url: (map['url_foto'] ?? map['url'] ?? '').toString(),
      title: (map['title'] ?? map['tipo_foto'] ?? 'Foto da Vistoria').toString(),
      photoType: (map['tipo_foto'] ?? map['photoType'] ?? 'outro').toString(),
      hasDamage: (map['tem_avaria'] ?? map['hasDamage'] ?? false) as bool,
      damageDescription: map['descricao_avaria'] ?? map['damageDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vistoriaId': vistoriaId,
      'url': url,
      'title': title,
      'photoType': photoType,
      'hasDamage': hasDamage,
      'damageDescription': damageDescription,
    };
  }

  Map<String, dynamic> toDatabaseMap(String parentVistoriaId) {
    String tipoEnum = 'outro';
    final t = (photoType.isNotEmpty ? photoType : title).toLowerCase();
    if (t.contains('frente')) {
      tipoEnum = 'frente';
    } else if (t.contains('traseira')) {
      tipoEnum = 'traseira';
    } else if (t.contains('esquerda')) {
      tipoEnum = 'lateral_esquerda';
    } else if (t.contains('direita')) {
      tipoEnum = 'lateral_direita';
    } else if (t.contains('painel')) {
      tipoEnum = 'painel';
    } else if (t.contains('hodometro') || t.contains('odometro')) {
      tipoEnum = 'hodometro';
    } else if (t.contains('banco')) {
      tipoEnum = 'bancos';
    } else if (t.contains('avaria') || hasDamage) {
      tipoEnum = 'avaria';
    }

    return {
      'vistoria_id': parentVistoriaId,
      'tipo_foto': tipoEnum,
      'url_foto': url,
      'tem_avaria': hasDamage,
      'descricao_avaria': damageDescription,
    };
  }
}

class ChecklistItem {
  final String? id;
  final String? vistoriaId;
  final String title;
  final bool isChecked;
  final String? notes;

  ChecklistItem({
    this.id,
    this.vistoriaId,
    required this.title,
    this.isChecked = false,
    this.notes,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id']?.toString(),
      vistoriaId: map['vistoria_id']?.toString(),
      title: (map['item_nome'] ?? map['title'] ?? '').toString(),
      isChecked: (map['conforme'] ?? map['isChecked'] ?? map['checado'] ?? false) as bool,
      notes: map['observacao'] ?? map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vistoriaId': vistoriaId,
      'title': title,
      'isChecked': isChecked,
      'notes': notes,
    };
  }

  Map<String, dynamic> toDatabaseMap(String parentVistoriaId) {
    return {
      'vistoria_id': parentVistoriaId,
      'item_nome': title,
      'conforme': isChecked,
      'observacao': notes,
    };
  }

  ChecklistItem copyWith({String? title, bool? isChecked, String? notes}) {
    return ChecklistItem(
      id: id,
      vistoriaId: vistoriaId,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
    );
  }
}

class Inspection {
  final String id;
  final String? contractId;
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
    this.contractId,
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
    if (map['fotos_vistoria'] is List) {
      photosList = (map['fotos_vistoria'] as List)
          .map((p) => InspectionPhoto.fromMap(p as Map<String, dynamic>))
          .toList();
    } else if (map['photos'] is List) {
      photosList = (map['photos'] as List)
          .map(
            (p) => p is String
                ? InspectionPhoto(url: p, title: 'Foto')
                : InspectionPhoto.fromMap(p as Map<String, dynamic>),
          )
          .toList();
    } else {
      if (map['foto_frente_url'] != null) photosList.add(InspectionPhoto(url: map['foto_frente_url'], title: 'Frente', photoType: 'frente'));
      if (map['foto_traseira_url'] != null) photosList.add(InspectionPhoto(url: map['foto_traseira_url'], title: 'Traseira', photoType: 'traseira'));
      if (map['foto_lateral_esquerda_url'] != null) photosList.add(InspectionPhoto(url: map['foto_lateral_esquerda_url'], title: 'Lateral Esquerda', photoType: 'lateral_esquerda'));
      if (map['foto_lateral_direita_url'] != null) photosList.add(InspectionPhoto(url: map['foto_lateral_direita_url'], title: 'Lateral Direita', photoType: 'lateral_direita'));
      if (map['foto_painel_url'] != null) photosList.add(InspectionPhoto(url: map['foto_painel_url'], title: 'Painel', photoType: 'painel'));
      if (map['foto_pneus_url'] != null) photosList.add(InspectionPhoto(url: map['foto_pneus_url'], title: 'Pneus', photoType: 'bancos'));
    }

    List<ChecklistItem> checklistItems = [];
    if (map['itens_checklist_vistoria'] is List) {
      checklistItems = (map['itens_checklist_vistoria'] as List)
          .map((c) => ChecklistItem.fromMap(c as Map<String, dynamic>))
          .toList();
    } else if (map['checklist'] is List) {
      checklistItems = (map['checklist'] as List)
          .map((c) => ChecklistItem.fromMap(c is Map<String, dynamic> ? c : {'title': c.toString()}))
          .toList();
    }

    return Inspection(
      id: (map['id'] ?? '').toString(),
      contractId: (map['contrato_id'] ?? map['contractId'])?.toString(),
      vehicleId: (map['veiculo_id'] ?? map['vehicleId'] ?? '').toString(),
      driverId: (map['motorista_id'] ?? map['driverId'] ?? '').toString(),
      type: parseType(map['tipo'] ?? map['type']),
      status: parseStatus(map['status']),
      dateTime: DateTime.tryParse((map['criado_em'] ?? map['dateTime'] ?? '').toString()) ?? DateTime.now(),
      kmAtInspection: (map['odometro_km'] ?? map['kmAtInspection'] ?? 0) is int
          ? (map['odometro_km'] ?? map['kmAtInspection'] ?? 0) as int
          : int.tryParse((map['odometro_km'] ?? map['kmAtInspection'] ?? '0').toString()) ?? 0,
      fuelLevel: (map['nivel_combustivel'] ?? map['fuelLevel'] ?? 1.0).toDouble(),
      photos: photosList,
      checklist: checklistItems,
      notes: (map['observacoes'] ?? map['notes'] ?? '').toString(),
      hasNewDamage: (map['tem_avaria_nova'] ?? map['hasNewDamage'] ?? false) as bool,
      reviewReason: (map['motivo_revisao'] ?? map['reviewReason'])?.toString(),
      reviewerId: (map['vistoriador_id'] ?? map['reviewerId'])?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contractId': contractId,
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

  /// Mapeamento para inserção na tabela `vistorias` do Supabase
  Map<String, dynamic> toDatabaseMap() {
    String statusStr = 'pendente_revisao';
    if (status == InspectionStatus.approved) {
      statusStr = 'aprovado';
    } else if (status == InspectionStatus.rejected) {
      statusStr = 'rejeitado';
    }

    final data = <String, dynamic>{
      'veiculo_id': vehicleId,
      'motorista_id': driverId,
      'tipo': type == InspectionType.checkin ? 'check_in' : 'check_out',
      'status': statusStr,
      'odometro_km': kmAtInspection,
      'nivel_combustivel': fuelLevel.clamp(0.0, 1.0),
      'tem_avaria_nova': hasNewDamage,
      'observacoes': notes,
    };

    if (id.isNotEmpty && id.contains('-')) {
      data['id'] = id;
    }
    if (contractId != null && contractId!.isNotEmpty) {
      data['contrato_id'] = contractId;
    }
    if (reviewerId != null && reviewerId!.isNotEmpty) {
      data['vistoriador_id'] = reviewerId;
    }
    if (reviewReason != null && reviewReason!.isNotEmpty) {
      data['motivo_revisao'] = reviewReason;
    }

    return data;
  }

  Inspection copyWith({
    String? id,
    String? contractId,
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
      contractId: contractId ?? this.contractId,
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
