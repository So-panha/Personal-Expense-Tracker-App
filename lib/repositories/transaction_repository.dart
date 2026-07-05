import 'dart:io';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';
import 'package:http_parser/http_parser.dart';

class TransactionRepository {
  final ApiClient apiClient;

  TransactionRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<TransactionModel> createTransaction({
    required int amount,
    required String transactionDate,
    required String notes,
    required String categoryId,
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'amount': amount.toString(),
        'transactionDate': transactionDate,
        'notes': notes,
        'categoryId': categoryId,
      };

      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        final filename = file.path.split(Platform.isWindows ? '\\' : '/').last;
        String ext = filename.split('.').last.toLowerCase();
        MediaType mediaType = MediaType('image', ext == 'png' ? 'png' : 'jpeg');

        dataMap['file'] = await MultipartFile.fromFile(
          file.path,
          filename: filename,
          contentType: mediaType,
        );
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.dio.post(
        '/transactions',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return TransactionModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<TransactionModel>> getTransactions({
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

      final response = await apiClient.dio.get('/transactions', queryParameters: queryParams);
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'];
      
      if (data is List) {
        return data
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (data is Map) {
        final items = data['items'];
        if (items is List) {
          return items
              .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await apiClient.dio.get('/transactions/$id');
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return TransactionModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<TransactionModel> updateTransaction({
    required String id,
    required int amount,
    required String transactionDate,
    required String notes,
    required String categoryId,
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'amount': amount.toString(),
        'transactionDate': transactionDate,
        'notes': notes,
        'categoryId': categoryId,
      };

      if (filePath != null && filePath.isNotEmpty) {
        // Can be a local path or a remote URL. If it's a local file path, upload it.
        if (FileSystemEntity.typeSync(filePath) != FileSystemEntityType.notFound) {
          final file = File(filePath);
          final filename = file.path.split(Platform.isWindows ? '\\' : '/').last;
          String ext = filename.split('.').last.toLowerCase();
          MediaType mediaType = MediaType('image', ext == 'png' ? 'png' : 'jpeg');

          dataMap['file'] = await MultipartFile.fromFile(
            file.path,
            filename: filename,
            contentType: mediaType,
          );
        }
      }

      final formData = FormData.fromMap(dataMap);

      final response = await apiClient.dio.put(
        '/transactions/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final envelope = response.data as Map<String, dynamic>;
      final data = envelope['data'] as Map<String, dynamic>;
      return TransactionModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await apiClient.dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
