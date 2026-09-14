import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/retail_models.dart';

class ProductService {
  const ProductService(this._api);

  final ApiClient _api;

  Future<List<Category>> categories({bool activeOnly = true}) async {
    final data = await _api.get(
      ApiConstants.categories,
      query: {'active_only': activeOnly},
    );
    return (data as List)
        .map(
          (item) => Category.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Product>> products({
    String? keyword,
    int? categoryId,
    bool activeOnly = false,
    bool lowStockOnly = false,
    bool? isActive,
    int? offset,
    int? limit,
  }) async {
    final data = await _api.get(
      ApiConstants.products,
      query: {
        'keyword': keyword,
        'category_id': categoryId,
        'active_only': activeOnly,
        'low_stock_only': lowStockOnly,
        'is_active': isActive,
        'offset': offset,
        'limit': limit,
      },
    );
    return (data as List)
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Product> product(int id) async {
    final data = Map<String, dynamic>.from(
      await _api.get('${ApiConstants.products}/$id') as Map,
    );
    return Product.fromJson(data);
  }

  Future<Product> create(Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(
      await _api.post(ApiConstants.products, data: payload) as Map,
    );
    return Product.fromJson(data);
  }

  Future<Product> update(int id, Map<String, dynamic> payload) async {
    final data = Map<String, dynamic>.from(
      await _api.patch('${ApiConstants.products}/$id', data: payload) as Map,
    );
    return Product.fromJson(data);
  }

  Future<Product> deactivate(int id) async {
    final data = Map<String, dynamic>.from(
      await _api.delete('${ApiConstants.products}/$id') as Map,
    );
    return Product.fromJson(data);
  }
}
