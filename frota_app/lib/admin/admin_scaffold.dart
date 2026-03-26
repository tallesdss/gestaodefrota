import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_header.dart';

class AdminScaffold extends StatelessWidget {
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Determine active route for sidebar
    final String location = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          AdminSidebar(activeRoute: location),
          Expanded(
            child: Column(
              children: [
                const AdminHeader(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
