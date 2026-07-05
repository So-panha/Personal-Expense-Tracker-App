import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';

class BudgetRepository {
  final ApiClient apiClient;

  BudgetRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<BudgetModel> createBudget({
    required String categoryId,
    required int limitAmount,
    required int month,
    required int year,
  }) async {
    try {
      final response = await apiClient.dio.post('/budgets', data: {
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'month': month,
        'year': year,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return BudgetModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<BudgetModel>> getBudgets({
    int? page,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortDir,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['_page'] = page;
      if (perPage != null) queryParams['_per_page'] = perPage;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (sortBy != null && sortBy.isNotEmpty) queryParams['sortBy'] = sortBy;
      if (sortDir != null && sortDir.isNotEmpty) queryParams['sortDir'] = sortDir;

      final response = await apiClient.dio.get('/budgets', queryParameters: queryParams);
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      
      if (data is List) {
        return data
            .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<BudgetModel> getBudgetById(String id) async {
    try {
      final response = await apiClient.dio.get('/budgets/$id');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return BudgetModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<BudgetModel> updateBudget({
    required String id,
    required String categoryId,
    required int limitAmount,
    required int month,
    required int year,
  }) async {
    try {
      final response = await apiClient.dio.put('/budgets/$id', data: {
        'categoryId': categoryId,
        'limitAmount': limitAmount,
        'month': month,
        'year': year,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return BudgetModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await apiClient.dio.delete('/budgets/$id');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
