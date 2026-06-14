import 'package:flutter/material.dart';

import '../models/weapon.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import 'load_status.dart';

class WeaponProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Weapon> _weapons = [];
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';
  bool _isOffline = false;

  List<Weapon> get weapons => _weapons;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;

  Future<void> fetchWeapons({bool forceRefresh = false}) async {
    if (_weapons.isNotEmpty && !forceRefresh) return;

    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final result = await _apiService.getWeapons();
      _weapons = result;
      _isOffline = false;
      _status = LoadStatus.loaded;
      await _databaseService.cacheWeapons(result);
    } catch (e) {
      final cached = await _databaseService.getCachedWeapons();
      if (cached.isNotEmpty) {
        _weapons = cached;
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