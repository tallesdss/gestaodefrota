import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../onboarding/login_screen.dart';
import '../onboarding/register_screen.dart';
import '../onboarding/selection_profile_screen.dart';
import '../../admin/dashboard/admin_dashboard_screen.dart';
import '../../admin/vehicles/vehicle_list_screen.dart';
import '../../admin/vehicles/vehicle_detail_screen.dart';
import '../../admin/drivers/driver_list_screen.dart';
import '../../admin/drivers/driver_form_screen.dart';
import '../../admin/managers/manager_list_screen.dart';
import '../../admin/managers/manager_form_screen.dart';
import '../../admin/drivers/driver_profile_screen.dart';
import '../../admin/drivers/driver_timeline_screen.dart';
import '../../admin/drivers/driver_inspection_history_screen.dart';
import '../../admin/users/registration_audit_screen.dart';
import '../../admin/users/profile_screen.dart';
import '../../admin/users/settings_screen.dart';
import '../../admin/users/notifications_screen.dart';
import '../../admin/contracts/contract_list_screen.dart';
import '../../admin/contracts/contract_form_screen.dart';
import '../../admin/maintenance/maintenance_list_screen.dart';
import '../../admin/inspections/inspection_audit_screen.dart';
import '../../admin/inspections/inspection_form_screen.dart';
import '../../admin/inspections/inspection_detail_screen.dart';
import '../../admin/financial/financial_list_screen.dart';
import '../../admin/financial/financial_flow_detail_screen.dart';
import '../../admin/financial/delinquency_list_screen.dart';
import '../../admin/admin_scaffold.dart';
import '../../manager/dashboard/manager_dashboard_screen.dart';
import '../../manager/widgets/manager_scaffold.dart';
import '../../models/driver.dart';
import '../../models/manager.dart';
import '../../models/contract.dart';
import '../../admin/vehicles/vehicle_form_screen.dart';
import '../../admin/vehicles/vehicle_usage_history_screen.dart';
import '../../admin/vehicles/vehicle_inspection_history_screen.dart';
import '../../admin/control_panel/control_panel_screen.dart';
import '../../admin/control_panel/salary_history_screen.dart';
import '../../admin/control_panel/manager_salaries_screen.dart';
import '../../admin/control_panel/expense_categories_screen.dart';
import '../../admin/control_panel/cash_flow_form_screen.dart';
import '../../admin/managers/user_search_promotion_screen.dart';
import '../../admin/control_panel/financial_report_screen.dart';




class AppRoutes {
  static const String root = '/selection';
  static const String login = '/';
  static const String register = '/register';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminVehicleList = '/admin/vehicles';
  static const String adminVehicleDetail = '/admin/vehicles/detail/:id';
  static const String adminDriverList = '/admin/drivers';
  static const String adminDriverForm = '/admin/drivers/form';
  static const String adminDriverProfile = '/admin/drivers/profile/:id';
  static const String adminDriverTimeline = '/admin/drivers/:id/timeline';
  static const String adminManagerList = '/admin/managers';
  static const String adminManagerForm = '/admin/managers/form';
  static const String adminRegistrationAudit = '/admin/audit';
  static const String adminContractList = '/admin/contracts';
  static const String adminContractForm = '/admin/contracts/form';
  static const String adminMaintenanceList = '/admin/maintenance';
  static const String adminInspectionAudit = '/admin/inspections';
  static const String adminInspectionForm = '/admin/inspections/new';
  static const String adminInspectionDetail = '/admin/inspections/:id';
  static const String adminFinancialList = '/admin/financial';
  static const String adminFinancialFlow = '/admin/financial/flow';
  static const String adminDelinquencyDrivers = '/admin/delinquency';
  static const String adminNotifications = '/admin/notifications';
  static const String adminSettings = '/admin/settings';
  static const String adminProfile = '/admin/profile';
  static const String adminVehicleForm = '/admin/vehicles/form';
  static const String adminVehicleUsageHistory = '/admin/vehicles/:id/usage';
  static const String adminControlPanel = '/admin/control-panel';
  static const String adminManagerSalaries = '/admin/control-panel/salaries';
  static const String adminManagerSalaryHistory = '/admin/control-panel/salaries/history';
  static const String adminExpenseCategories = '/admin/control-panel/categories';
  static const String adminCashFlowForm = '/admin/control-panel/cash-flow-form';
  static const String adminManagerSearch = '/admin/managers/search';
  static const String adminFinancialReport = '/admin/control-panel/report';



