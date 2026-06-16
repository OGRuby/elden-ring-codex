import 'package:flutter/material.dart';

import '../models/boss.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'load_status.dart';

class BossProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Boss> _allBosses = [];
  List<Boss> _bosses = [];
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  String _searchQuery = '';

  List<Boss> get bosses => _bosses;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;

  Future<void> fetchBosses({bool forceRefresh = false}) async {
    if (_allBosses.isNotEmpty && !forceRefresh) return;

    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _apiService.getBosses();
      _allBosses = result;
      _isOffline = false;
      _status = LoadStatus.loaded;
      await _databaseService.cacheBosses(result);
    } catch (e) {
      final cached = await _databaseService.getCachedBosses();
      if (cached.isNotEmpty) {
        _allBosses = cached;
        _isOffline = true;
        _status = LoadStatus.loaded;
        _errorMessage = e.toString();
      } else {
        _status = LoadStatus.error;
        _errorMessage = e.toString();
      }
    }

    _applySearch();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _bosses = List.from(_allBosses);
    } else {
      final q = _searchQuery.toLowerCase();
      _bosses = _allBosses
          .where((b) => b.name.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<void> clearCache() async {
    final db = await _databaseService.database;
    await db.delete('bosses');
    _allBosses = [];
    _bosses = [];
    _status = LoadStatus.initial;
    notifyListeners();
  }
}