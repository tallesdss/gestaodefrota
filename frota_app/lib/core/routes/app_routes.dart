import 'package:go_router/go_router.dart';
import '../onboarding/login_screen.dart';
import '../onboarding/register_screen.dart';
import '../onboarding/selection_profile_screen.dart';
import '../onboarding/forgot_password_screen.dart';
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
import '../../admin/maintenance/workshop_list_screen.dart';
import '../../admin/maintenance/workshop_detail_screen.dart';
import '../../admin/maintenance/workshop_form_screen.dart';
import '../../admin/inspections/inspection_audit_screen.dart';
import '../../admin/inspections/inspection_form_screen.dart';
import '../../admin/inspections/inspection_detail_screen.dart';
import '../../admin/financial/financial_list_screen.dart';
import '../../admin/financial/financial_flow_detail_screen.dart';
import '../../admin/financial/delinquency_list_screen.dart';
import '../../admin/maintenance/maintenance_detail_screen.dart';
import '../../admin/maintenance/maintenance_form_screen.dart';
import '../../admin/vehicles/vehicle_maintenance_history_screen.dart';
import '../../admin/admin_scaffold.dart';
import '../../admin/vehicles/vehicle_form_screen.dart';
import '../../models/driver.dart';
import '../../models/manager.dart';
import '../../models/contract.dart';
import '../../models/workshop.dart';
import '../../admin/vehicles/vehicle_usage_history_screen.dart';
import '../../admin/vehicles/vehicle_inspection_history_screen.dart';
import '../../admin/control_panel/control_panel_screen.dart';
import '../../admin/control_panel/salary_history_screen.dart';
import '../../admin/control_panel/manager_salaries_screen.dart';
import '../../admin/control_panel/expense_categories_screen.dart';
import '../../admin/control_panel/cash_flow_form_screen.dart';
import '../../admin/managers/user_search_promotion_screen.dart';
import '../../admin/control_panel/financial_report_screen.dart';
import '../../driver_portal/onboarding/driver_onboarding_docs_screen.dart';
import '../../driver_portal/onboarding/driver_onboarding_contract_screen.dart';
import '../../driver_portal/profile/driver_profile_setup_screen.dart';
import '../../driver_portal/profile/driver_profile_detail_screen.dart';
import '../../driver_portal/profile/driver_documents_screen.dart';
import '../../driver_portal/profile/account_security_screen.dart';
import '../../driver_portal/home/driver_home_screen.dart';
import '../../driver_portal/home/driver_activity_timeline_screen.dart';
import '../../driver_portal/inspections/inspection_checkin_screen.dart';
import '../../driver_portal/inspections/inspection_checkout_screen.dart';
import '../../driver_portal/inspections/occurrence_report_screen.dart';
import '../../driver_portal/inspections/inspection_history_screen.dart';
import '../../driver_portal/inspections/inspection_detail_screen.dart';
import '../../driver_portal/payments/financial_statement_screen.dart';
import '../../driver_portal/payments/pix_checkout_screen.dart';
import '../../driver_portal/payments/receipts_history_screen.dart';
import '../../driver_portal/notifications/notifications_screen.dart';
import '../../driver_portal/support/support_screen.dart';
import '../../models/financial_entry.dart';
import '../../driver_portal/widgets/driver_scaffold.dart';
import '../../super_admin/onboarding/super_admin_login_screen.dart';
import '../../super_admin/dashboard/super_admin_dashboard_screen.dart';
import '../../super_admin/widgets/super_admin_scaffold.dart';
import '../../super_admin/companies/company_list_screen.dart';
import '../../super_admin/plans/plans_screen.dart';

class AppRoutes {
  static const String root = '/selection';
  static const String login = '/';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String adminDashboard = '/admin/dashboard';
  static const String superAdminLogin = '/super-admin/login';
  static const String superAdminDashboard = '/super-admin/dashboard';
  static const String superAdminCompanies = '/super-admin/companies';
  static const String superAdminPlans = '/super-admin/plans';
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
  static const String adminManagerSalaryHistory =
      '/admin/control-panel/salaries/history';
  static const String adminExpenseCategories =
      '/admin/control-panel/categories';
  static const String adminCashFlowForm = '/admin/control-panel/cash-flow-form';
  static const String adminManagerSearch = '/admin/managers/search';
  static const String adminFinancialReport = '/admin/control-panel/report';
  static const String adminWorkshops = '/admin/workshops';
  static const String adminWorkshopDetail = '/admin/workshops/detail/:id';
  static const String adminWorkshopForm = '/admin/workshops/form';
  static const String adminVehicleMaintenanceHistory =
      '/admin/vehicles/:id/maintenance';
  static const String adminMaintenanceDetail = '/admin/maintenance/detail/:id';
  static const String adminMaintenanceForm = '/admin/maintenance/form';

