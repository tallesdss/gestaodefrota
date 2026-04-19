import 'package:flutter/material.dart';

class SuperAdminManager {
  static final ValueNotifier<String?> impersonatedCompanyId = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> impersonatedCompanyName = ValueNotifier<String?>(null);

  static void impersonate(String id, String name) {
    impersonatedCompanyId.value = id;
    impersonatedCompanyName.value = name;
  }

  static void stopImpersonation() {
    impersonatedCompanyId.value = null;
    impersonatedCompanyName.value = null;
  }

  static bool get isImpersonating => impersonatedCompanyId.value != null;
}
