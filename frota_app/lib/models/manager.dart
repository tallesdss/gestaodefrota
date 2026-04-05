enum ManagerStatus { active, inactive }

class Manager {
  final String id;
  final String name;
  final String? cpf;
  final String phone;
  final String email;
  final ManagerStatus status;
  final String avatarUrl;
  final bool isApproved;

  Manager({
    required this.id,
    required this.name,
    this.cpf,
    required this.phone,
    required this.email,
    required this.status,
    required this.avatarUrl,
    this.isApproved = true,
  });

  factory Manager.fromMap(Map<String, dynamic> map) {
    return Manager(
      id: map['id'],
      name: map['name'],
      cpf: map['cpf'],
      phone: map['phone'],
      email: map['email'],
      status: ManagerStatus.values.firstWhere((e) => e.name == map['status']),
      avatarUrl: map['avatarUrl'],
      isApproved: map['isApproved'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'email': email,
      'status': status.name,
      'avatarUrl': avatarUrl,
      'isApproved': isApproved,
    };
  }
}