  static const String gestorDashboard = '/gestor/dashboard';
  static const String gestorFinancialList = '/gestor/financial';
  static const String gestorDriverList = '/gestor/drivers';
  static const String gestorInspectionAudit = '/gestor/inspections';
  static const String gestorVehicleList = '/gestor/vehicles';
  static const String gestorAudit = '/gestor/audit';
  static const String gestorNotifications = '/gestor/notifications';
  static const String gestorProfile = '/gestor/profile';
  static const String gestorVehicleMaintenanceHistory =
      '/gestor/vehicles/:id/maintenance';
  static const String gestorMaintenanceDetail =
      '/gestor/maintenance/detail/:id';
  static const String gestorMaintenanceForm = '/gestor/maintenance/form';
  static const String gestorVehicleDetail = '/gestor/vehicles/detail/:id';
  static const String gestorDriverProfile = '/gestor/drivers/profile/:id';
  static const String gestorInspectionDetail = '/gestor/inspections/:id';
  static const String driverOnboardingDocs = '/driver/onboarding/docs';
  static const String driverOnboardingContract = '/driver/onboarding/contract';
  static const String driverProfileSetup = '/driver/profile-setup';
  static const String driverHome = '/driver/home';
  static const String driverProfileDetail = '/driver/profile-detail';
  static const String driverAccountSecurity = '/driver/account-security';
  static const String driverDocuments = '/driver/documents';
  static const String driverActivityTimeline = '/driver/activity-timeline';
  static const String driverInspectionCheckIn = '/driver/inspection/checkin';
  static const String driverInspectionCheckOut = '/driver/inspection/checkout';
  static const String driverOccurrenceReport = '/driver/occurrence/report';
  static const String driverInspectionHistory = '/driver/inspection/history';
  static const String driverInspectionDetail = '/driver/inspection/:id';
  static const String driverFinancialStatement = '/driver/financial/statement';
  static const String driverPixCheckout = '/driver/financial/checkout';
  static const String driverReceipts = '/driver/financial/receipts';
  static const String driverNotifications = '/driver/notifications';
  static const String driverSupport = '/driver/support';

