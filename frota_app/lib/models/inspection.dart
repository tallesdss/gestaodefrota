enum InspectionType { 
  checkin, 
  checkout 
}

enum InspectionStatus { 
  pending, 
  approved, 
  rejected 
}

class InspectionPhoto {
  final String url;
  final String title;

  InspectionPhoto({required this.url, required this.title});

  factory InspectionPhoto.fromMap(Map<String, dynamic> map) {
    return InspectionPhoto(
      url: map['url'],
      title: map['title'] ?? 'Foto da Vistoria',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'title': title,
    };
  }
}

class ChecklistItem {
  final String title;
  final bool isChecked;

  ChecklistItem({required this.title, this.isChecked = false});

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      title: map['title'],
      isChecked: map['isChecked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isChecked': isChecked,
    };
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
    return Inspection(
      id: map['id'],
      vehicleId: map['vehicleId'],
      driverId: map['driverId'],
      type: InspectionType.values.firstWhere((e) => e.name == map['type']),
      status: map['status'] != null 
          ? InspectionStatus.values.firstWhere((e) => e.name == map['status'])
          : InspectionStatus.pending,
      dateTime: DateTime.parse(map['dateTime']),
      kmAtInspection: map['kmAtInspection'],
      fuelLevel: map['fuelLevel'].toDouble(),
      photos: (map['photos'] as List)
          .map((p) => p is String 
              ? InspectionPhoto(url: p, title: 'Foto') 
              : InspectionPhoto.fromMap(p as Map<String, dynamic>))
          .toList(),
      checklist: map['checklist'] != null
          ? (map['checklist'] as List).map((c) => ChecklistItem.fromMap(c)).toList()
          : [],
      notes: map['notes'],
      hasNewDamage: map['hasNewDamage'] as bool,
      reviewReason: map['reviewReason'],
      reviewerId: map['reviewerId'],
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
