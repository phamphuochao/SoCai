// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'RetailManager';

  @override
  String get appSubtitle => 'Retail revenue management';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get sales => 'Sales';

  @override
  String get invoices => 'Invoices';

  @override
  String get products => 'Products';

  @override
  String get inventory => 'Inventory';

  @override
  String get expenses => 'Expenses';

  @override
  String get reports => 'Reports';

  @override
  String get logout => 'Sign out';

  @override
  String get adminRole => 'Administrator';

  @override
  String get staffRole => 'Staff';

  @override
  String get genericError => 'Unable to load data. Please try again.';

  @override
  String get loadingData => 'Loading data...';

  @override
  String get noData => 'No data yet.';

  @override
  String get retry => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get closeNotification => 'Close notification';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get cancel => 'Cancel';

  @override
  String get select => 'Select';

  @override
  String get selectDate => 'Select date';

  @override
  String get fromDate => 'From';

  @override
  String get toDate => 'To';

  @override
  String get filter => 'Filter';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get product => 'Product';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get notes => 'Notes';

  @override
  String get action => 'Actions';

  @override
  String get type => 'Type';

  @override
  String get change => 'Change';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue using the system.';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

  @override
  String get demoAccount => 'Demo account: admin / admin123';

  @override
  String get loginHeroTitle => 'Everything within reach';

  @override
  String get loginHeroSubtitle =>
      'Manage products, sales, inventory, and revenue with ease.';

  @override
  String get storeIllustration => 'Retail store illustration';

  @override
  String welcomeUser(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get revenueToday => 'Revenue today';

  @override
  String get netRevenue => 'Net revenue';

  @override
  String get grossProfit => 'Gross profit';

  @override
  String get netProfit => 'Net profit';

  @override
  String get invoiceCount => 'Invoice count';

  @override
  String get lowStockProducts => 'Low-stock products';

  @override
  String get revenueLastSevenDays => 'Revenue over the last 7 days';

  @override
  String get dailyRevenue => 'Daily revenue';

  @override
  String get topProducts => 'Top-selling products';

  @override
  String get noSalesInRange => 'No sales in this period.';

  @override
  String productQuantity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String highestAmount(String amount) {
    return 'Highest $amount';
  }

  @override
  String get productsSubtitle => 'View prices, stock levels, and sales status.';

  @override
  String get addProduct => 'Add product';

  @override
  String get searchNameOrSku => 'Search by name or SKU';

  @override
  String get allStatuses => 'All statuses';

  @override
  String get activeProducts => 'Active';

  @override
  String get inactiveProducts => 'Inactive';

  @override
  String get lowStock => 'Low stock';

  @override
  String get inStock => 'In stock';

  @override
  String get allCategories => 'All categories';

  @override
  String get noMatchingProducts => 'No matching products found.';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get productCode => 'Code';

  @override
  String get productName => 'Product name';

  @override
  String get sellingPrice => 'Selling price';

  @override
  String get stock => 'Stock';

  @override
  String stockValue(int count) {
    return 'Stock $count';
  }

  @override
  String get stopSelling => 'Deactivate';

  @override
  String get stopProductTitle => 'Deactivate product';

  @override
  String stopProductPrompt(String name) {
    return 'Deactivate “$name”? Existing invoice data will be retained.';
  }

  @override
  String stopProductSuccess(String name) {
    return '$name has been deactivated.';
  }

  @override
  String get editProduct => 'Edit product';

  @override
  String get createProduct => 'Add product';

  @override
  String get adminOnlyProducts => 'Only administrators can change products.';

  @override
  String get sku => 'SKU';

  @override
  String get costPrice => 'Cost price';

  @override
  String get initialStock => 'Initial stock';

  @override
  String get lowStockThreshold => 'Low-stock threshold';

  @override
  String get saveProduct => 'Save product';

  @override
  String get productUpdated => 'Product updated.';

  @override
  String get productCreated => 'Product created.';

  @override
  String get salesSubtitle =>
      'Select products and create a multi-item invoice.';

  @override
  String get productList => 'Products';

  @override
  String get noActiveProducts => 'No active products.';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get cartStockLimit =>
      'The cart quantity has reached the available stock.';

  @override
  String get invoiceCart => 'Invoice';

  @override
  String get clearAll => 'Clear all';

  @override
  String get emptyCart => 'The cart is empty.';

  @override
  String get customerOptional => 'Customer name (optional)';

  @override
  String get discount => 'Discount';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cash => 'Cash';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get card => 'Card';

  @override
  String get estimatedSubtotal => 'Estimated subtotal';

  @override
  String get paymentConfirmationNote =>
      'The final amount is confirmed when the invoice is created.';

  @override
  String get checkout => 'Checkout';

  @override
  String get addAtLeastOneProduct => 'Add at least one product.';

  @override
  String get discountMustNotBeNegative =>
      'Discount must be a non-negative number.';

  @override
  String invoiceCreated(String code, String total) {
    return 'Invoice $code created. Total: $total.';
  }

  @override
  String get invoicesSubtitle =>
      'Search and view the details of each sales invoice.';

  @override
  String get createInvoice => 'Create invoice';

  @override
  String get invoiceCode => 'Invoice code';

  @override
  String get noMatchingInvoices => 'No matching invoices found.';

  @override
  String get staff => 'Staff';

  @override
  String get payment => 'Payment';

  @override
  String get invoiceList => 'Invoice list';

  @override
  String get cancelInvoice => 'Cancel invoice';

  @override
  String get cancelInvoicePrompt =>
      'The invoice will be cancelled and its stock restored once.';

  @override
  String get invoiceCancelled => 'Invoice cancelled and stock restored.';

  @override
  String createdAt(String date) {
    return 'Created at $date';
  }

  @override
  String get customer => 'Customer';

  @override
  String get walkInCustomer => 'Walk-in customer';

  @override
  String get quantity => 'Quantity';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get lineTotal => 'Line total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get grandTotal => 'Total';

  @override
  String productNumber(int id) {
    return 'Product #$id';
  }

  @override
  String get inventorySubtitle => 'Current stock levels and low-stock alerts.';

  @override
  String get inventoryHistory => 'Inventory history';

  @override
  String get importOrAdjust => 'Import / adjust';

  @override
  String get noInventoryProducts => 'No products in inventory.';

  @override
  String get currentStock => 'Current stock';

  @override
  String get warningThreshold => 'Alert threshold';

  @override
  String thresholdValue(int value) {
    return 'Threshold $value';
  }

  @override
  String get updateInventory => 'Update inventory';

  @override
  String get operationType => 'Operation type';

  @override
  String get importStock => 'Import stock';

  @override
  String get inventoryAdjustment => 'Stocktake adjustment';

  @override
  String get importQuantity => 'Import quantity';

  @override
  String get quantityChange => 'Quantity change (+/-)';

  @override
  String get importQuantityPositive =>
      'Import quantity must be greater than 0.';

  @override
  String get adjustmentNonZero => 'Adjustment must not be 0.';

  @override
  String get inventoryHistorySubtitle =>
      'Every stock change is recorded for tracking.';

  @override
  String get currentInventory => 'Current inventory';

  @override
  String get filterByProduct => 'Filter by product';

  @override
  String get allProducts => 'All products';

  @override
  String get noInventoryTransactions => 'No inventory transactions yet.';

  @override
  String get transactionImport => 'Import';

  @override
  String get transactionAdjustment => 'Adjustment';

  @override
  String get transactionSale => 'Sale';

  @override
  String get transactionReturn => 'Return';

  @override
  String get expensesSubtitle =>
      'Track expenses for accurate net profit calculations.';

  @override
  String get addExpense => 'Add expense';

  @override
  String totalValue(String amount) {
    return 'Total: $amount';
  }

  @override
  String pageTotalValue(String amount) {
    return 'Page total: $amount';
  }

  @override
  String get noExpensesInRange => 'No expenses in this period.';

  @override
  String get expenseType => 'Expense type';

  @override
  String get expenseDate => 'Expense date';

  @override
  String get invalidExpense =>
      'Enter an expense type and an amount greater than 0.';

  @override
  String get expenseCreated => 'Expense added.';

  @override
  String get reportsSubtitle => 'Revenue and profit for the selected period.';

  @override
  String get viewReport => 'View report';

  @override
  String get averageOrderValue => 'Average order value';

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String pageNumber(int page) {
    return 'Page $page';
  }

  @override
  String get pageNotFound => 'The page you requested does not exist.';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String mustBeNumber(String field) {
    return '$field must be a number';
  }

  @override
  String mustNotBeNegative(String field) {
    return '$field must not be negative';
  }

  @override
  String mustBePositive(String field) {
    return '$field must be greater than 0';
  }
}
