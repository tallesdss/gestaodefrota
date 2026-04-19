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
  companyCreated,
  companyModified,
  broadcastSent,
  promoCodeCreated,
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
      case AuditAction.companyCreated: return 'Empresa Criada';
      case AuditAction.companyModified: return 'Empresa Modificada';
      case AuditAction.broadcastSent: return 'Broadcast Enviado';
      case AuditAction.promoCodeCreated: return 'Cupom Criado';
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
      case AuditAction.companyCreated: return Icons.business;
      case AuditAction.companyModified: return Icons.edit_note;
      case AuditAction.broadcastSent: return Icons.campaign_outlined;
      case AuditAction.promoCodeCreated: return Icons.confirmation_number_outlined;
    }
  }

  Color get color {
    switch (action) {
      case AuditAction.companyBlocked:
      case AuditAction.userDeleted: return Colors.redAccent;
      case AuditAction.broadcastSent: return Colors.orangeAccent;
      case AuditAction.companyCreated: return Colors.greenAccent;
      case AuditAction.promoCodeCreated: return Colors.purpleAccent;
      case AuditAction.paymentConfirmed:
      case AuditAction.impersonationEnd: return Colors.greenAccent;
      case AuditAction.impersonationStart: return Colors.orangeAccent;
      default: return Colors.blueAccent;
    }
  }
}
