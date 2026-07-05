import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository categoryRepository;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == CategoryType.INCOME).toList();
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == CategoryType.EXPENSE).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider(this.categoryRepository);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchCategories({
    int? page,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortDir,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _categories = await categoryRepository.getCategories(
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

  Future<bool> addCategory(String name, CategoryType type, {bool isSystem = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final newCat = await categoryRepository.createCategory(name, type, isSystem: isSystem);
      _categories.insert(0, newCat);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(String id, String name) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedCat = await categoryRepository.updateCategory(id, name);
      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        _categories[index] = updatedCat;
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

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await categoryRepository.deleteCategory(id);
      _categories.removeWhere((c) => c.id == id);
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
