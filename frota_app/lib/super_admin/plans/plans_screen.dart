import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

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
                    'Planos e Tarifas',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure os tiers de assinatura e limites de recursos.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Novo Plano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(180, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanCard(
                  name: 'Basic',
                  price: r'R$ 299',
                  description: 'Ideal para frotas pequenas e autônomos.',
                  features: const [
                    'Até 20 veículos',
                    'Acesso Driver App',
                    'Relatórios Básicos',
                    'Suporte por Email',
                  ],
                  color: Colors.white24,
                ),
                const SizedBox(width: 24),
                _PlanCard(
                  name: 'Professional',
                  price: r'R$ 890',
                  description: 'Performance e controle para médias empresas.',
                  features: const [
                    'Até 100 veículos',
                    'Módulo Workshop Full',
                    'Telemetria Básica',
                    'Suporte Prioritário',
                    'Gestão de Documentos',
                  ],
                  color: AppColors.accent,
                  isPopular: true,
                ),
                const SizedBox(width: 24),
                _PlanCard(
                  name: 'Enterprise',
                  price: 'Consulte',
                  description: 'Soluções customizadas para grandes frotas.',
                  features: const [
                    'Veículos Ilimitados',
                    'Whitelabel',
                    'API Dedicada',
                    'Gerente de Conta',
                    'SLA Garantido',
                  ],
                  color: Colors.white24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String description;
  final List<String> features;
  final Color color;
  final bool isPopular;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.color,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isPopular ? color.withAlpha(10) : Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPopular ? color : Colors.white.withAlpha(10),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'MAIS VENDIDO',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            Text(
              name,
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: isPopular ? color : Colors.white,
                  ),
                ),
                if (price != 'Consulte')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/mês',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white38,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white60,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10),
            const SizedBox(height: 32),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: isPopular ? color : Colors.white38),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isPopular ? color : Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Editar Plano',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: isPopular ? color : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
