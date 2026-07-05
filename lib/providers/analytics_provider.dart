import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository analyticsRepository;

  DashboardSummaryModel? _summary;
  List<CategoryBreakdownModel> _breakdown = [];
  List<TrendPointModel> _trends = [];
  bool _isLoading = false;
  String? _error;

  DashboardSummaryModel? get summary => _summary;
  List<CategoryBreakdownModel> get breakdown => _breakdown;
  List<TrendPointModel> get trends => _trends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnalyticsProvider(this.analyticsRepository);

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> fetchDashboardSummary() async {
    _setLoading(true);
    _setError(null);
    try {
      _summary = await analyticsRepository.getDashboardSummary();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategoryBreakdown(int month, int year) async {
    _setLoading(true);
    _setError(null);
    try {
      _breakdown = await analyticsRepository.getCategoryBreakdown(month, year);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTrends() async {
    _setLoading(true);
    _setError(null);
    try {
      _trends = await analyticsRepository.getTrends();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> exportCsv() async {
    _setLoading(true);
    _setError(null);
    try {
      return await analyticsRepository.exportCsv();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return null;
    } finally {
      _setLoading(false);
    }
  }
}
