import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import 'driver_sidebar.dart';

class DriverScaffold extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const DriverScaffold({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context) {
    final String location = state.uri.path;
    final bool isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          if (isDesktop) DriverSidebar(activeRoute: location),
          Expanded(
            child: Column(children: [Expanded(child: child)]),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? _buildBottomNavigationBar(context, location)
          : null,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, String location) {
    int currentIndex = 0;
    if (location == AppRoutes.driverHome) {
      currentIndex = 0;
    } else if (location.startsWith('/driver/financial')) {
      currentIndex = 1;
    } else if (location.startsWith('/driver/inspection')) {
      currentIndex = 2;
    } else if (location == AppRoutes.driverNotifications) {
      currentIndex = 3;
    } else if (location == AppRoutes.driverProfileDetail) {
      currentIndex = 4;
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.driverHome);
              break;
            case 1:
              context.go(AppRoutes.driverFinancialStatement);
              break;
            case 2:
              context.go(AppRoutes.driverInspectionHistory);
              break;
            case 3:
              context.go(AppRoutes.driverNotifications);
              break;
            case 4:
              context.go(AppRoutes.driverProfileDetail);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Financeiro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_outlined),
            activeIcon: Icon(Icons.task),
            label: 'Vistorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
