import 'package:flutter/material.dart';

class TenantManager extends ChangeNotifier {
  static final TenantManager _instance = TenantManager._internal();
  factory TenantManager() => _instance;
  TenantManager._internal();

  String _currentCompanyId = 'default_company';
  String? _companyName;

  String get currentCompanyId => _currentCompanyId;
  String? get companyName => _companyName;

  bool get isSuperAdminMode => _currentCompanyId == 'super_admin';

  void setTenant(String companyId, {String? name}) {
    _currentCompanyId = companyId;
    _companyName = name;
    notifyListeners();
    debugPrint('Tenant changed to: $companyId ($name)');
  }

  void resetToDefault() {
    _currentCompanyId = 'default_company';
    _companyName = null;
    notifyListeners();
  }
  
  // Method to filter lists based on current tenant
  List<T> filterByTenant<T>(List<T> items, String Function(T) getCompanyId) {
    if (isSuperAdminMode) return items;
    return items.where((item) => getCompanyId(item) == _currentCompanyId).toList();
  }
}
