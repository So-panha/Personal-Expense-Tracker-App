import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/goal_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository goalRepository;

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GoalProvider(this.goalRepository);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchGoals({
    int? page,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortDir,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      _goals = await goalRepository.getGoals(
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

  Future<bool> createGoal({
    required String name,
    required int targetAmount,
    required String deadline,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final newGoal = await goalRepository.createGoal(
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
      );
      _goals.insert(0, newGoal);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addGoalProgress(String id, int amount) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedGoal = await goalRepository.addGoalProgress(id, amount);
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
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

  Future<bool> updateGoal({
    required String id,
    required String name,
    required int targetAmount,
    required String deadline,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final updatedGoal = await goalRepository.updateGoal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        deadline: deadline,
      );
      final index = _goals.indexWhere((g) => g.id == id);
      if (index != -1) {
        _goals[index] = updatedGoal;
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

  Future<bool> deleteGoal(String id) async {
    _setLoading(true);
    _setError(null);
    try {
      await goalRepository.deleteGoal(id);
      _goals.removeWhere((g) => g.id == id);
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
