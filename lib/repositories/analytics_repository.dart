import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';

class AnalyticsRepository {
  final ApiClient apiClient;

  AnalyticsRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<DashboardSummaryModel> getDashboardSummary() async {
    try {
      final response = await apiClient.dio.get('/analytics/dashboard-summary');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return DashboardSummaryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<CategoryBreakdownModel>> getCategoryBreakdown(int month, int year) async {
    try {
      final response = await apiClient.dio.get(
        '/analytics/category-breakdown',
        queryParameters: {'month': month, 'year': year},
      );
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is List) {
        return data
            .map((json) => CategoryBreakdownModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<TrendPointModel>> getTrends() async {
    try {
      final response = await apiClient.dio.get('/analytics/trends');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      if (data is List) {
        return data
            .map((json) => TrendPointModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<String> exportCsv() async {
    try {
      final response = await apiClient.dio.get(
        '/analytics/export',
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Content-Type': 'text/csv'},
        ),
      );
      return response.data as String? ?? '';
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
