// lib/products/productRepository.dart
import 'package:sqflite/sqflite.dart';
import 'package:teladelogin/database/datasbaseHelper.dart';
import 'productModel.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ======= CRUD LOCAL (SQLite) =======

  Future<int> create(Product product) async {
    final db = await _dbHelper.database;
    final data = product.copyWith(
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      dirty: true,
      deleted: false,
    ).toMap();
    return await db.insert(
      'products',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<Product>> getAll({String? q}) async {
    final db = await _dbHelper.database;
    final whereClauses = <String>['deleted = 0'];
    final whereArgs = <Object?>[];

    if ((q ?? '').trim().isNotEmpty) {
      whereClauses.add('(name LIKE ? OR sku LIKE ?)');
      whereArgs.addAll(['%$q%', '%$q%']);
    }

    final rows = await db.query(
      'products',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<Product?> getByRemoteId(String remoteId) async {
    final db = await _dbHelper.database;
    final rows =
        await db.query('products', where: 'remoteId = ?', whereArgs: [remoteId]);
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> update(Product product) async {
    if (product.id == null) throw ArgumentError('Produto sem ID para update.');
    final db = await _dbHelper.database;
    final updated = product.copyWith(
      updatedAt: DateTime.now(),
      dirty: true,
    );
    return await db.update(
      'products',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Soft delete: marca deleted = 1 e dirty = 1
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      'products',
      {'deleted': 1, 'dirty': 1, 'updatedAt': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ======= HELPERS DE SINCRONIZAÇÃO =======

  /// Insere ou atualiza vindo do Firestore (upsert)
  Future<void> upsertFromRemote(Product remote) async {
    final db = await _dbHelper.database;
    // Se o produto remoto já existir localmente (remoteId), substitui.
    final existing = await getByRemoteId(remote.remoteId!);
    final data = remote.copyWith(dirty: false).toMap();
    if (existing == null) {
      await db.insert('products', data,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.update('products', data,
          where: 'id = ?', whereArgs: [existing.id]);
    }
  }

  /// Retorna produtos marcados como sujos (dirty = 1)
  Future<List<Product>> getDirty() async {
    final db = await _dbHelper.database;
    final rows = await db.query('products', where: 'dirty = 1');
    return rows.map(Product.fromMap).toList();
  }

  /// Marca um registro local como sincronizado
  Future<void> markSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update('products', {'dirty': 0}, where: 'id = ?', whereArgs: [id]);
  }

  /// Define remoteId e remove flag de dirty (após criar remoto)
  Future<void> setRemoteId(int id, String remoteId) async {
    final db = await _dbHelper.database;
    await db.update('products', {'remoteId': remoteId, 'dirty': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Remove permanentemente (hard delete) — usado quando remoção confirmada no remoto
  Future<void> hardDelete(int id) async {
    final db = await _dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  /// Ajusta estoque (delta pode ser negativo)
  Future<int> adjustStock({required int id, required int delta}) async {
    final db = await _dbHelper.database;
    final updatedAt = DateTime.now().millisecondsSinceEpoch;
    return await db.rawUpdate('''
      UPDATE products
      SET stock = stock + ?, updatedAt = ?, dirty = 1
      WHERE id = ?
    ''', [delta, updatedAt, id]);
  }
}
