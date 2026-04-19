import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/super_admin_manager.dart';

class ImpersonationBanner extends StatelessWidget {
  const ImpersonationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: SuperAdminManager.impersonatedCompanyName,
      builder: (context, companyName, _) {
        if (companyName == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade800,
                Colors.orange.shade600,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.privacy_tip, color: Colors.black, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'MODO DE VISUALIZAÇÃO MASTER: Você está navegando como "$companyName".',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => SuperAdminManager.stopImpersonation(),
                  icon: const Icon(Icons.exit_to_app, color: Colors.black, size: 18),
                  label: const Text(
                    'SAIR E VOLTAR AO MASTER',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
