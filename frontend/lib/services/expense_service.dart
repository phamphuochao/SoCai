import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/date_utils.dart';
import '../models/retail_models.dart';

class ExpenseService {
  const ExpenseService(this._api);

  final ApiClient _api;

  Future<List<Expense>> expenses({
    DateTime? dateFrom,
    DateTime? dateTo,
    int? offset,
    int? limit,
  }) async {
    final data = await _api.get(
      ApiConstants.expenses,
      query: {
        'date_from': dateFrom == null ? null : AppDateUtils.query(dateFrom),
        'date_to': dateTo == null ? null : AppDateUtils.query(dateTo),
        'offset': offset,
        'limit': limit,
      },
    );
    return (data as List)
        .map((item) => Expense.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Expense> create({
    required String type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    final data = Map<String, dynamic>.from(
      await _api.post(
            ApiConstants.expenses,
            data: {
              'expense_type': type,
              'amount': amount,
              'expense_date': AppDateUtils.query(date),
              'note': note,
            },
          )
          as Map,
    );
    return Expense.fromJson(data);
  }
}
