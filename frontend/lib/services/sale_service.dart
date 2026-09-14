import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/retail_models.dart';

class SaleService {
  const SaleService(this._api);

  final ApiClient _api;

  Future<List<Sale>> sales({
    String? invoiceCode,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? staffId,
    String? status,
    int? offset,
    int? limit,
  }) async {
    final data = await _api.get(
      ApiConstants.sales,
      query: {
        'invoice_code': invoiceCode,
        'date_from': dateFrom?.toIso8601String(),
        'date_to': dateTo?.toIso8601String(),
        'staff_id': staffId,
        'status': status,
        'offset': offset,
        'limit': limit,
      },
    );
    return (data as List)
        .map((item) => Sale.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Sale> sale(int id) async {
    final data = Map<String, dynamic>.from(
      await _api.get('${ApiConstants.sales}/$id') as Map,
    );
    return Sale.fromJson(data);
  }

  Future<Sale> create({
    required List<Map<String, dynamic>> items,
    required double discountAmount,
    required String paymentMethod,
    String? customerName,
  }) async {
    final data = Map<String, dynamic>.from(
      await _api.post(
            ApiConstants.sales,
            data: {
              'items': items,
              'discount_amount': discountAmount,
              'payment_method': paymentMethod,
              'customer_name': customerName,
            },
          )
          as Map,
    );
    return Sale.fromJson(data);
  }

  Future<Sale> cancel(int id) async {
    final data = Map<String, dynamic>.from(
      await _api.post('${ApiConstants.sales}/$id/cancel') as Map,
    );
    return Sale.fromJson(data);
  }
}
