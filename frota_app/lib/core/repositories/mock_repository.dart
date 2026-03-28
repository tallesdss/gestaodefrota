import '../../models/vehicle.dart';
import '../../models/driver.dart';
import '../../models/manager.dart';
import '../../models/contract.dart';
import '../../models/maintenance_entry.dart';
import '../../models/inspection.dart';
import '../../models/financial_entry.dart';
import '../../models/timeline_item.dart';
import '../../mock/mock_vehicles.dart';
import '../../mock/mock_drivers.dart';
import '../../mock/mock_managers.dart';
import '../../mock/mock_contracts.dart';
import '../../mock/mock_maintenances.dart';
import '../../mock/mock_inspections.dart';
import '../../mock/mock_financials.dart';
import '../../mock/mock_timeline.dart';

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

  // Managers
  Future<List<Manager>> getManagers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockManagers;
  }

  // Contracts
  Future<List<Contract>> getContracts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockContracts;
  }

  // Maintenances
  Future<List<MaintenanceEntry>> getMaintenances() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockMaintenances;
  }

  // Inspections
  Future<List<Inspection>> getInspections() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockInspections;
  }

  Future<List<Inspection>> getInspectionsByDriver(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockInspections.where((i) => i.driverId == driverId).toList();
  }

  Future<List<Inspection>> getInspectionsByVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockInspections.where((i) => i.vehicleId == vehicleId).toList();
  }

  // Financials
  Future<List<FinancialEntry>> getFinancialEntries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockFinancialEntries;
  }

  Future<List<FinancialEntry>> getFinancialEntriesByVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockFinancialEntries.where((f) => f.vehicleId == vehicleId).toList();
  }

  // Timeline
  Future<List<TimelineItem>> getDriverTimeline({required String driverId, int page = 1, int pageSize = 5}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final start = (page - 1) * pageSize;
    if (start >= mockTimeline.length) return [];
    final end = (start + pageSize) > mockTimeline.length ? mockTimeline.length : (start + pageSize);
    return mockTimeline.sublist(start, end);
  }
}
