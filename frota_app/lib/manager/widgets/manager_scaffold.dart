import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../admin/widgets/admin_header.dart';
import 'manager_sidebar.dart';

class ManagerScaffold extends StatelessWidget {
  final Widget child;

  const ManagerScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          ManagerSidebar(activeRoute: location),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(), // Reuse AdminHeader as it contains search and profile
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
