import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/routes/app_routes.dart';
import '../../models/manager.dart';

class UserSearchPromotionScreen extends StatefulWidget {
  const UserSearchPromotionScreen({super.key});

  @override
  State<UserSearchPromotionScreen> createState() => _UserSearchPromotionScreenState();
}

class _UserSearchPromotionScreenState extends State<UserSearchPromotionScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Dados mockup de usuários que NÃO são gestores ainda
  final List<Map<String, String>> _mockUsers = [
    {
      'name': 'Carlos Oliveira', 
      'email': 'carlos.o@email.com', 
      'avatar': 'https://i.pravatar.cc/150?u=carlos',
      'cpf': '123.456.789-01',
      'phone': '(11) 98765-4321'
    },
    {
      'name': 'Ana Paula', 
      'email': 'ana.paula@email.com', 
      'avatar': 'https://i.pravatar.cc/150?u=ana',
      'cpf': '234.567.890-12',
      'phone': '(11) 97654-3210'
    },
    {
      'name': 'Marcos Silva', 
      'email': 'marcos.s@email.com', 
      'avatar': 'https://i.pravatar.cc/150?u=marcos',
      'cpf': '345.678.901-23',
      'phone': '(11) 96543-2109'
    },
    {
      'name': 'Fernanda Lima', 
      'email': 'fernanda.l@email.com', 
      'avatar': 'https://i.pravatar.cc/150?u=fernanda',
      'cpf': '456.789.012-34',
      'phone': '(11) 95432-1098'
    },
    {
      'name': 'Roberto Santos', 
      'email': 'roberto.s@email.com', 
      'avatar': 'https://i.pravatar.cc/150?u=roberto',
      'cpf': '567.890.123-45',
      'phone': '(11) 94321-0987'
    },
  ];

  late List<Map<String, String>> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _mockUsers;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _mockUsers
          .where((u) => u['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                        u['email']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'PROMOVER USUÁRIO',
          style: AppTextStyles.labelLarge.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUSCAR NO SISTEMA',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nome ou e-mail do usuário...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 64, color: AppColors.outlineVariant),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Nenhum usuário encontrado.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return GestureDetector(
                        onTap: () {
                          // Criar um objeto Manager temporário para enviar ao formulário
                          final manager = Manager(
                            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                            name: user['name']!,
                            email: user['email']!,
                            phone: user['phone']!,
                            cpf: user['cpf']!,
                            avatarUrl: user['avatar']!,
                            status: ManagerStatus.active,
                            isApproved: true,
                          );
                          // Navega para o formulário com os dados pré-preenchidos
                          context.push(AppRoutes.adminManagerForm, extra: manager);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.surfaceContainerLow),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(user['avatar']!),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['name']!, 
                                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)
                                    ),
                                    Text(
                                      user['email']!, 
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'PROMOVER',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
