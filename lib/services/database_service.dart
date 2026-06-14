import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/boss.dart';
import '../models/weapon.dart';


class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;


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

  Future<List<Boss>> getCachedBosses() async {
    final db = await database;
    final maps = await db.query('bosses', orderBy: 'name ASC');
    return maps.map((m) => Boss.fromMap(m)).toList();
  }

  Future<Boss?> getCachedBoss(String id) async {
    final db = await database;
    final maps = await db.query('bosses', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Boss.fromMap(maps.first);
  }


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


  Future<List<Weapon>> getCachedWeapons() async {
    final db = await database;
    final maps = await db.query('weapons', orderBy: 'name ASC');
    return maps.map((m) => Weapon.fromMap(m)).toList();
  }


  Future<Weapon?> getCachedWeapon(String id) async {
    final db = await database;
    final maps = await db.query('weapons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Weapon.fromMap(maps.first);
  }

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


  Future<void> removeFavorite({required String id, required String type}) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
    );
  }


  Future<bool> isFavorite({required String id, required String type}) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'id = ? AND type = ?',
      whereArgs: [id, type],
    );
    return result.isNotEmpty;
  }


  Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await database;
    return db.query('favorites', orderBy: 'name ASC');
  }
}