import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

// ── Data Model (Mutable) ────────────────────────────────────────────────────

class ExpenseSubcategory {
  String name;
  ExpenseSubcategory({required this.name});
}

class ExpenseSubgroup {
  String name;
  List<ExpenseSubcategory> items;
  ExpenseSubgroup({required this.name, required this.items});
}

class ExpenseCategory {
  String name;
  final IconData icon;
  final Color color;
  List<ExpenseSubgroup> subgroups;

  ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.subgroups,
  });
}

// ── Initial Data ─────────────────────────────────────────────────────────────

List<ExpenseCategory> _buildInitialCategories() => [
  ExpenseCategory(
    name: 'Manutenção',
    icon: Icons.build_outlined,
    color: AppColors.error,
    subgroups: [
      ExpenseSubgroup(
        name: 'Motor',
        items: [
          ExpenseSubcategory(name: 'Troca de óleo e filtro de óleo'),
          ExpenseSubcategory(name: 'Troca de correia dentada'),
          ExpenseSubcategory(name: 'Troca de correia do alternador'),
          ExpenseSubcategory(name: 'Troca de bomba d\'água'),
          ExpenseSubcategory(name: 'Troca de bomba de combustível'),
          ExpenseSubcategory(name: 'Troca de velas de ignição'),
          ExpenseSubcategory(name: 'Troca de bobina de ignição'),
          ExpenseSubcategory(name: 'Limpeza de injetores'),
          ExpenseSubcategory(name: 'Troca de filtro de combustível'),
          ExpenseSubcategory(name: 'Troca de filtro de ar'),
          ExpenseSubcategory(name: 'Troca de junta do cabeçote'),
          ExpenseSubcategory(name: 'Regulagem de válvulas'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Suspensão',
        items: [
          ExpenseSubcategory(name: 'Troca de amortecedores'),
          ExpenseSubcategory(name: 'Troca de molas'),
          ExpenseSubcategory(name: 'Troca de pivôs'),
          ExpenseSubcategory(name: 'Troca de bandejas e buchas'),
          ExpenseSubcategory(name: 'Troca de barra estabilizadora'),
          ExpenseSubcategory(name: 'Troca de rolamento de roda'),
          ExpenseSubcategory(name: 'Alinhamento e balanceamento'),
          ExpenseSubcategory(name: 'Troca de terminal de direção'),
          ExpenseSubcategory(name: 'Troca de caixa de direção'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Freios',
        items: [
          ExpenseSubcategory(name: 'Troca de pastilhas de freio'),
          ExpenseSubcategory(name: 'Troca de discos de freio'),
          ExpenseSubcategory(name: 'Troca de lonas e tambores'),
          ExpenseSubcategory(name: 'Troca de fluido de freio'),
          ExpenseSubcategory(name: 'Troca de cilindro mestre'),
          ExpenseSubcategory(name: 'Troca de mangueiras de freio'),
          ExpenseSubcategory(name: 'Regulagem do freio de mão'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Transmissão',
        items: [
          ExpenseSubcategory(name: 'Troca de óleo do câmbio'),
          ExpenseSubcategory(
            name: 'Troca de embreagem (disco, plato e rolamento)',
          ),
          ExpenseSubcategory(name: 'Troca de cabo de embreagem'),
          ExpenseSubcategory(name: 'Troca de junta homocinética'),
          ExpenseSubcategory(name: 'Troca de semi-eixo'),
          ExpenseSubcategory(name: 'Troca de óleo do diferencial'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Arrefecimento',
        items: [
          ExpenseSubcategory(name: 'Troca de fluido de arrefecimento'),
          ExpenseSubcategory(name: 'Troca de radiador'),
          ExpenseSubcategory(name: 'Troca de mangueiras do radiador'),
          ExpenseSubcategory(name: 'Troca de termostato'),
          ExpenseSubcategory(name: 'Troca de ventoinha'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Elétrica',
        items: [
          ExpenseSubcategory(name: 'Troca de bateria'),
          ExpenseSubcategory(name: 'Troca de alternador'),
          ExpenseSubcategory(name: 'Troca de motor de arranque'),
          ExpenseSubcategory(name: 'Troca de fusíveis e relés'),
          ExpenseSubcategory(
            name: 'Troca de lâmpadas (faróis, lanternas, setas)',
          ),
          ExpenseSubcategory(
            name: 'Troca de sensores (rotação, temperatura, ABS)',
          ),
          ExpenseSubcategory(name: 'Reparo de chicote elétrico'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Pneus',
        items: [
          ExpenseSubcategory(name: 'Troca de pneus'),
          ExpenseSubcategory(name: 'Rodízio de pneus'),
          ExpenseSubcategory(name: 'Troca de estepe'),
          ExpenseSubcategory(name: 'Calibragem de pressão'),
          ExpenseSubcategory(name: 'Troca de válvulas'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Ar-condicionado',
        items: [
          ExpenseSubcategory(name: 'Recarga de gás'),
          ExpenseSubcategory(name: 'Troca de filtro de cabine'),
          ExpenseSubcategory(name: 'Troca de compressor'),
          ExpenseSubcategory(name: 'Troca de condensador'),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Abastecimento',
    icon: Icons.local_gas_station_outlined,
    color: AppColors.primary,
    subgroups: [
      ExpenseSubgroup(
        name: 'Combustível',
        items: [
          ExpenseSubcategory(name: 'Abastecimento de gasolina'),
          ExpenseSubcategory(name: 'Abastecimento de etanol'),
          ExpenseSubcategory(name: 'Abastecimento de diesel'),
          ExpenseSubcategory(name: 'Abastecimento de GNV'),
          ExpenseSubcategory(name: 'Recarga elétrica'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Lubrificantes e fluidos',
        items: [
          ExpenseSubcategory(name: 'Completar óleo do motor'),
          ExpenseSubcategory(name: 'Completar fluido de freio'),
          ExpenseSubcategory(name: 'Completar fluido de direção hidráulica'),
          ExpenseSubcategory(name: 'Completar aditivo do radiador'),
          ExpenseSubcategory(
            name: 'Completar fluido de limpador de para-brisa',
          ),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Limpeza e Estética',
    icon: Icons.auto_awesome_outlined,
    color: Colors.blue,
    subgroups: [
      ExpenseSubgroup(
        name: 'Limpeza',
        items: [
          ExpenseSubcategory(name: 'Lavagem externa'),
          ExpenseSubcategory(name: 'Lavagem interna'),
          ExpenseSubcategory(name: 'Limpeza de estofados'),
          ExpenseSubcategory(name: 'Higienização de ar-condicionado'),
          ExpenseSubcategory(name: 'Limpeza de motor'),
          ExpenseSubcategory(name: 'Polimento de faróis'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Funilaria',
        items: [
          ExpenseSubcategory(name: 'Reparo de amassados'),
          ExpenseSubcategory(name: 'Troca de para-choque dianteiro'),
          ExpenseSubcategory(name: 'Troca de para-choque traseiro'),
          ExpenseSubcategory(name: 'Troca de capô'),
          ExpenseSubcategory(name: 'Troca de porta'),
          ExpenseSubcategory(name: 'Troca de paralama'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Pintura',
        items: [
          ExpenseSubcategory(name: 'Pintura total'),
          ExpenseSubcategory(name: 'Pintura parcial'),
          ExpenseSubcategory(name: 'Polimento'),
          ExpenseSubcategory(name: 'Vitrificação de pintura'),
          ExpenseSubcategory(name: 'Envelopamento'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Vidros',
        items: [
          ExpenseSubcategory(name: 'Troca de para-brisa'),
          ExpenseSubcategory(name: 'Troca de vidro lateral'),
          ExpenseSubcategory(name: 'Troca de vidro traseiro'),
          ExpenseSubcategory(name: 'Reparo de trinca'),
          ExpenseSubcategory(name: 'Troca de borracha de vedação'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Acessórios',
        items: [
          ExpenseSubcategory(name: 'Troca de retrovisores'),
          ExpenseSubcategory(name: 'Troca de maçanetas'),
          ExpenseSubcategory(name: 'Instalação de engate reboque'),
          ExpenseSubcategory(name: 'Troca de tapetes e frisos'),
        ],
      ),
    ],
  ),
  ExpenseCategory(
    name: 'Documentos e IPVA',
    icon: Icons.description_outlined,
    color: const Color(0xFF607D8B),
    subgroups: [
      ExpenseSubgroup(
        name: 'Impostos e taxas',
        items: [
          ExpenseSubcategory(name: 'Pagamento de IPVA'),
          ExpenseSubcategory(name: 'Pagamento de DPVAT / DPEG'),
          ExpenseSubcategory(name: 'Licenciamento anual (CRLV)'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Seguro',
        items: [
          ExpenseSubcategory(name: 'Renovação de seguro compreensivo'),
          ExpenseSubcategory(name: 'Acionamento de seguro'),
          ExpenseSubcategory(name: 'Vistoria de seguro'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Infrações',
        items: [
          ExpenseSubcategory(name: 'Registro de multa'),
          ExpenseSubcategory(name: 'Recurso de multa'),
          ExpenseSubcategory(name: 'Indicação de condutor'),
          ExpenseSubcategory(name: 'Pagamento de multa'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Sinistros',
        items: [
          ExpenseSubcategory(name: 'Registro de boletim de ocorrência'),
          ExpenseSubcategory(name: 'Orçamento de reparo pós-sinistro'),
          ExpenseSubcategory(name: 'Acompanhamento de reparo'),
          ExpenseSubcategory(name: 'Baixa do veículo (furto/perda total)'),
        ],
      ),
      ExpenseSubgroup(
        name: 'Vistoria e transferência',
        items: [
          ExpenseSubcategory(name: 'Vistoria cautelar'),
          ExpenseSubcategory(name: 'Transferência de propriedade'),
          ExpenseSubcategory(name: 'Emplacamento de veículo novo'),
        ],
      ),
    ],
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  late List<ExpenseCategory> _categories;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _expandedCategories = {};
  final Set<String> _expandedSubgroups = {};

  @override
  void initState() {
    super.initState();
    _categories = _buildInitialCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _countTotalItems(ExpenseCategory cat) {
    return cat.subgroups.fold(0, (sum, sg) => sum + sg.items.length);
  }

  int get _totalSubgroups =>
      _categories.fold(0, (s, c) => s + c.subgroups.length);
  int get _totalItems => _categories.fold(0, (s, c) => s + _countTotalItems(c));

  List<ExpenseSubgroup> _filteredSubgroups(ExpenseCategory cat) {
    if (_searchQuery.isEmpty) return cat.subgroups;
    final query = _searchQuery.toLowerCase();
    return cat.subgroups
        .map((sg) {
          final filteredItems = sg.items
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();
          if (filteredItems.isNotEmpty ||
              sg.name.toLowerCase().contains(query)) {
            return ExpenseSubgroup(
              name: sg.name,
              items: filteredItems.isNotEmpty ? filteredItems : sg.items,
            );
          }
          return null;
        })
        .whereType<ExpenseSubgroup>()
        .toList();
  }

  bool _categoryMatchesSearch(ExpenseCategory cat) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    if (cat.name.toLowerCase().contains(query)) return true;
    return cat.subgroups.any((sg) {
      if (sg.name.toLowerCase().contains(query)) return true;
      return sg.items.any((item) => item.name.toLowerCase().contains(query));
    });
  }

  // ── CRUD Dialogs ──────────────────────────────────────────────────────────

  Future<String?> _showTextDialog({
    required String title,
    required String hint,
    String initialValue = '',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary.withAlpha(102),
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.pop(ctx, text);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Salvar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog(String itemName) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Remover Item',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            content: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Tem certeza que deseja remover '),
                  TextSpan(
                    text: '"$itemName"',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const TextSpan(text: '? Esta ação não pode ser desfeita.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Remover',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Subgroup CRUD ─────────────────────────────────────────────────────────

  void _addSubgroup(int catIndex) async {
    final name = await _showTextDialog(
      title: 'Novo Subgrupo',
      hint: 'Ex: Motor, Freios, Pintura...',
    );
    if (name != null) {
      setState(() {
        _categories[catIndex].subgroups.add(
          ExpenseSubgroup(name: name, items: []),
        );
        _expandedCategories.add(catIndex);
      });
      _showSnack('Subgrupo "$name" adicionado');
    }
  }

  void _editSubgroup(int catIndex, int subIndex) async {
    final currentName = _categories[catIndex].subgroups[subIndex].name;
    final name = await _showTextDialog(
      title: 'Editar Subgrupo',
      hint: 'Nome do subgrupo',
      initialValue: currentName,
    );
    if (name != null && name != currentName) {
      setState(() => _categories[catIndex].subgroups[subIndex].name = name);
      _showSnack('Subgrupo renomeado para "$name"');
    }
  }

  void _deleteSubgroup(int catIndex, int subIndex) async {
    final subName = _categories[catIndex].subgroups[subIndex].name;
    final confirmed = await _showDeleteDialog(subName);
    if (confirmed) {
      setState(() {
        _categories[catIndex].subgroups.removeAt(subIndex);
        _expandedSubgroups.removeWhere((k) => k.startsWith('$catIndex-'));
      });
      _showSnack('Subgrupo "$subName" removido');
    }
  }

  // ── Item CRUD ─────────────────────────────────────────────────────────────

  void _addItem(int catIndex, int subIndex) async {
    final name = await _showTextDialog(
      title: 'Novo Item',
      hint: 'Ex: Troca de óleo, Polimento...',
    );
    if (name != null) {
      setState(() {
        _categories[catIndex].subgroups[subIndex].items.add(
          ExpenseSubcategory(name: name),
        );
        final key = '$catIndex-$subIndex';
        _expandedSubgroups.add(key);
        _expandedCategories.add(catIndex);
      });
      _showSnack('Item "$name" adicionado');
    }
  }

  void _editItem(int catIndex, int subIndex, int itemIndex) async {
    final currentName =
        _categories[catIndex].subgroups[subIndex].items[itemIndex].name;
    final name = await _showTextDialog(
      title: 'Editar Item',
      hint: 'Nome do item',
      initialValue: currentName,
    );
    if (name != null && name != currentName) {
      setState(
        () => _categories[catIndex].subgroups[subIndex].items[itemIndex].name =
            name,
      );
      _showSnack('Item renomeado para "$name"');
    }
  }

  void _deleteItem(int catIndex, int subIndex, int itemIndex) async {
    final itemName =
        _categories[catIndex].subgroups[subIndex].items[itemIndex].name;
    final confirmed = await _showDeleteDialog(itemName);
    if (confirmed) {
      setState(
        () =>
            _categories[catIndex].subgroups[subIndex].items.removeAt(itemIndex),
      );
      _showSnack('Item "$itemName" removido');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _categories
        .where((cat) => _categoryMatchesSearch(cat))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Categorias de Despesas',
          style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary),
        ),
        leading: BackButton(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // ── Search Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar subcategoria...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant.withAlpha(128),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── Stats Bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildStatChip(
                    '${_categories.length}',
                    'Categorias',
                    Icons.folder_outlined,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _buildStatChip(
                    '$_totalSubgroups',
                    'Subgrupos',
                    Icons.folder_open_outlined,
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  _buildStatChip(
                    '$_totalItems',
                    'Itens',
                    Icons.list_alt_rounded,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Category List ──
          Expanded(
            child: filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.onSurfaceVariant.withAlpha(77),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Nenhum resultado para "$_searchQuery"',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCategories[index];
                      final catIndex = _categories.indexOf(cat);
                      return _buildCategoryCard(cat, catIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Stat Chip ──────────────────────────────────────────────────────────────
  Widget _buildStatChip(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withAlpha(180), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withAlpha(153),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Category Card (Level 1) ────────────────────────────────────────────────
  Widget _buildCategoryCard(ExpenseCategory cat, int catIndex) {
    final isExpanded =
        _expandedCategories.contains(catIndex) || _searchQuery.isNotEmpty;
    final subgroups = _filteredSubgroups(cat);
    final totalItems = _countTotalItems(cat);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.ambientShadow,
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedCategories.contains(catIndex)) {
                  _expandedCategories.remove(catIndex);
                } else {
                  _expandedCategories.add(catIndex);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cat.subgroups.length} subgrupos · $totalItems itens',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add subgroup button
                  _buildMiniAction(
                    icon: Icons.add_rounded,
                    color: AppColors.success,
                    tooltip: 'Adicionar subgrupo',
                    onTap: () => _addSubgroup(catIndex),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
              ),
              child: Column(
                children: subgroups.asMap().entries.map((entry) {
                  final realSubIndex = cat.subgroups.indexOf(entry.value);
                  return _buildSubgroupTile(
                    entry.value,
                    catIndex,
                    realSubIndex >= 0 ? realSubIndex : entry.key,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ── Subgroup Tile (Level 2) ────────────────────────────────────────────────
  Widget _buildSubgroupTile(
    ExpenseSubgroup subgroup,
    int catIndex,
    int subIndex,
  ) {
    final key = '$catIndex-$subIndex';
    final isExpanded =
        _expandedSubgroups.contains(key) || _searchQuery.isNotEmpty;
    final cat = _categories[catIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Subgroup Header
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedSubgroups.contains(key)) {
                  _expandedSubgroups.remove(key);
                } else {
                  _expandedSubgroups.add(key);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(153),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subgroup.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  // Item count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${subgroup.items.length}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cat.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Action icons for subgroup
                  _buildMiniAction(
                    icon: Icons.add_rounded,
                    color: AppColors.success,
                    tooltip: 'Adicionar item',
                    onTap: () => _addItem(catIndex, subIndex),
                    size: 18,
                  ),
                  _buildMiniAction(
                    icon: Icons.edit_outlined,
                    color: AppColors.primary,
                    tooltip: 'Editar subgrupo',
                    onTap: () => _editSubgroup(catIndex, subIndex),
                    size: 18,
                  ),
                  _buildMiniAction(
                    icon: Icons.delete_outline_rounded,
                    color: AppColors.error,
                    tooltip: 'Remover subgrupo',
                    onTap: () => _deleteSubgroup(catIndex, subIndex),
                    size: 18,
                  ),
                  const SizedBox(width: 2),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.onSurfaceVariant.withAlpha(128),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items list
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 24, right: 8, bottom: 10),
              child: Column(
                children: subgroup.items.asMap().entries.map((entry) {
                  return _buildItemRow(
                    entry.value,
                    cat.color,
                    catIndex,
                    subIndex,
                    entry.key,
                  );
                }).toList(),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ── Item Row (Level 3) ─────────────────────────────────────────────────────
  Widget _buildItemRow(
    ExpenseSubcategory item,
    Color color,
    int catIndex,
    int subIndex,
    int itemIndex,
  ) {
    final isHighlighted =
        _searchQuery.isNotEmpty &&
        item.name.toLowerCase().contains(_searchQuery.toLowerCase());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isHighlighted ? color : AppColors.outlineVariant,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? color : AppColors.onSurfaceVariant,
              ),
            ),
          ),
          // Edit item
          _buildMiniAction(
            icon: Icons.edit_outlined,
            color: AppColors.primary,
            tooltip: 'Editar',
            onTap: () => _editItem(catIndex, subIndex, itemIndex),
            size: 15,
            padSize: 4,
          ),
          // Delete item
          _buildMiniAction(
            icon: Icons.close_rounded,
            color: AppColors.error,
            tooltip: 'Remover',
            onTap: () => _deleteItem(catIndex, subIndex, itemIndex),
            size: 15,
            padSize: 4,
          ),
        ],
      ),
    );
  }

  // ── Mini Action Button ─────────────────────────────────────────────────────
  Widget _buildMiniAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
    double size = 20,
    double padSize = 6,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(padSize),
          child: Icon(icon, color: color.withAlpha(180), size: size),
        ),
      ),
    );
  }
}
