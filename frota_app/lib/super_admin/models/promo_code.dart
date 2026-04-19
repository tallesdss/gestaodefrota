enum PromoType { percentage, fixed }

class PromoCode {
  final String id;
  final String code;
  final PromoType type;
  final double value;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.expiryDate,
    this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
  });

  String get discountLabel => type == PromoType.percentage ? '${value.toInt()}%' : 'R\$ ${value.toStringAsFixed(2)}';
}
