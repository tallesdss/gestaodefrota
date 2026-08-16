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
import 'vehicle_repository.dart';
import 'driver_repository.dart';
import 'manager_repository.dart';
import 'contract_repository.dart';
import 'workshop_repository.dart';
import 'maintenance_repository.dart';
import 'inspection_repository.dart';
import 'financial_repository.dart';
import 'timeline_repository.dart';

/// Facade central para os repositórios Supabase.
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
    return _vehicleRepo.getVehicles(status: status, search: search);
  }

  Future<Vehicle?> getVehicleById(String id) async {
    return _vehicleRepo.getVehicleById(id);
  }

  // Drivers
  Future<List<Driver>> getDrivers({String? status, String? search, String? city}) async {
    return _driverRepo.getDrivers(status: status, search: search, city: city);
  }

  Future<Driver?> getDriverById(String id) async {
    return _driverRepo.getDriverById(id);
  }

  // Managers
  Future<List<Manager>> getManagers() async {
    return _managerRepo.getManagers();
  }

  // Contracts
  Future<List<Contract>> getContracts({String? status, String? driverId, String? vehicleId}) async {
    return _contractRepo.getContracts(status: status, driverId: driverId, vehicleId: vehicleId);
  }

  // Workshops
  Future<List<Workshop>> getWorkshops({String? search, bool? isAccredited}) async {
    return _workshopRepo.getWorkshops(search: search, isAccredited: isAccredited);
  }

  // Expense Categories
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    return _financialRepo.getExpenseCategories();
  }

  // Maintenance
  Future<List<MaintenanceEntry>> getMaintenances({String? vehicleId, String? workshopId, String? status}) async {
    return _maintenanceRepo.getMaintenances(vehicleId: vehicleId, workshopId: workshopId, status: status);
  }

  Future<List<MaintenanceEntry>> getMaintenancesByVehicle(String vehicleId) async {
    return _maintenanceRepo.getMaintenances(vehicleId: vehicleId);
  }

  Future<MaintenanceEntry?> getMaintenanceById(String id) async {
    return _maintenanceRepo.getMaintenanceById(id);
  }

  Future<void> addMaintenance(MaintenanceEntry entry) async {
    await _maintenanceRepo.createMaintenance(entry);
  }

  Future<void> updateMaintenance(MaintenanceEntry updated) async {
    await _maintenanceRepo.updateMaintenance(updated);
  }

  Future<void> deleteMaintenance(String id) async {
    await _maintenanceRepo.deleteMaintenance(id);
  }

  // Inspections
  Future<List<Inspection>> getInspections({String? driverId, String? vehicleId, String? status}) async {
    return _inspectionRepo.getInspections(driverId: driverId, vehicleId: vehicleId, status: status);
  }

  Future<Inspection?> getInspectionById(String id) async {
    return _inspectionRepo.getInspectionById(id);
  }

  Future<List<Inspection>> getInspectionsByDriver(String driverId) async {
    return _inspectionRepo.getInspections(driverId: driverId);
  }

  Future<List<Inspection>> getInspectionsByVehicle(String vehicleId) async {
    return _inspectionRepo.getInspections(vehicleId: vehicleId);
  }

  Future<void> updateInspection(Inspection updated) async {
    await _inspectionRepo.updateInspectionStatus(updated.id, updated.status);
  }

  // Financials
  Future<List<FinancialEntry>> getFinancialEntries({String? type, String? status, String? driverId, String? vehicleId}) async {
    return _financialRepo.getFinancialEntries(type: type, status: status, driverId: driverId, vehicleId: vehicleId);
  }

  Future<List<FinancialEntry>> getFinancialEntriesByVehicle(String vehicleId) async {
    return _financialRepo.getFinancialEntries(vehicleId: vehicleId);
  }

  Future<List<FinancialEntry>> getFinancialEntriesByDriver(String driverId) async {
    return _financialRepo.getFinancialEntries(driverId: driverId);
  }

  // Timeline
  Future<List<TimelineItem>> getDriverTimeline({
    required String driverId,
    int page = 1,
    int pageSize = 5,
  }) async {
    return _timelineRepo.getDriverTimeline(driverId: driverId, page: page, pageSize: pageSize);
  }

  Future<void> addFinancialEntry(FinancialEntry entry) async {
    await _financialRepo.createFinancialEntry(entry);
  }

  Future<void> markAsPaid(String entryId, {DateTime? paymentDate, String? paymentMethod}) async {
    await _financialRepo.markAsPaid(entryId, paymentDate: paymentDate, paymentMethod: paymentMethod);
  }
}
