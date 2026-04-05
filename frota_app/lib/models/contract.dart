enum ContractStatus { active, expired, cancelled }

class Contract {
  final String id;
  final String vehicleId;
  final String driverId;
  final String type; // uber / prefecture
  final DateTime startDate;
  final DateTime endDate;
  final double weeklyValue;
  final double monthlyValue;
  final ContractStatus status;
  final bool depositPaid;

  Contract({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.weeklyValue,
    required this.monthlyValue,
    required this.status,
    required this.depositPaid,
  });

  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map['id'],
      vehicleId: map['vehicleId'],
      driverId: map['driverId'],
      type: map['type'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      weeklyValue: map['weeklyValue'].toDouble(),
      monthlyValue: map['monthlyValue'].toDouble(),
      status: ContractStatus.values.firstWhere((e) => e.name == map['status']),
      depositPaid: map['depositPaid'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'weeklyValue': weeklyValue,
      'monthlyValue': monthlyValue,
      'status': status.name,
      'depositPaid': depositPaid,
    };
  }
}