  static const String gestorDashboard = '/gestor/dashboard';
  static const String gestorFinancialList = '/gestor/financial';
  static const String gestorDriverList = '/gestor/drivers';
  static const String gestorInspectionAudit = '/gestor/inspections';
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
      
      // Admin Shell
      ShellRoute(
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
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
            path: adminDriverForm,
            builder: (context, state) {
              final driver = state.extra as Driver?;
              return DriverFormScreen(driver: driver);
            },
          ),
          GoRoute(
            path: adminDriverProfile,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverProfileScreen(driverId: id);
            },
          ),
          GoRoute(
            path: adminDriverTimeline,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverTimelineScreen(driverId: id);
            },
          ),
          GoRoute(
            path: '/admin/drivers/:id/inspections',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverInspectionHistoryScreen(driverId: id);
            },
          ),
          GoRoute(
            path: adminManagerList,
            builder: (context, state) => const ManagerListScreen(),
          ),
          GoRoute(
            path: adminManagerForm,
            builder: (context, state) {
              final manager = state.extra as Manager?;
              return ManagerFormScreen(manager: manager);
            },
          ),
          GoRoute(
            path: adminRegistrationAudit,
            builder: (context, state) {
               final id = state.uri.queryParameters['id'];
               return RegistrationAuditScreen(initialSelectedId: id);
            },
          ),
          GoRoute(
            path: adminContractList,
            builder: (context, state) => const ContractListScreen(),
          ),
          GoRoute(
            path: adminContractForm,
            builder: (context, state) {
              final contract = state.extra as Contract?;
              return ContractFormScreen(contract: contract);
            },
          ),
          GoRoute(
            path: adminMaintenanceList,
            builder: (context, state) => const MaintenanceListScreen(),
          ),
          GoRoute(
            path: adminInspectionAudit,
            builder: (context, state) => const InspectionAuditScreen(),
          ),
          GoRoute(
            path: adminInspectionForm,
            builder: (context, state) => const InspectionFormScreen(),
          ),
          GoRoute(
            path: adminInspectionDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InspectionDetailScreen(inspectionId: id);
            },
          ),
          GoRoute(
            path: adminFinancialList,
            builder: (context, state) => const FinancialListScreen(),
          ),
          GoRoute(
            path: adminFinancialFlow,
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return FinancialFlowDetailScreen(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: adminDelinquencyDrivers,
            builder: (context, state) => const DelinquencyListScreen(),
          ),
          GoRoute(
            path: adminNotifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: adminSettings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: adminProfile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: adminVehicleForm,
            builder: (context, state) => const VehicleFormScreen(),
          ),
          GoRoute(
            path: adminVehicleUsageHistory,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VehicleUsageHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: '/admin/vehicles/:id/inspections',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VehicleInspectionHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: adminControlPanel,
            builder: (context, state) => const ControlPanelScreen(),
          ),
          GoRoute(
            path: adminManagerSalaries,
            builder: (context, state) => const ManagerSalariesScreen(),
          ),
          GoRoute(
            path: adminManagerSalaryHistory,
            builder: (context, state) => const SalaryHistoryScreen(),
          ),
          GoRoute(
            path: adminExpenseCategories,
            builder: (context, state) => const ExpenseCategoriesScreen(),
          ),
          GoRoute(
            path: adminCashFlowForm,
            builder: (context, state) => const CashFlowFormScreen(),
          ),
          GoRoute(
            path: adminManagerSearch,
            builder: (context, state) => const UserSearchPromotionScreen(),
          ),
          GoRoute(
            path: adminFinancialReport,
            builder: (context, state) => const FinancialReportScreen(),
          ),
        ],
      ),

      // Gestor Shell
      ShellRoute(
        builder: (context, state, child) => ManagerScaffold(child: child),
        routes: [
          GoRoute(
            path: gestorDashboard,
            builder: (context, state) => const ManagerDashboardScreen(),
          ),
          GoRoute(
            path: gestorFinancialList,
            builder: (context, state) => const FinancialListScreen(),
          ),
          GoRoute(
            path: gestorDriverList,
            builder: (context, state) => const DriverListScreen(),
          ),
          GoRoute(
            path: gestorInspectionAudit,
            builder: (context, state) => const InspectionAuditScreen(),
          ),
        ],
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
