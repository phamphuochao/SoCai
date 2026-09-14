class RoutePaths {
  const RoutePaths._();

  static const login = '/login';
  static const dashboard = '/dashboard';
  static const sales = '/sales';
  static const invoices = '/invoices';
  static const products = '/products';
  static const productNew = '/products/new';
  static const inventory = '/inventory';
  static const inventoryHistory = '/inventory/history';
  static const expenses = '/expenses';
  static const reports = '/reports';

  static String invoice(int id) => '/invoices/$id';
  static String productEdit(int id) => '/products/$id/edit';
}
