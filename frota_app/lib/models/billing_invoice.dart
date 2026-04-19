import 'package:flutter/material.dart';

enum InvoiceStatus {
  paid,
  pending,
  overdue,
  cancelled,
}

class BillingInvoice {
  final String id;
  final String companyId;
  final String companyName;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidAt;
  final InvoiceStatus status;
  final String planName;

  BillingInvoice({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.amount,
    required this.dueDate,
    this.paidAt,
    required this.status,
    required this.planName,
  });

  Color get statusColor {
    switch (status) {
      case InvoiceStatus.paid:
        return Colors.greenAccent;
      case InvoiceStatus.pending:
        return Colors.orangeAccent;
      case InvoiceStatus.overdue:
        return Colors.redAccent;
      case InvoiceStatus.cancelled:
        return Colors.white24;
    }
  }

  String get statusLabel {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Pago';
      case InvoiceStatus.pending:
        return 'Pendente';
      case InvoiceStatus.overdue:
        return 'Atrasado';
      case InvoiceStatus.cancelled:
        return 'Cancelado';
    }
  }
}
