import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TransactionProvider(this.transactionRepository);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchTransactions({
    int? page,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortDir,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _transactions = await transactionRepository.getTransactions(
        page: page,
        perPage: perPage,
        search: search,
        sortBy: sortBy,
        sortDir: sortDir,
      );
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTransaction({
    required int amount,
    required String transactionDate,
    required String notes,
    required String categoryId,
    String? filePath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newTx = await transactionRepository.createTransaction(
        amount: amount,
        transactionDate: transactionDate,
        notes: notes,
        categoryId: categoryId,
        filePath: filePath,
      );
      _transactions.insert(0, newTx);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTransaction({
    required String id,
    required int amount,
    required String transactionDate,
    required String notes,
    required String categoryId,
    String? filePath,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedTx = await transactionRepository.updateTransaction(
        id: id,
        amount: amount,
        transactionDate: transactionDate,
        notes: notes,
        categoryId: categoryId,
        filePath: filePath,
      );
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        _transactions[index] = updatedTx;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await transactionRepository.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
