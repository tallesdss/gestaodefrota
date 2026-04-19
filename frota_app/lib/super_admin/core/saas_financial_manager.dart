import 'package:flutter/material.dart';
import '../models/saas_plan.dart';
import '../../models/billing_invoice.dart';
import '../../mock/mock_billings.dart';
import '../models/promo_code.dart';

class SaaSFinancialManager extends ChangeNotifier {
  static final SaaSFinancialManager _instance = SaaSFinancialManager._internal();
  factory SaaSFinancialManager() => _instance;
  SaaSFinancialManager._internal() {
    _invoices = MockBillings.getInvoices();
  }

  // --- Plans ---
  final List<SaaSPlan> _plans = [
    SaaSPlan(
      id: '1',
      name: 'Basic',
      price: 450,
      maxVehicles: 10,
      maxUsers: 3,
      color: Colors.blueAccent,
      features: ['Gestão de Veículos', 'Relatórios Básicos', 'Suporte por Email'],
    ),
    SaaSPlan(
      id: '2',
      name: 'Pro',
      price: 850,
      maxVehicles: 50,
      maxUsers: 15,
      isPopular: true,
      color: const Color(0xFFD4FF00), // AppColors.accent equivalent
      features: ['Tudo do Basic', 'Manutenção Avançada', 'Suporte Prioritário', 'APP Motorista'],
    ),
    SaaSPlan(
      id: '3',
      name: 'Enterprise',
      price: 2500,
      maxVehicles: 999,
      maxUsers: 999,
      color: Colors.purpleAccent,
      features: ['Tudo do Pro', 'Customização White-Label', 'API Access', 'Consultoria'],
    ),
  ];

  List<SaaSPlan> get plans => List.unmodifiable(_plans);

  void addPlan(SaaSPlan plan) {
    _plans.add(plan);
    notifyListeners();
  }

  void updatePlan(SaaSPlan plan) {
    final index = _plans.indexWhere((p) => p.id == plan.id);
    if (index != -1) {
      _plans[index] = plan;
      notifyListeners();
    }
  }

  void removePlan(String id) {
    _plans.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // --- Billing ---
  late List<BillingInvoice> _invoices;

  List<BillingInvoice> get invoices => List.unmodifiable(_invoices);

  void confirmPayment(String invoiceId) {
    final index = _invoices.indexWhere((i) => i.id == invoiceId);
    if (index != -1) {
      final old = _invoices[index];
      _invoices[index] = BillingInvoice(
        id: old.id,
        companyId: old.companyId,
        companyName: old.companyName,
        amount: old.amount,
        dueDate: old.dueDate,
        planName: old.planName,
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  double get totalMRR => _invoices
      .where((i) => i.status != InvoiceStatus.cancelled)
      .fold(0, (sum, item) => sum + item.amount);

  double get overdueAmount => _invoices
      .where((i) => i.status == InvoiceStatus.overdue)
      .fold(0, (sum, item) => sum + item.amount);

  // --- Promo Codes ---
  final List<PromoCode> _promoCodes = [
    PromoCode(
      id: '1',
      code: 'WELCOME50',
      type: PromoType.percentage,
      value: 50,
      usageLimit: 100,
      usageCount: 45,
    ),
    PromoCode(
      id: '2',
      code: 'BLACKFRIDAY',
      type: PromoType.fixed,
      value: 200,
      expiryDate: DateTime(2026, 11, 30),
    ),
  ];

  List<PromoCode> get promoCodes => List.unmodifiable(_promoCodes);

  void addPromoCode(PromoCode promo) {
    _promoCodes.add(promo);
    notifyListeners();
  }

  void togglePromoStatus(String id) {
    final index = _promoCodes.indexWhere((p) => p.id == id);
    if (index != -1) {
      final old = _promoCodes[index];
      _promoCodes[index] = PromoCode(
        id: old.id,
        code: old.code,
        type: old.type,
        value: old.value,
        expiryDate: old.expiryDate,
        usageLimit: old.usageLimit,
        usageCount: old.usageCount,
        isActive: !old.isActive,
      );
      notifyListeners();
    }
  }

  void removePromoCode(String id) {
    _promoCodes.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
