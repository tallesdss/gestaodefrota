import '../../models/vehicle.dart';
import '../../models/driver.dart';
import '../../models/manager.dart';
import '../../models/contract.dart';
import '../../models/maintenance_entry.dart';
import '../../models/inspection.dart';
import '../../models/financial_entry.dart';
import '../../models/timeline_item.dart';
import '../../models/workshop.dart';
import '../../models/expense_category.dart';
import '../../mock/mock_vehicles.dart';
import '../../mock/mock_drivers.dart';
import '../../mock/mock_managers.dart';
import '../../mock/mock_contracts.dart';
import '../../mock/mock_maintenances.dart';
import '../../mock/mock_inspections.dart';
import '../../mock/mock_financials.dart';
import '../../mock/mock_timeline.dart';
import '../../mock/mock_workshops.dart';
import '../../mock/mock_expense_categories.dart';

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

  // Workshops
  Future<List<Workshop>> getWorkshops() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockWorkshops;
  }

  // Expense Categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockExpenseCategories;
  }

  Future<List<MaintenanceEntry>> getMaintenances() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockMaintenances;
  }

  Future<List<MaintenanceEntry>> getMaintenancesByVehicle(
    String vehicleId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockMaintenances.where((m) => m.vehicleId == vehicleId).toList();
  }

  Future<MaintenanceEntry?> getMaintenanceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return mockMaintenances.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addMaintenance(MaintenanceEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockMaintenances.add(entry);
  }

  Future<void> updateMaintenance(MaintenanceEntry updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = mockMaintenances.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      mockMaintenances[index] = updated;
    }
  }

  Future<void> deleteMaintenance(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockMaintenances.removeWhere((m) => m.id == id);
  }

  // Inspections
  Future<List<Inspection>> getInspections() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockInspections;
  }

  Future<Inspection?> getInspectionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return mockInspections.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Inspection>> getInspectionsByDriver(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockInspections.where((i) => i.driverId == driverId).toList();
  }

  Future<List<Inspection>> getInspectionsByVehicle(String vehicleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockInspections.where((i) => i.vehicleId == vehicleId).toList();
  }

  Future<void> updateInspection(Inspection updated) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = mockInspections.indexWhere((i) => i.id == updated.id);
    if (index != -1) {
      mockInspections[index] = updated;
    }
  }

  // Financials
  Future<List<FinancialEntry>> getFinancialEntries() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockFinancialEntries;
  }

  Future<List<FinancialEntry>> getFinancialEntriesByVehicle(
    String vehicleId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockFinancialEntries.where((f) => f.vehicleId == vehicleId).toList();
  }

  Future<List<FinancialEntry>> getFinancialEntriesByDriver(
    String driverId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockFinancialEntries.where((f) => f.driverId == driverId).toList();
  }

  // Timeline
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final start = (page - 1) * pageSize;
    if (start >= mockTimeline.length) return [];
    final end = (start + pageSize) > mockTimeline.length
        ? mockTimeline.length
        : (start + pageSize);
    return mockTimeline.sublist(start, end);
  }

  Future<void> addFinancialEntry(FinancialEntry entry) async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockFinancialEntries.add(entry);
  }
}
