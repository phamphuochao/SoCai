import '../core/utils/json_utils.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  final int id;
  final String username;
  final String fullName;
  final String role;

  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: jsonInt(json['id']),
    username: json['username']?.toString() ?? '',
    fullName: json['full_name']?.toString() ?? '',
    role: json['role']?.toString() ?? 'staff',
  );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  final int id;
  final String name;
  final String description;
  final bool isActive;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: jsonInt(json['id']),
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    isActive: json['is_active'] == true,
  );
}

class Product {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.categoryId,
    required this.costPrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.isActive,
  });

  final int id;
  final String sku;
  final String name;
  final int? categoryId;
  final double costPrice;
  final double sellingPrice;
  final int stockQuantity;
  final int minStockLevel;
  final bool isActive;

  bool get isLowStock => stockQuantity <= minStockLevel;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: jsonInt(json['id']),
    sku: json['sku']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    categoryId: json['category_id'] == null
        ? null
        : jsonInt(json['category_id']),
    costPrice: jsonDouble(json['cost_price']),
    sellingPrice: jsonDouble(json['selling_price']),
    stockQuantity: jsonInt(json['stock_quantity']),
    minStockLevel: jsonInt(json['min_stock_level']),
    isActive: json['is_active'] == true,
  );
}

class SaleItem {
  const SaleItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPriceSnapshot,
    required this.lineTotal,
  });

  final int id;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double costPriceSnapshot;
  final double lineTotal;

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
    id: jsonInt(json['id']),
    productId: jsonInt(json['product_id']),
    quantity: jsonInt(json['quantity']),
    unitPrice: jsonDouble(json['unit_price']),
    costPriceSnapshot: jsonDouble(json['cost_price_snapshot']),
    lineTotal: jsonDouble(json['line_total']),
  );
}

class Sale {
  const Sale({
    required this.id,
    required this.invoiceCode,
    required this.staffId,
    required this.customerName,
    required this.subtotal,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.soldAt,
    required this.items,
  });

  final int id;
  final String invoiceCode;
  final int staffId;
  final String? customerName;
  final double subtotal;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final DateTime soldAt;
  final List<SaleItem> items;

  bool get isCancelled => status == 'CANCELLED';

  factory Sale.fromJson(Map<String, dynamic> json) => Sale(
    id: jsonInt(json['id']),
    invoiceCode: json['invoice_code']?.toString() ?? '',
    staffId: jsonInt(json['staff_id']),
    customerName: json['customer_name']?.toString(),
    subtotal: jsonDouble(json['subtotal']),
    discountAmount: jsonDouble(json['discount_amount']),
    totalAmount: jsonDouble(json['total_amount']),
    paymentMethod: json['payment_method']?.toString() ?? 'CASH',
    status: json['status']?.toString() ?? 'COMPLETED',
    soldAt: jsonDateTime(json['sold_at']),
    items: (json['items'] as List? ?? const [])
        .map(
          (item) => SaleItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
  );
}

class InventoryTransaction {
  const InventoryTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantityChange,
    required this.note,
    required this.createdAt,
  });

  final int id;
  final int productId;
  final String type;
  final int quantityChange;
  final String? note;
  final DateTime createdAt;

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      InventoryTransaction(
        id: jsonInt(json['id']),
        productId: jsonInt(json['product_id']),
        type: json['type']?.toString() ?? '',
        quantityChange: jsonInt(json['quantity_change']),
        note: json['note']?.toString(),
        createdAt: jsonDateTime(json['created_at']),
      );
}

class Expense {
  const Expense({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.note,
  });

  final int id;
  final String type;
  final double amount;
  final DateTime date;
  final String? note;

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: jsonInt(json['id']),
    type: json['expense_type']?.toString() ?? '',
    amount: jsonDouble(json['amount']),
    date: jsonDateTime(json['expense_date']),
    note: json['note']?.toString(),
  );
}

class RevenueSummary {
  const RevenueSummary({
    required this.netRevenue,
    required this.orderCount,
    required this.averageOrderValue,
    required this.grossProfit,
    required this.netProfit,
  });

  final double netRevenue;
  final int orderCount;
  final double averageOrderValue;
  final double grossProfit;
  final double netProfit;

  factory RevenueSummary.fromJson(Map<String, dynamic> json) => RevenueSummary(
    netRevenue: jsonDouble(json['net_revenue']),
    orderCount: jsonInt(json['order_count']),
    averageOrderValue: jsonDouble(json['average_order_value']),
    grossProfit: jsonDouble(json['gross_profit']),
    netProfit: jsonDouble(json['net_profit']),
  );
}

class TopProduct {
  const TopProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final int id;
  final String name;
  final int quantity;
  final double revenue;

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
    id: jsonInt(json['id']),
    name: json['name']?.toString() ?? '',
    quantity: jsonInt(json['total_quantity']),
    revenue: jsonDouble(json['total_revenue']),
  );
}

class DailyRevenue {
  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.orderCount,
  });

  final DateTime date;
  final double revenue;
  final int orderCount;

  factory DailyRevenue.fromJson(Map<String, dynamic> json) => DailyRevenue(
    date: jsonDateTime(json['date']),
    revenue: jsonDouble(json['revenue']),
    orderCount: jsonInt(json['order_count']),
  );
}
