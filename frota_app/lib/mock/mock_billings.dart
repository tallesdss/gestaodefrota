import '../models/billing_invoice.dart';

class MockBillings {
  static List<BillingInvoice> getInvoices() {
    return [
      BillingInvoice(
        id: 'INV-001',
        companyId: '1',
        companyName: 'Transportes TransLog Ltda',
        amount: 2500.00,
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        paidAt: DateTime.now().subtract(const Duration(days: 4)),
        status: InvoiceStatus.paid,
        planName: 'Enterprise',
      ),
      BillingInvoice(
        id: 'INV-002',
        companyId: '2',
        companyName: 'Frota Rápida Delivery',
        amount: 850.00,
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: InvoiceStatus.pending,
        planName: 'Pro',
      ),
      BillingInvoice(
        id: 'INV-003',
        companyId: '3',
        companyName: 'Express Encomendas',
        amount: 450.00,
        dueDate: DateTime.now().subtract(const Duration(days: 12)),
        status: InvoiceStatus.overdue,
        planName: 'Basic',
      ),
      BillingInvoice(
        id: 'INV-004',
        companyId: '4',
        companyName: 'Logística Total',
        amount: 5200.00,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        status: InvoiceStatus.pending,
        planName: 'Enterprise Plus',
      ),
      BillingInvoice(
        id: 'INV-005',
        companyId: '1',
        companyName: 'Transportes TransLog Ltda',
        amount: 2500.00,
        dueDate: DateTime.now().add(const Duration(days: 25)),
        status: InvoiceStatus.pending,
        planName: 'Enterprise',
      ),
    ];
  }
}
