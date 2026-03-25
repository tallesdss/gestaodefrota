import '../../models/vehicle.dart';
import '../../models/driver.dart';
import '../../models/financial_entry.dart';
import '../../mock/mock_vehicles.dart';
import '../../mock/mock_drivers.dart';
import '../../mock/mock_financials.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal();

  // Vehicles
  Future<List<Vehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockVehicles;
  }

  Future<Vehicle> getVehicleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockVehicles.firstWhere((v) => v.id == id);
  }

  // Drivers
  Future<List<Driver>> getDrivers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockDrivers;
  }

  // Financials
  Future<List<FinancialEntry>> getFinancialEntries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockFinancialEntries;
  }
}
