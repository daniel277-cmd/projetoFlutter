import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:teladelogin/dataBase/datasbaseHelper.dart';
import 'package:teladelogin/models/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  static AuthRepository get instance => AuthRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get firebaseUser => _auth.currentUser;

  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setInitScreen(User? user) {
    // Implement your logic here, e.g., navigation or state update
  }
}

class UserRepository {
  final _col = FirebaseFirestore.instance.collection('users');
  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ---------- FIRESTORE ----------
  Future<void> upsertFirestore(UserModel u) async {
    try {
      await _col.doc(u.firebaseUid).set(u.toFirestore(), SetOptions(merge: true));
      print('✅ Dados salvos no Firestore');
    } catch (e) {
      print('⚠️ Erro ao salvar no Firestore (funcionando offline): $e');
      // Não falha - continua funcionando offline
    }
  }

  Future<UserModel?> getFromFirestore(String uid) async {
    try {
      final snap = await _col.doc(uid).get(const GetOptions(source: Source.serverAndCache));
      if (!snap.exists || snap.data() == null) return null;
      return UserModel.fromFirestore(uid, snap.data()!);
    } catch (e) {
      print('⚠️ Erro ao buscar Firestore (usando dados locais): $e');
      return null; // Fallback para dados locais
    }
  }

  // ---------- SQLITE ----------
  Future<UserModel?> findByFirebaseUid(String uid) async {
    if (kIsWeb) {
      print('⚠️ SQLite não disponível no Web - ignorando busca local');  
      return null;
    }
    final db = await _db;
    final res = await db.query('users', where: 'firebaseUid = ?', whereArgs: [uid], limit: 1);
    if (res.isEmpty) return null;
    return UserModel.fromMap(res.first);
  }

  Future<UserModel> upsertLocal(UserModel u) async {
    if (kIsWeb) {
      print('⚠️ SQLite não disponível no Web - retornando dados sem ID local');
      return u; // Retorna sem salvar localmente no Web
    }
    final db = await _db;
    final existing = await db.query('users', where: 'firebaseUid = ?', whereArgs: [u.firebaseUid], limit: 1);
    if (existing.isEmpty) {
      final id = await db.insert('users', u.toMap());
      return u.copyWith(id: id);
    } else {
      await db.update('users', u.toMap(), where: 'firebaseUid = ?', whereArgs: [u.firebaseUid]);
      return u.copyWith(id: existing.first['id'] as int?);
    }
  }

  // ---------- SYNC ----------
  /// Garante o usuário em ambos os lados e retorna o modelo consolidado local.
  Future<UserModel> syncUser(UserModel base) async {
    if (kIsWeb) {
      print('🌐 Modo Web - usando apenas Firestore');
      await upsertFirestore(base);
      return base;
    }
    
    // Prioridade: Firestore como fonte de verdade para perfil/role/classId
    final remote = await getFromFirestore(base.firebaseUid);
    final merged = (remote == null)
        ? base
        : base.copyWith(
            name: remote.name,
            email: remote.email,
            avatarUrl: remote.avatarUrl,
            isGoogleUser: remote.isGoogleUser,
            role: remote.role,
            classId: remote.classId,
          );

    await upsertFirestore(merged);        // garante no remoto (merge)
    final local = await upsertLocal(merged); // garante no local
    return local;
  }
}
