import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/company.dart';
import '../../mock/mock_companies.dart';
import '../core/super_admin_manager.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final List<Company> _allCompanies = MockCompanies.getCompanies();
  String _searchQuery = '';
  CompanyStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final filteredCompanies = _allCompanies.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.cnpj.contains(_searchQuery);
      final matchesStatus = _statusFilter == null || c.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

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
                    'Gestão de Empresas',
                    style: GoogleFonts.manrope(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visualize e gerencie todos os tenants do sistema.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_business_outlined, size: 20),
                label: const Text('Cadastrar Empresa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Filters
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.inter(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou CNPJ...',
                      hintStyle: GoogleFonts.inter(color: Colors.white24),
                      prefixIcon: const Icon(Icons.search, color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _FilterChip(
                  label: 'Todas',
                  isSelected: _statusFilter == null,
                  onTap: () => setState(() => _statusFilter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Ativas',
                  isSelected: _statusFilter == CompanyStatus.active,
                  onTap: () =>
                      setState(() => _statusFilter = CompanyStatus.active),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Inativas',
                  isSelected: _statusFilter == CompanyStatus.inactive,
                  onTap: () =>
                      setState(() => _statusFilter = CompanyStatus.inactive),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Bloqueadas',
                  isSelected: _statusFilter == CompanyStatus.blocked,
                  onTap: () =>
                      setState(() => _statusFilter = CompanyStatus.blocked),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('EMPRESA',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1))),
                Expanded(
                    flex: 2,
                    child: Text('CNPJ',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1))),
                Expanded(
                    flex: 1,
                    child: Text('PLANO',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1))),
                Expanded(
                    flex: 1,
                    child: Text('STATUS',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1))),
                Expanded(
                    flex: 1,
                    child: Text('VEÍCULOS',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 1))),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: ListView.separated(
                itemCount: filteredCompanies.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white.withValues(alpha: 0.02), height: 1),
                itemBuilder: (context, index) {
                  final company = filteredCompanies[index];
                  return _CompanyRow(company: company);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.transparent,
      selectedColor: AppColors.accent,
      checkmarkColor: Colors.black,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? Colors.black : Colors.white70,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: isSelected ? AppColors.accent : Colors.white.withValues(alpha: 0.08)),
      ),
    );
  }
}

class _CompanyRow extends StatelessWidget {
  final Company company;

  const _CompanyRow({required this.company});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SuperAdminManager.impersonate(company.id, company.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Acessando como ${company.name}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    company.email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                company.cnpj,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                company.planName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _StatusBadge(status: company.status),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${company.currentVehicles} / ${company.vehicleLimit}',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white24),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CompanyStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case CompanyStatus.active:
        color = Colors.greenAccent;
        label = 'Ativa';
        break;
      case CompanyStatus.inactive:
        color = Colors.white54;
        label = 'Inativa';
        break;
      case CompanyStatus.blocked:
        color = Colors.redAccent;
        label = 'Bloqueada';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
