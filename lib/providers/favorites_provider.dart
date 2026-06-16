import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../services/database_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  Future<void> loadFavorites() async {
    _favorites = await _databaseService.getFavorites();
    notifyListeners();
  }

  bool isFavorite(String id, String type) {
    return _favorites.any((f) => f['id'] == id && f['type'] == type);
  }

  Future<void> toggleFavorite({
    required String id,
    required String type,
    required String name,
    required String image,
  }) async {
    if (isFavorite(id, type)) {
      await _databaseService.removeFavorite(id: id, type: type);
      await FirebaseAnalytics.instance.logEvent(
        name: 'remove_from_favorites',
        parameters: {'item_name': name, 'item_type': type},
      );
    } else {
      await _databaseService.addFavorite(
        id: id,
        type: type,
        name: name,
        image: image,
      );
      await FirebaseAnalytics.instance.logEvent(
        name: 'add_to_favorites',
        parameters: {'item_name': name, 'item_type': type},
      );
    }
    await loadFavorites();
  }
}