  static final router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: root,
        builder: (context, state) => const SelectionProfileScreen(),
      ),

      // Super Admin Routes
      GoRoute(
        path: superAdminLogin,
        builder: (context, state) => const SuperAdminLoginScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) => SuperAdminScaffold(child: child),
        routes: [
          GoRoute(
            path: superAdminDashboard,
            builder: (context, state) => const SuperAdminDashboardScreen(),
          ),
          GoRoute(
            path: superAdminCompanies,
            builder: (context, state) => const CompanyListScreen(),
          ),
          GoRoute(
            path: superAdminPlans,
            builder: (context, state) => const PlansScreen(),
          ),
          // Add other super admin routes here as they are implemented
        ],
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
          GoRoute(
            path: adminWorkshops,
            builder: (context, state) => const WorkshopListScreen(),
          ),
          GoRoute(
            path: adminWorkshopDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return WorkshopDetailScreen(workshopId: id);
            },
          ),
          GoRoute(
            path: adminWorkshopForm,
            builder: (context, state) {
              final workshop = state.extra as Workshop?;
              return WorkshopFormScreen(workshop: workshop);
            },
          ),
          GoRoute(
            path: adminVehicleMaintenanceHistory,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaintenanceHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: adminMaintenanceDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaintenanceDetailScreen(maintenanceId: id);
            },
          ),
          GoRoute(
            path: adminMaintenanceForm,
            builder: (context, state) {
              final vehicleId = (state.extra as String?) ??
                  state.uri.queryParameters['vehicleId'];
              return MaintenanceFormScreen(initialVehicleId: vehicleId);
            },
          ),
        ],
      ),

      // Gestor Shell (Mirrors Admin Shell but excludes Control Panel)
      ShellRoute(
        builder: (context, state, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(
            path: gestorDashboard,
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: gestorVehicleList,
            builder: (context, state) => const VehicleListScreen(),
          ),
          GoRoute(
            path: gestorVehicleDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VehicleDetailScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: '/gestor/vehicles/form', // Added missing form route
            builder: (context, state) => const VehicleFormScreen(),
          ),
          GoRoute(
            path: '/gestor/vehicles/:id/usage', // Added missing history route
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VehicleUsageHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path:
                '/gestor/vehicles/:id/inspections', // Added missing history route
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VehicleInspectionHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: gestorDriverList,
            builder: (context, state) => const DriverListScreen(),
          ),
          GoRoute(
            path: '/gestor/drivers/form', // Added missing form route
            builder: (context, state) {
              final driver = state.extra as Driver?;
              return DriverFormScreen(driver: driver);
            },
          ),
          GoRoute(
            path: gestorDriverProfile,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverProfileScreen(driverId: id);
            },
          ),
          GoRoute(
            path:
                '/gestor/drivers/:id/timeline', // Added missing timeline route
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverTimelineScreen(driverId: id);
            },
          ),
          GoRoute(
            path:
                '/gestor/drivers/:id/inspections', // Added missing history route
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverInspectionHistoryScreen(driverId: id);
            },
          ),
          GoRoute(
            path: gestorAudit,
            builder: (context, state) {
              final id = state.uri.queryParameters['id'];
              return RegistrationAuditScreen(initialSelectedId: id);
            },
          ),
          GoRoute(
            path: gestorInspectionAudit,
            builder: (context, state) => const InspectionAuditScreen(),
          ),
          GoRoute(
            path: '/gestor/inspections/new', // Added missing form route
            builder: (context, state) => const InspectionFormScreen(),
          ),
          GoRoute(
            path: gestorInspectionDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InspectionDetailScreen(inspectionId: id);
            },
          ),
          GoRoute(
            path: gestorFinancialList,
            builder: (context, state) => const FinancialListScreen(),
          ),
          GoRoute(
            path: '/gestor/financial/flow', // Added missing flow route
            builder: (context, state) {
              final vehicleId = state.uri.queryParameters['vehicleId'];
              return FinancialFlowDetailScreen(vehicleId: vehicleId);
            },
          ),
          GoRoute(
            path: '/gestor/delinquency', // Added missing delinquency route
            builder: (context, state) => const DelinquencyListScreen(),
          ),
          GoRoute(
            path: '/gestor/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/gestor/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/gestor/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: gestorVehicleMaintenanceHistory,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaintenanceHistoryScreen(vehicleId: id);
            },
          ),
          GoRoute(
            path: gestorMaintenanceDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return MaintenanceDetailScreen(maintenanceId: id);
            },
          ),
          GoRoute(
            path: gestorMaintenanceForm,
            builder: (context, state) {
              final vehicleId = (state.extra as String?) ??
                  state.uri.queryParameters['vehicleId'];
              return MaintenanceFormScreen(initialVehicleId: vehicleId);
            },
          ),
        ],
      ),

      GoRoute(
        path: driverOnboardingDocs,
        builder: (context, state) => const DriverOnboardingDocsScreen(),
      ),
      GoRoute(
        path: driverOnboardingContract,
        builder: (context, state) => const DriverOnboardingContractScreen(),
      ),
      GoRoute(
        path: driverProfileSetup,
        builder: (context, state) => const DriverProfileSetupScreen(),
      ),

      // Driver Shell
      ShellRoute(
        builder: (context, state, child) =>
            DriverScaffold(state: state, child: child),
        routes: [
          GoRoute(
            path: driverHome,
            builder: (context, state) => const DriverHomeScreen(),
          ),
          GoRoute(
            path: driverInspectionCheckIn,
            builder: (context, state) => const InspectionCheckInScreen(),
          ),
          GoRoute(
            path: driverInspectionCheckOut,
            builder: (context, state) => const InspectionCheckOutScreen(),
          ),
          GoRoute(
            path: driverOccurrenceReport,
            builder: (context, state) => const OccurrenceReportScreen(),
          ),
          GoRoute(
            path: driverInspectionHistory,
            builder: (context, state) => const InspectionHistoryScreen(),
          ),
          GoRoute(
            path: driverInspectionDetail,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return DriverInspectionDetailScreen(inspectionId: id);
            },
          ),
          GoRoute(
            path: driverFinancialStatement,
            builder: (context, state) => const FinancialStatementScreen(),
          ),
          GoRoute(
            path: driverPixCheckout,
            builder: (context, state) {
              final entry = state.extra as FinancialEntry;
              return PixCheckoutScreen(entry: entry);
            },
          ),
          GoRoute(
            path: driverReceipts,
            builder: (context, state) => const ReceiptsHistoryScreen(),
          ),
          GoRoute(
            path: driverNotifications,
            builder: (context, state) => const DriverNotificationsScreen(),
          ),
          GoRoute(
            path: driverSupport,
            builder: (context, state) => const DriverSupportScreen(),
          ),
          GoRoute(
            path: driverProfileDetail,
            builder: (context, state) => const DriverProfileDetailScreen(),
          ),
          GoRoute(
            path: driverAccountSecurity,
            builder: (context, state) => const AccountSecurityScreen(),
          ),
          GoRoute(
            path: driverDocuments,
            builder: (context, state) => const DriverDocumentsScreen(),
          ),
          GoRoute(
            path: driverActivityTimeline,
            builder: (context, state) => const DriverActivityTimelineScreen(),
          ),
        ],
      ),
    ],
  );
}
