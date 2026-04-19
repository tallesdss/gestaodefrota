import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../mock/mock_companies.dart';

class CompanyManager extends ChangeNotifier {
  static final CompanyManager _instance = CompanyManager._internal();
  factory CompanyManager() => _instance;
  CompanyManager._internal();

  final List<Company> _companies = MockCompanies.getCompanies();

  List<Company> get companies => List.unmodifiable(_companies);

  void addCompany(Company company) {
    _companies.add(company);
    notifyListeners();
  }

  void updateCompany(Company company) {
    final index = _companies.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      _companies[index] = company;
      notifyListeners();
    }
  }

  void removeCompany(String id) {
    _companies.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void changeStatus(String id, CompanyStatus status) {
    final index = _companies.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _companies[index];
      _companies[index] = Company(
        id: old.id,
        name: old.name,
        email: old.email,
        cnpj: old.cnpj,
        phone: old.phone,
        plan: old.plan,
        status: status,
        vehicleLimit: old.vehicleLimit,
        currentVehicles: old.currentVehicles,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  void changePlan(String id, String planName, int vehicleLimit) {
    final index = _companies.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _companies[index];
      _companies[index] = Company(
        id: old.id,
        name: old.name,
        email: old.email,
        cnpj: old.cnpj,
        phone: old.phone,
        plan: _getPlanEnum(planName),
        status: old.status,
        vehicleLimit: vehicleLimit,
        currentVehicles: old.currentVehicles,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  CompanyPlan _getPlanEnum(String planName) {
    if (planName.toLowerCase().contains('pro')) return CompanyPlan.pro;
    if (planName.toLowerCase().contains('enterprise')) return CompanyPlan.enterprise;
    return CompanyPlan.basic;
  }
}
