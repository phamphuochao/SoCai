import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/retail_models.dart';

class InventoryService {
  const InventoryService(this._api);

  final ApiClient _api;

  Future<List<Product>> lowStock() async {
    final data = await _api.get('${ApiConstants.inventory}/low-stock');
    return (data as List)
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<InventoryTransaction>> transactions({
    int? productId,
    int? offset,
    int? limit,
  }) async {
    final data = await _api.get(
      '${ApiConstants.inventory}/transactions',
      query: {'product_id': productId, 'offset': offset, 'limit': limit},
    );
    return (data as List)
        .map(
          (item) => InventoryTransaction.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Product> importStock(int productId, int quantity, String? note) async {
    final data = Map<String, dynamic>.from(
      await _api.post(
            '${ApiConstants.inventory}/import',
            data: {'product_id': productId, 'quantity': quantity, 'note': note},
          )
          as Map,
    );
    return Product.fromJson(data);
  }

  Future<Product> adjustStock(
    int productId,
    int quantityChange,
    String? note,
  ) async {
    final data = Map<String, dynamic>.from(
      await _api.post(
            '${ApiConstants.inventory}/adjust',
            data: {
              'product_id': productId,
              'quantity_change': quantityChange,
              'note': note,
            },
          )
          as Map,
    );
    return Product.fromJson(data);
  }
}
