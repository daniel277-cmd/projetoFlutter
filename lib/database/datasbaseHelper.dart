import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    // ✔ SQLite Web via FFI WEB
    if (kIsWeb) {
      final db = await databaseFactory.openDatabase(
        'corretor_prova_web.db',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        ),
      );
      await _ensureProductsTable(db);
      return db;
    }

    // ✔ Mobile (Android/iOS)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'corretor_prova.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _ensureProductsTable(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firebaseUid TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        avatarUrl TEXT,
        isGoogleUser INTEGER DEFAULT 0,
        role TEXT NOT NULL DEFAULT 'student',
        classId TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute("ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'student'");
      await db.execute("ALTER TABLE users ADD COLUMN classId TEXT");
    }
  }

  Future<void> _ensureProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT UNIQUE,
        name TEXT NOT NULL,
        sku TEXT UNIQUE,
        price REAL NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        dirty INTEGER NOT NULL DEFAULT 0,
        deleted INTEGER NOT NULL DEFAULT 0
      );
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
