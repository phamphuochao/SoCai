import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/retail_models.dart';

class ReportService {
  const ReportService(this._api);

  final ApiClient _api;

  Map<String, dynamic> _range(DateTime? from, DateTime? to) => {
    'date_from': from?.toIso8601String(),
    'date_to': to?.toIso8601String(),
  };

  Future<RevenueSummary> summary({DateTime? from, DateTime? to}) async {
    final data = Map<String, dynamic>.from(
      await _api.get('${ApiConstants.reports}/summary', query: _range(from, to))
          as Map,
    );
    return RevenueSummary.fromJson(data);
  }

  Future<List<TopProduct>> topProducts({
    DateTime? from,
    DateTime? to,
    int limit = 5,
  }) async {
    final query = _range(from, to)..['limit'] = limit;
    final data = await _api.get(
      '${ApiConstants.reports}/top-products',
      query: query,
    );
    return (data as List)
        .map(
          (item) => TopProduct.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<DailyRevenue>> dailyRevenue({
    DateTime? from,
    DateTime? to,
  }) async {
    final data = await _api.get(
      '${ApiConstants.reports}/revenue-by-day',
      query: _range(from, to),
    );
    return (data as List)
        .map(
          (item) =>
              DailyRevenue.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
