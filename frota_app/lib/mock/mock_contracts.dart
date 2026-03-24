import '../models/contract.dart';

List<Contract> mockContracts = [
  Contract(
    id: 'c1',
    vehicleId: 'v2',
    driverId: 'd1',
    type: 'prefecture',
    startDate: DateTime(2024, 01, 01),
    endDate: DateTime(2025, 01, 01),
    weeklyValue: 0,
    monthlyValue: 2500.0,
    status: ContractStatus.active,
    depositPaid: true,
  ),
];
