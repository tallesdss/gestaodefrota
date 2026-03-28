import '../models/inspection.dart';

List<Inspection> mockInspections = [
  Inspection(
    id: 'i1',
    vehicleId: '1',
    driverId: 'd1',
    type: InspectionType.checkin,
    dateTime: DateTime(2024, 03, 01, 08, 30),
    kmAtInspection: 15420,
    fuelLevel: 0.85,
    photos: ['https://placehold.co/600x400/png?text=Frente', 'https://placehold.co/600x400/png?text=Lateral'],
    notes: 'Veículo em ótimo estado.',
    hasNewDamage: false,
  ),
  Inspection(
    id: 'i2',
    vehicleId: '2',
    driverId: 'd2',
    type: InspectionType.checkout,
    dateTime: DateTime(2024, 02, 28, 18, 00),
    kmAtInspection: 42300,
    fuelLevel: 0.25,
    photos: ['https://placehold.co/600x400/png?text=Avaria+Parachoque'],
    notes: 'Pequeno risco no parachoque traseiro.',
    hasNewDamage: true,
  ),
];
