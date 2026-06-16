import 'package:flutter/material.dart';

import '../models/weapon.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'load_status.dart';

class WeaponProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Weapon> _allWeapons = [];
  List<Weapon> _weapons = [];
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;
  String _searchQuery = '';

  List<Weapon> get weapons => _weapons;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String get searchQuery => _searchQuery;

  Future<void> fetchWeapons({bool forceRefresh = false}) async {
    if (_allWeapons.isNotEmpty && !forceRefresh) return;

    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _apiService.getWeapons();
      _allWeapons = result;
      _isOffline = false;
      _status = LoadStatus.loaded;
      await _databaseService.cacheWeapons(result);
    } catch (e) {
      final cached = await _databaseService.getCachedWeapons();
      if (cached.isNotEmpty) {
        _allWeapons = cached;
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
      _weapons = List.from(_allWeapons);
    } else {
      final q = _searchQuery.toLowerCase();
      _weapons = _allWeapons
          .where((w) => w.name.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<void> clearCache() async {
    final db = await _databaseService.database;
    await db.delete('weapons');
    _allWeapons = [];
    _weapons = [];
    _status = LoadStatus.initial;
    notifyListeners();
  }
}