import 'package:flutter/material.dart';

enum AuditAction {
  impersonationStart,
  impersonationEnd,
  companyBlocked,
  companySuspended,
  planCreated,
  planUpdated,
  paymentConfirmed,
  userDeleted,
}

class AuditEntry {
  final String id;
  final DateTime timestamp;
  final String adminName;
  final AuditAction action;
  final String target; // e.g., company name, plan name
  final String details;

  AuditEntry({
    required this.id,
    required this.timestamp,
    required this.adminName,
    required this.action,
    required this.target,
    required this.details,
  });

  String get actionLabel {
    switch (action) {
      case AuditAction.impersonationStart: return 'Início de Impersonação';
      case AuditAction.impersonationEnd: return 'Fim de Impersonação';
      case AuditAction.companyBlocked: return 'Empresa Bloqueada';
      case AuditAction.companySuspended: return 'Empresa Suspensa';
      case AuditAction.planCreated: return 'Plano Criado';
      case AuditAction.planUpdated: return 'Plano Atualizado';
      case AuditAction.paymentConfirmed: return 'Pagamento Confirmado';
      case AuditAction.userDeleted: return 'Usuário Removido';
    }
  }

  IconData get icon {
    switch (action) {
      case AuditAction.impersonationStart: return Icons.remove_red_eye_outlined;
      case AuditAction.impersonationEnd: return Icons.logout;
      case AuditAction.companyBlocked: return Icons.block;
      case AuditAction.companySuspended: return Icons.pause_circle_outline;
      case AuditAction.planCreated: return Icons.add_box_outlined;
      case AuditAction.planUpdated: return Icons.edit_note;
      case AuditAction.paymentConfirmed: return Icons.payments_outlined;
      case AuditAction.userDeleted: return Icons.person_remove_outlined;
    }
  }

  Color get color {
    switch (action) {
      case AuditAction.companyBlocked:
      case AuditAction.userDeleted: return Colors.redAccent;
      case AuditAction.paymentConfirmed:
      case AuditAction.impersonationEnd: return Colors.greenAccent;
      case AuditAction.impersonationStart: return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }
}
