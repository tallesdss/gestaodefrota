import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/system_manager.dart';
import '../core/audit_manager.dart';
import '../models/audit_entry.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _systemManager = SystemManager();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Geral';

  @override
  void initState() {
    super.initState();
    _systemManager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _systemManager.removeListener(_onStateChanged);
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _send() {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) return;

    _systemManager.sendBroadcast(
      _titleController.text,
      _messageController.text,
      _selectedCategory,
    );

    AuditManager().logAction(
      action: AuditAction.broadcastSent,
      target: 'Sistema Global',
      details: 'Broadcast enviado: ${_titleController.text}',
    );

    _titleController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Broadcast enviado com sucesso para todos os administradores!'),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Composer
          Expanded(
            flex: 2,
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
                    'Nova Notificação Global',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Este aviso será exibido no dashboard de todas as empresas cadastradas.',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _titleController,
                    label: 'Título do Aviso',
                    hint: 'Ex: Atualização de Termos de Uso',
                  ),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    label: 'Categoria',
                    value: _selectedCategory,
                    items: const ['Geral', 'Financeiro', 'Manutenção', 'Infraestrutura', 'Urgente'],
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _messageController,
                    label: 'Mensagem Completa',
                    hint: 'Descreva os detalhes do comunicado...',
                    maxLines: 6,
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: const Text('Disparar Broadcast'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),
          // Right: History
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Histórico de Envios',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.separated(
                    itemCount: _systemManager.broadcasts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final b = _systemManager.broadcasts[index];
                      return _BroadcastItem(broadcast: b);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((i) => DropdownMenuItem(
                value: i,
                child: Text(i, style: const TextStyle(color: Colors.white)),
              )).toList(),
              onChanged: onChanged,
              dropdownColor: const Color(0xFF0F172A),
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _BroadcastItem extends StatelessWidget {
  final SystemBroadcast broadcast;

  const _BroadcastItem({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: broadcast.category == 'Urgente' ? Colors.redAccent.withAlpha(20) : Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  broadcast.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: broadcast.category == 'Urgente' ? Colors.redAccent : Colors.white54,
                  ),
                ),
              ),
              Text(
                DateFormat('dd MMM, HH:mm').format(broadcast.sentAt),
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            broadcast.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            broadcast.message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
