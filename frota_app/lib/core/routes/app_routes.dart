import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// TODO: Import project pages

class AppRoutes {
  static const String login = '/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String driverHome = '/driver/home';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: login,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen (Work in Progress)')),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Dashboard Placeholder')),
        ),
      ),
    ],
  );
}
