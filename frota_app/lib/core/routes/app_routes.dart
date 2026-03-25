import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/login_screen.dart';
import '../onboarding/register_screen.dart';
import '../onboarding/selection_profile_screen.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';
import '../../admin/vehicles/vehicle_list_screen.dart';
import '../../admin/vehicles/vehicle_detail_screen.dart';
import '../../admin/drivers/driver_list_screen.dart';

class AppRoutes {
  static const String root = '/selection';
  static const String login = '/';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminVehicleList = '/admin/vehicles';
  static const String adminVehicleDetail = '/admin/vehicles/detail/:id';
  static const String adminDriverList = '/admin/drivers';
  static const String driverHome = '/driver/home';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: root,
        builder: (context, state) => const SelectionProfileScreen(),
      ),
      GoRoute(
        path: adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: adminVehicleList,
        builder: (context, state) => const VehicleListScreen(),
      ),
      GoRoute(
        path: adminVehicleDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VehicleDetailScreen(vehicleId: id);
        },
      ),
      GoRoute(
        path: adminDriverList,
        builder: (context, state) => const DriverListScreen(),
      ),
      GoRoute(
        path: '/gestor',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Gestor Dashboard (Work in Progress)')),
        ),
      ),
      GoRoute(
        path: driverHome,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Driver Portal (Work in Progress)')),
        ),
      ),
    ],
  );
}
