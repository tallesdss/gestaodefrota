import 'package:frota_app/core/config/supabase_config.dart';
import 'package:frota_app/core/repositories/driver_repository.dart';
import 'package:frota_app/core/repositories/contract_repository.dart';
import 'package:frota_app/core/repositories/vehicle_repository.dart';
import 'package:frota_app/core/repositories/financial_repository.dart';

void main() async {
  await SupabaseConfig.initialize();
  final driverRepo = DriverRepository();
  final contractRepo = ContractRepository();
  final vehicleRepo = VehicleRepository();
  final finRepo = FinancialRepository();

  final drivers = await driverRepo.getDrivers(status: 'ativo');
  print('Total drivers found: ${drivers.length}');
  for (var d in drivers) {
    print('Driver ID: ${d.id} | Name: "${d.name}" | VehicleId: ${d.currentVehicleId}');
    final c = await contractRepo.getActiveContractByDriver(d.id);
    print('  Contract: ${c?.contractNumber} | VehId: ${c?.vehicleId}');
    if (c != null && c.vehicleId.isNotEmpty) {
      final v = await vehicleRepo.getVehicleById(c.vehicleId);
      print('  Vehicle: ${v?.brand} ${v?.model} (${v?.plate}) - KM: ${v?.currentKm}');
    }
    final debts = await finRepo.getFinancialEntries(driverId: d.id);
    print('  Debts count: ${debts.length}');
  }
}
