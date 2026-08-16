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
import 'vehicle_repository.dart';
import 'driver_repository.dart';
import 'manager_repository.dart';
import 'contract_repository.dart';
import 'workshop_repository.dart';
import 'maintenance_repository.dart';
import 'inspection_repository.dart';
import 'financial_repository.dart';
import 'timeline_repository.dart';

class MockRepository {
  static final MockRepository _instance = MockRepository._internal();
  factory MockRepository() => _instance;
  MockRepository._internal();

  final VehicleRepository _vehicleRepo = VehicleRepository();
  final DriverRepository _driverRepo = DriverRepository();
  final ManagerRepository _managerRepo = ManagerRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final WorkshopRepository _workshopRepo = WorkshopRepository();
  final MaintenanceRepository _maintenanceRepo = MaintenanceRepository();
  final InspectionRepository _inspectionRepo = InspectionRepository();
  final FinancialRepository _financialRepo = FinancialRepository();
  final TimelineRepository _timelineRepo = TimelineRepository();

  // Vehicles
  Future<List<Vehicle>> getVehicles({String? status, String? search}) async {
    try {
      final list = await _vehicleRepo.getVehicles(status: status, search: search);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockVehicles;
  }

  Future<Vehicle> getVehicleById(String id) async {
    try {
      final v = await _vehicleRepo.getVehicleById(id);
      if (v != null) return v;
    } catch (_) {}
    return mockVehicles.firstWhere((v) => v.id == id, orElse: () => mockVehicles.first);
  }

  // Drivers
  Future<List<Driver>> getDrivers({String? status, String? search, String? city}) async {
    try {
      final list = await _driverRepo.getDrivers(status: status, search: search, city: city);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockDrivers;
  }

  // Managers
  Future<List<Manager>> getManagers() async {
    try {
      final list = await _managerRepo.getManagers();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockManagers;
  }

  // Contracts
  Future<List<Contract>> getContracts({String? status, String? driverId, String? vehicleId}) async {
    try {
      final list = await _contractRepo.getContracts(status: status, driverId: driverId, vehicleId: vehicleId);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockContracts;
  }

  // Workshops
  Future<List<Workshop>> getWorkshops({String? search, bool? isAccredited}) async {
    try {
      final list = await _workshopRepo.getWorkshops(search: search, isAccredited: isAccredited);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockWorkshops;
  }

  // Expense Categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    try {
      final list = await _financialRepo.getExpenseCategories();
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockExpenseCategories;
  }

  Future<List<MaintenanceEntry>> getMaintenances({String? vehicleId, String? workshopId, String? status}) async {
    try {
      final list = await _maintenanceRepo.getMaintenances(vehicleId: vehicleId, workshopId: workshopId, status: status);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockMaintenances;
  }

  Future<List<MaintenanceEntry>> getMaintenancesByVehicle(String vehicleId) async {
    return getMaintenances(vehicleId: vehicleId);
  }

  Future<MaintenanceEntry?> getMaintenanceById(String id) async {
    try {
      final m = await _maintenanceRepo.getMaintenanceById(id);
      if (m != null) return m;
    } catch (_) {}
    try {
      return mockMaintenances.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addMaintenance(MaintenanceEntry entry) async {
    try {
      await _maintenanceRepo.createMaintenance(entry);
    } catch (_) {
      mockMaintenances.add(entry);
    }
  }

  Future<void> updateMaintenance(MaintenanceEntry updated) async {
    try {
      await _maintenanceRepo.updateMaintenance(updated);
    } catch (_) {
      final index = mockMaintenances.indexWhere((m) => m.id == updated.id);
      if (index != -1) mockMaintenances[index] = updated;
    }
  }

  Future<void> deleteMaintenance(String id) async {
    try {
      await _maintenanceRepo.deleteMaintenance(id);
    } catch (_) {
      mockMaintenances.removeWhere((m) => m.id == id);
    }
  }

  // Inspections
  Future<List<Inspection>> getInspections({String? driverId, String? vehicleId, String? status}) async {
    try {
      final list = await _inspectionRepo.getInspections(driverId: driverId, vehicleId: vehicleId, status: status);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockInspections;
  }

  Future<Inspection?> getInspectionById(String id) async {
    try {
      final i = await _inspectionRepo.getInspectionById(id);
      if (i != null) return i;
    } catch (_) {}
    try {
      return mockInspections.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Inspection>> getInspectionsByDriver(String driverId) async {
    return getInspections(driverId: driverId);
  }

  Future<List<Inspection>> getInspectionsByVehicle(String vehicleId) async {
    return getInspections(vehicleId: vehicleId);
  }

  Future<void> updateInspection(Inspection updated) async {
    try {
      await _inspectionRepo.updateInspectionStatus(updated.id, updated.status);
    } catch (_) {
      final index = mockInspections.indexWhere((i) => i.id == updated.id);
      if (index != -1) mockInspections[index] = updated;
    }
  }

  // Financials
  Future<List<FinancialEntry>> getFinancialEntries({String? type, String? status, String? driverId, String? vehicleId}) async {
    try {
      final list = await _financialRepo.getFinancialEntries(type: type, status: status, driverId: driverId, vehicleId: vehicleId);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    return mockFinancialEntries;
  }

  Future<List<FinancialEntry>> getFinancialEntriesByVehicle(String vehicleId) async {
    return getFinancialEntries(vehicleId: vehicleId);
  }

  Future<List<FinancialEntry>> getFinancialEntriesByDriver(String driverId) async {
    return getFinancialEntries(driverId: driverId);
  }

  // Timeline
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      final list = await _timelineRepo.getDriverTimeline(driverId: driverId, page: page, pageSize: pageSize);
      if (list.isNotEmpty) return list;
    } catch (_) {}
    final start = (page - 1) * pageSize;
    if (start >= mockTimeline.length) return [];
    final end = (start + pageSize) > mockTimeline.length ? mockTimeline.length : (start + pageSize);
    return mockTimeline.sublist(start, end);
  }

  Future<void> addFinancialEntry(FinancialEntry entry) async {
    try {
      await _financialRepo.createFinancialEntry(entry);
    } catch (_) {
      mockFinancialEntries.add(entry);
    }
  }

  Future<void> markAsPaid(String entryId, {DateTime? paymentDate, String? paymentMethod}) async {
    try {
      await _financialRepo.markAsPaid(entryId, paymentDate: paymentDate, paymentMethod: paymentMethod);
    } catch (_) {}
  }
}
