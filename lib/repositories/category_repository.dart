import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';

class CategoryRepository {
  final ApiClient apiClient;

  CategoryRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<CategoryModel> createCategory(String name, CategoryType type, {bool isSystem = false}) async {
    try {
      final response = await apiClient.dio.post('/categories', data: {
        'name': name,
        'type': type == CategoryType.INCOME ? 'INCOME' : 'EXPENSE',
        'isSystem': isSystem,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<CategoryModel>> getCategories({
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

      final response = await apiClient.dio.get('/categories', queryParameters: queryParams);
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      
      if (data is List) {
        return data
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final response = await apiClient.dio.get('/categories/$id');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<CategoryModel> updateCategory(String id, String name) async {
    try {
      final response = await apiClient.dio.put('/categories/$id', data: {
        'name': name,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await apiClient.dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
