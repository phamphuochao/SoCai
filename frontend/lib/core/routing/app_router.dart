import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../components/layout/app_shell.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/inventory/inventory_history_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/invoices/invoice_detail_screen.dart';
import '../../features/invoices/invoices_screen.dart';
import '../../features/not_found_screen.dart';
import '../../features/products/product_form_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/sales/sales_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/date_utils.dart';
import 'route_paths.dart';

GoRouter createAppRouter(
  AuthProvider auth, {
  String? initialLocation,
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: auth,
  redirect: (context, state) {
    final path = state.uri.path;
    final atLogin = path == RoutePaths.login;
    if (path == '/') {
      return auth.isAuthenticated ? RoutePaths.dashboard : RoutePaths.login;
    }
    if (!auth.isAuthenticated && !atLogin) {
      return Uri(
        path: RoutePaths.login,
        queryParameters: {'from': state.uri.toString()},
      ).toString();
    }
    if (auth.isAuthenticated && atLogin) {
      final from = state.uri.queryParameters['from'];
      return from != null && from.startsWith('/') && from != RoutePaths.login
          ? from
          : RoutePaths.dashboard;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: RoutePaths.login,
      pageBuilder: (context, state) => _webPage(
        state,
        LoginScreen(returnUrl: state.uri.queryParameters['from']),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.dashboard,
          pageBuilder: (_, state) => _webPage(state, const DashboardScreen()),
        ),
        GoRoute(
          path: RoutePaths.sales,
          pageBuilder: (_, state) => _webPage(
            state,
            SalesScreen(search: state.uri.queryParameters['search'] ?? ''),
          ),
        ),
        GoRoute(
          path: RoutePaths.invoices,
          pageBuilder: (_, state) => _webPage(
            state,
            InvoicesScreen(
              search: state.uri.queryParameters['search'] ?? '',
              status: state.uri.queryParameters['status'] ?? 'all',
              from: AppDateUtils.parseQuery(state.uri.queryParameters['from']),
              to: AppDateUtils.parseQuery(state.uri.queryParameters['to']),
              page: _pageFrom(state),
            ),
          ),
        ),
        GoRoute(
          path: '${RoutePaths.invoices}/:id',
          pageBuilder: (_, state) => _webPage(
            state,
            InvoiceDetailScreen(
              saleId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.products,
          pageBuilder: (_, state) => _webPage(
            state,
            ProductsScreen(
              search: state.uri.queryParameters['search'] ?? '',
              status: state.uri.queryParameters['status'] ?? 'all',
              categoryId: int.tryParse(
                state.uri.queryParameters['category'] ?? '',
              ),
              page: _pageFrom(state),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.productNew,
          pageBuilder: (_, state) => _webPage(state, const ProductFormScreen()),
        ),
        GoRoute(
          path: '${RoutePaths.products}/:id/edit',
          pageBuilder: (_, state) => _webPage(
            state,
            ProductFormScreen(
              productId: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.inventory,
          pageBuilder: (_, state) => _webPage(state, const InventoryScreen()),
        ),
        GoRoute(
          path: RoutePaths.inventoryHistory,
          pageBuilder: (_, state) => _webPage(
            state,
            InventoryHistoryScreen(
              productId: int.tryParse(
                state.uri.queryParameters['product'] ?? '',
              ),
              page: _pageFrom(state),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.expenses,
          pageBuilder: (_, state) => _webPage(
            state,
            ExpensesScreen(
              from: AppDateUtils.parseQuery(state.uri.queryParameters['from']),
              to: AppDateUtils.parseQuery(state.uri.queryParameters['to']),
              page: _pageFrom(state),
            ),
          ),
        ),
        GoRoute(
          path: RoutePaths.reports,
          pageBuilder: (_, state) => _webPage(
            state,
            ReportsScreen(
              from: AppDateUtils.parseQuery(state.uri.queryParameters['from']),
              to: AppDateUtils.parseQuery(state.uri.queryParameters['to']),
            ),
          ),
        ),
      ],
    ),
  ],
  errorPageBuilder: (_, state) => _webPage(state, const NotFoundScreen()),
);

NoTransitionPage<void> _webPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

int _pageFrom(GoRouterState state) {
  final page = int.tryParse(state.uri.queryParameters['page'] ?? '');
  return page != null && page > 0 ? page : 1;
}
