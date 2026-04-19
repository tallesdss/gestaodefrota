import 'package:flutter/material.dart';

class SystemBroadcast {
  final String id;
  final String title;
  final String message;
  final DateTime sentAt;
  final String category;

  SystemBroadcast({
    required this.id,
    required this.title,
    required this.message,
    required this.sentAt,
    this.category = 'Geral',
  });
}

class SystemManager extends ChangeNotifier {
  static final SystemManager _instance = SystemManager._internal();
  factory SystemManager() => _instance;
  SystemManager._internal();

  final List<SystemBroadcast> _broadcasts = [
    SystemBroadcast(
      id: '1',
      title: 'Manutenção Programada',
      message: 'O sistema ficará instável no domingo das 02:00 às 04:00.',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Infraestrutura',
    ),
  ];

  List<SystemBroadcast> get broadcasts => List.unmodifiable(_broadcasts);

  void sendBroadcast(String title, String message, String category) {
    _broadcasts.insert(0, SystemBroadcast(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      sentAt: DateTime.now(),
      category: category,
    ));
    notifyListeners();
  }

  // System Health Mock
  double cpuUsage = 15.0;
  double memoryUsage = 42.0;
  int activeClients = 124;
  int errorCount24h = 3;

  void refreshHealth() {
    // In a real app, this would call an API
    notifyListeners();
  }
}
