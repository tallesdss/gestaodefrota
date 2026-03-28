import '../models/maintenance_entry.dart';

final List<MaintenanceEntry> mockMaintenances = [
  MaintenanceEntry(
    id: 'm1',
    vehicleId: '1',
    type: MaintenanceType.oilChange,
    description: 'Troca de óleo 5W30 e filtro de motor',
    date: DateTime(2024, 02, 10),
    kmAtMaintenance: 15420,
    cost: 250.00,
    workshop: 'Oficina Central',
  ),
  MaintenanceEntry(
    id: 'm2',
    vehicleId: '2',
    type: MaintenanceType.tires,
    description: 'Troca de 2 pneus dianteiros Michelin',
    date: DateTime(2023, 11, 25),
    kmAtMaintenance: 42300,
    cost: 1100.00,
    workshop: 'Pneus Express',
  ),
  MaintenanceEntry(
    id: 'm3',
    vehicleId: '1',
    type: MaintenanceType.brakes,
    description: 'Substituição de pastilhas de freio dianteiras',
    date: DateTime(2023, 08, 05),
    kmAtMaintenance: 8500,
    cost: 380.00,
    workshop: 'Oficina Central',
  ),
];
