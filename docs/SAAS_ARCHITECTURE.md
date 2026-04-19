# SaaS Multi-tenant Architecture (Frontend)

This document describes how the fleet management system implements multi-tenancy in the frontend.

## 1. Tenant Identification
All core models (Vehicles, Drivers, Inspections, etc.) now include a `companyId` field. This ensures that data is filtered appropriately.

## 2. Global State Management
- **Tenant Context**: The application maintains a `currentCompanyId` in its global state.
- **Switching Tenants**: Super Admins can switch between tenants (Impersonation/Shadow Mode). This updates the `currentCompanyId` globally, effectively filtering all views to show only that company's data.

## 3. Mock Data Strategy
To support development without a backend, the mock repositories (`mock_vehicles.dart`, etc.) will:
1. Initialize data with various `companyId`s.
2. Provide methods like `getVehiclesByCompany(String companyId)`.

## 4. UI Layer Requirements
- **Company Branding**: UI components should fetch colors and logos from the current company's configuration.
- **Role-based Access**: 
  - `SUPER_ADMIN`: Access to all companies and master settings.
  - `ADMIN`: Access only to their own company settings.
  - `DRIVER`: Access only to assigned vehicles within their company.

## 5. Security (Frontend)
- Navigation guards prevent users from accessing URLs belonging to other `companyId`s.
- Tenant-specific keys are used for caching data in `SharedPreferences`.
