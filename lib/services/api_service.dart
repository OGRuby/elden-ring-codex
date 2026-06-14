import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/boss.dart';
import '../../models/weapon.dart';

/// Wyjątek rzucany, gdy zapytanie do API się nie powiedzie.
/// Zawiera czytelny komunikat, który można pokazać użytkownikowi.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Serwis odpowiedzialny za komunikację z Elden Ring API
/// (https://eldenring.fanapis.com).
///
/// Każda metoda wykonuje jedno zapytanie GET i mapuje odpowiedź JSON
/// na odpowiednie modele danych. W przypadku błędu (brak internetu,
/// błąd serwera, timeout) rzuca [ApiException] z czytelnym komunikatem.
class ApiService {
  static const String _baseUrl = 'https://eldenring.fanapis.com/api';
  static const Duration _timeout = Duration(seconds: 10);

  /// Pobiera listę bossów. Można podać [limit] (domyślnie 100, aby
  /// pobrać możliwie pełną listę) oraz opcjonalną nazwę do wyszukania.
  Future<List<Boss>> getBosses({int limit = 100, String? name}) async {
    final uri = Uri.parse('$_baseUrl/bosses').replace(queryParameters: {
      'limit': limit.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
    });

    final data = await _getJson(uri);
    final list = (data['data'] as List<dynamic>?) ?? [];
    return list.map((e) => Boss.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Pobiera szczegóły jednego bossa po jego [id].
  Future<Boss> getBossDetails(String id) async {
    final uri = Uri.parse('$_baseUrl/bosses/$id');
    final data = await _getJson(uri);

    // API dla pojedynczego elementu zwraca obiekt w polu "data"
    // (a nie listę), dlatego obsługujemy obie możliwości.
    final dynamic body = data['data'];
    if (body is Map<String, dynamic>) {
      return Boss.fromJson(body);
    } else if (body is List && body.isNotEmpty) {
      return Boss.fromJson(body.first as Map<String, dynamic>);
    }
    throw ApiException('Nie znaleziono bossa o podanym identyfikatorze.');
  }

  /// Pobiera listę broni. Można podać [limit] oraz opcjonalną nazwę.
  Future<List<Weapon>> getWeapons({int limit = 100, String? name}) async {
    final uri = Uri.parse('$_baseUrl/weapons').replace(queryParameters: {
      'limit': limit.toString(),
      if (name != null && name.isNotEmpty) 'name': name,
    });

    final data = await _getJson(uri);
    final list = (data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Weapon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Pobiera szczegóły jednej broni po jej [id].
  Future<Weapon> getWeaponDetails(String id) async {
    final uri = Uri.parse('$_baseUrl/weapons/$id');
    final data = await _getJson(uri);

    final dynamic body = data['data'];
    if (body is Map<String, dynamic>) {
      return Weapon.fromJson(body);
    } else if (body is List && body.isNotEmpty) {
      return Weapon.fromJson(body.first as Map<String, dynamic>);
    }
    throw ApiException('Nie znaleziono broni o podanym identyfikatorze.');
  }

  /// Wykonuje zapytanie GET pod podany adres i zwraca zdekodowany JSON.
  /// Tłumaczy typowe błędy sieciowe na czytelne komunikaty w [ApiException].
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw ApiException('Nie znaleziono żądanych danych (404).');
      } else {
        throw ApiException(
          'Serwer odpowiedział błędem (kod ${response.statusCode}). '
              'Spróbuj ponownie później.',
        );
      }
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw ApiException(
        'Brak połączenia z internetem. Sprawdź swoje połączenie '
            'i spróbuj ponownie.',
      );
    } on FormatException {
      throw ApiException('Otrzymano nieprawidłową odpowiedź z serwera.');
    } catch (_) {
      throw ApiException(
        'Wystąpił nieoczekiwany błąd. Sprawdź połączenie z internetem '
            'i spróbuj ponownie.',
      );
    }
  }
}