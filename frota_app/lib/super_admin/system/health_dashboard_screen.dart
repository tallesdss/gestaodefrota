import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/system_manager.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final _systemManager = SystemManager();

  @override
  void initState() {
    super.initState();
    _systemManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _systemManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Saúde do Sistema',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitoramento em tempo real da infraestrutura SaaS.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _systemManager.refreshHealth(),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Forçar Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white10),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Main Stats
          Row(
            children: [
              _StatCard(
                label: 'Carga de CPU',
                value: '${_systemManager.cpuUsage.toStringAsFixed(1)}%',
                icon: Icons.speed,
                color: _systemManager.cpuUsage > 80 ? Colors.redAccent : Colors.greenAccent,
                progress: _systemManager.cpuUsage / 100,
              ),
              const SizedBox(width: 24),
              _StatCard(
                label: 'Uso de Memória',
                value: '${_systemManager.memoryUsage.toStringAsFixed(1)}%',
                icon: Icons.memory,
                color: Colors.blueAccent,
                progress: _systemManager.memoryUsage / 100,
              ),
              const SizedBox(width: 24),
              _StatCard(
                label: 'Logs de Erro (24h)',
                value: '${_systemManager.errorCount24h}',
                icon: Icons.bug_report_outlined,
                color: _systemManager.errorCount24h > 10 ? Colors.orangeAccent : Colors.white24,
                isWarning: _systemManager.errorCount24h > 0,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Server Status Table
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status dos Microsserviços',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildServiceRow('API Gateway', 'Operacional', true),
                  _buildServiceRow('Auth Service', 'Operacional', true),
                  _buildServiceRow('Billing Engine', 'Mantenção', false, isPending: true),
                  _buildServiceRow('Fleet Core', 'Operacional', true),
                  _buildServiceRow('Notification Hub', 'Operacional', true),
                  _buildServiceRow('Storage CDN', 'Degradado', false, isWarning: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String name, String status, bool isOk, {bool isWarning = false, bool isPending = false}) {
    Color statusColor = isOk ? Colors.greenAccent : (isWarning ? Colors.orangeAccent : (isPending ? Colors.blueAccent : Colors.redAccent));
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: statusColor.withAlpha(100), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            'Latência: ${isOk ? "45ms" : "--"}',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? progress;
  final bool isWarning;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.progress,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWarning ? Colors.orangeAccent.withAlpha(30) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (isWarning)
                  const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withAlpha(10),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
