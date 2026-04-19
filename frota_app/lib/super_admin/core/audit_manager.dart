import 'package:flutter/material.dart';
import '../models/audit_entry.dart';

class AuditManager extends ChangeNotifier {
  static final AuditManager _instance = AuditManager._internal();
  factory AuditManager() => _instance;
  AuditManager._internal();

  final List<AuditEntry> _logs = [
    AuditEntry(
      id: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      adminName: 'Admin Master',
      action: AuditAction.impersonationStart,
      target: 'Transportes TransLog',
      details: 'Sessão iniciada como cliente.',
    ),
    AuditEntry(
      id: '2',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      adminName: 'Admin Master',
      action: AuditAction.paymentConfirmed,
      target: 'Logística Express',
      details: 'Fatura de R\$ 850,00 confirmada manualmente.',
    ),
    AuditEntry(
      id: '3',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      adminName: 'Admin Master',
      action: AuditAction.planUpdated,
      target: 'Plano Pro',
      details: 'Aumento de limite de veículos de 40 para 50.',
    ),
  ];

  List<AuditEntry> get logs => List.unmodifiable(_logs.reversed);

  void logAction({
    required AuditAction action,
    required String target,
    required String details,
    String adminName = 'Admin Master',
  }) {
    _logs.add(AuditEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      adminName: adminName,
      action: action,
      target: target,
      details: details,
    ));
    notifyListeners();
  }
}
