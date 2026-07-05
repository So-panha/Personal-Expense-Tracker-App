import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';

class GoalRepository {
  final ApiClient apiClient;

  GoalRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<GoalModel> createGoal({
    required String name,
    required int targetAmount,
    required String deadline,
  }) async {
    try {
      final response = await apiClient.dio.post('/goals', data: {
        'name': name,
        'targetAmount': targetAmount,
        'deadline': deadline,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return GoalModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<GoalModel>> getGoals({
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

      final response = await apiClient.dio.get('/goals', queryParameters: queryParams);
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      
      if (data is List) {
        return data
            .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((json) => GoalModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<GoalModel> addGoalProgress(String id, int amount) async {
    try {
      final response = await apiClient.dio.put('/goals/$id/progress', data: {
        'amount': amount,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return GoalModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<GoalModel> updateGoal({
    required String id,
    required String name,
    required int targetAmount,
    required String deadline,
  }) async {
    try {
      final response = await apiClient.dio.put('/goals/$id', data: {
        'name': name,
        'targetAmount': targetAmount,
        'deadline': deadline,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return GoalModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await apiClient.dio.delete('/goals/$id');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
