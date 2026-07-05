import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository budgetRepository;

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BudgetProvider(this.budgetRepository);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchBudgets({
    int? page,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortDir,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _budgets = await budgetRepository.getBudgets(
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

  Future<bool> createBudget({
    required String categoryId,
    required int limitAmount,
    required int month,
    required int year,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newBudget = await budgetRepository.createBudget(
        categoryId: categoryId,
        limitAmount: limitAmount,
        month: month,
        year: year,
      );
      _budgets.insert(0, newBudget);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBudget({
    required String id,
    required String categoryId,
    required int limitAmount,
    required int month,
    required int year,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedBudget = await budgetRepository.updateBudget(
        id: id,
        categoryId: categoryId,
        limitAmount: limitAmount,
        month: month,
        year: year,
      );
      final index = _budgets.indexWhere((b) => b.id == id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
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

  Future<bool> deleteBudget(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await budgetRepository.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
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
