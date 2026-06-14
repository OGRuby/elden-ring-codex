import 'package:flutter/material.dart';

import '../models/boss.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'load_status.dart';

class BossProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Boss> _bosses = [];
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;

  List<Boss> get bosses => _bosses;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  Future<void> fetchBosses({bool forceRefresh = false}) async {
    if (_bosses.isNotEmpty && !forceRefresh) return;

    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _apiService.getBosses();
      _bosses = result;
      _isOffline = false;
      _status = LoadStatus.loaded;
      await _databaseService.cacheBosses(result);
    } catch (e) {
      final cached = await _databaseService.getCachedBosses();
      if (cached.isNotEmpty) {
        _bosses = cached;
        _isOffline = true;
        _status = LoadStatus.loaded;
        _errorMessage = e.toString();
      } else {
        _status = LoadStatus.error;
        _errorMessage = e.toString();
      }
    }

    notifyListeners();
  }
}