import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/audit_manager.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _auditManager = AuditManager();

  @override
  void initState() {
    super.initState();
    _auditManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _auditManager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFilterRow(),
          const SizedBox(height: 24),
          Expanded(child: _buildLogList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log de Auditoria Master',
          style: GoogleFonts.manrope(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          'Rastro completo de ações administrativas em todo o ecossistema.',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar por empresa, ação ou admin...',
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.search, color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
              const SizedBox(width: 8),
              Text('Últimos 30 dias', style: GoogleFonts.inter(color: Colors.white70)),
              const Icon(Icons.arrow_drop_down, color: Colors.white54),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogList() {
    final logs = _auditManager.logs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (context, index) => const Divider(color: Colors.white10),
        itemBuilder: (context, index) {
          final log = logs[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: log.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(log.icon, color: log.color, size: 20),
            ),
            title: Row(
              children: [
                Text(
                  log.actionLabel,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.white24)),
                const SizedBox(width: 8),
                Text(
                  log.target,
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${log.details} - Por ${log.adminName}',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
              ),
            ),
            trailing: Text(
              DateFormat('HH:mm - dd/MM').format(log.timestamp),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white24),
            ),
          );
        },
      ),
    );
  }
}
