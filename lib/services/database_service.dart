import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/boss.dart';
import '../models/weapon.dart';

/// Serwis odpowiedzialny za lokalną bazę danych SQLite.
///
/// Pełni dwie funkcje:
/// 1. Cache danych z API (bossowie, broń) — pozwala korzystać
///    z aplikacji w trybie offline (ostatnio pobrane dane).
/// 2. Przechowywanie listy ulubionych elementów użytkownika.
///
/// Zaimplementowany jako singleton, aby cała aplikacja korzystała
/// z jednego połączenia z bazą.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;

  /// Zwraca otwartą instancję bazy danych, tworząc ją przy pierwszym użyciu.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'elden_ring_codex.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE bosses (
            id TEXT PRIMARY KEY,
            name TEXT,
            image TEXT,
            description TEXT,
            location TEXT,
            drops TEXT,
            healthPoints TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE weapons (
            id TEXT PRIMARY KEY,
            name TEXT,
            image TEXT,
            description TEXT,
            category TEXT,
            weight REAL,
            attack TEXT,
            defence TEXT,
            requiredAttributes TEXT,
            scalesWith TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE favorites (
            id TEXT NOT NULL,
            type TEXT NOT NULL,
            name TEXT,
            image TEXT,
            PRIMARY KEY (id, type)
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------
  // BOSSOWIE — cache
  // ---------------------------------------------------------------------

  /// Zapisuje listę bossów do lokalnej bazy (nadpisując istniejące wpisy
  /// o tym samym id). Używane jako cache po pobraniu danych z API.
  Future<void> cacheBosses(List<Boss> bosses) async {
    final db = await database;
    final batch = db.batch();
    for (final boss in bosses) {
      batch.insert(
        'bosses',
        boss.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Zwraca listę bossów zapisanych lokalnie (np. gdy brak internetu).
  Future<List<Boss>> getCachedBosses() async {
    final db = await database;
    final maps = await db.query('bosses', orderBy: 'name ASC');
    return maps.map((m) => Boss.fromMap(m)).toList();
  }

  /// Zwraca pojedynczego bossa z cache po jego id (lub null).
  Future<Boss?> getCachedBoss(String id) async {
    final db = await database;
    final maps = await db.query('bosses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Boss.fromMap(maps.first);
  }

  // ---------------------------------------------------------------------
  // BROŃ — cache
  // ---------------------------------------------------------------------

  /// Zapisuje listę broni do lokalnej bazy (nadpisując istniejące wpisy).
  Future<void> cacheWeapons(List<Weapon> weapons) async {
    final db = await database;
    final batch = db.batch();
    for (final weapon in weapons) {
      batch.insert(
        'weapons',
        weapon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Zwraca listę broni zapisanych lokalnie (np. gdy brak internetu).
  Future<List<Weapon>> getCachedWeapons() async {
    final db = await database;
    final maps = await db.query('weapons', orderBy: 'name ASC');
    return maps.map((m) => Weapon.fromMap(m)).toList();
  }

  /// Zwraca pojedynczą broń z cache po jej id (lub null).
  Future<Weapon?> getCachedWeapon(String id) async {
    final db = await database;
    final maps = await db.query('weapons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Weapon.fromMap(maps.first);
  }

  // ---------------------------------------------------------------------
  // ULUBIONE
  // ---------------------------------------------------------------------

  /// Dodaje element do ulubionych. [type] to 'boss' lub 'weapon'.
  Future<void> addFavorite({
    required String id,
    required String type,
    required String name,
    required String image,
  }) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'id': id, 'type': type, 'name': name, 'image': image},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Usuwa element z ulubionych.
  Future<void> removeFavorite({required String id, required String type}) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
    );
  }

  /// Sprawdza, czy dany element jest w ulubionych.
  Future<bool> isFavorite({required String id, required String type}) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
    );
    return result.isNotEmpty;
  }

  /// Zwraca wszystkie ulubione elementy (zarówno bossów, jak i broń).
  /// Każdy wpis to mapa z polami: id, type, name, image.
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query('favorites', orderBy: 'name ASC');
  }
}