import 'package:flutter/material.dart';
import '../../core/saas/tenant_manager.dart';
import 'audit_manager.dart';
import '../models/audit_entry.dart';

class SuperAdminManager {
  static final ValueNotifier<String?> impersonatedCompanyId = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> impersonatedCompanyName = ValueNotifier<String?>(null);

  static void impersonate(String id, String name) {
    impersonatedCompanyId.value = id;
    impersonatedCompanyName.value = name;
    TenantManager().setTenant(id, name: name);
    
    AuditManager().logAction(
      action: AuditAction.impersonationStart,
      target: name,
      details: 'Acesso simultâneo como administrador da empresa iniciada.',
    );
  }

  static void stopImpersonation() {
    final name = impersonatedCompanyName.value ?? 'Desconhecido';
    impersonatedCompanyId.value = null;
    impersonatedCompanyName.value = null;
    TenantManager().resetToDefault();

    AuditManager().logAction(
      action: AuditAction.impersonationEnd,
      target: name,
      details: 'Sessão de sombra encerrada.',
    );
  }

  static bool get isImpersonating => impersonatedCompanyId.value != null;
}
