import '../models/inspection.dart';

List<Inspection> mockInspections = [
  Inspection(
    id: 'i1',
    vehicleId: 'v2',
    driverId: 'd1',
    type: InspectionType.checkin,
    dateTime: DateTime(2024, 01, 01, 09, 30),
    kmAtInspection: 30000,
    fuelLevel: 0.75,
    photos: [
      'https://via.placeholder.com/150?text=Front',
      'https://via.placeholder.com/150?text=Rear',
    ],
    notes: 'Veículo em perfeito estado.',
    hasNewDamage: false,
  ),
];
