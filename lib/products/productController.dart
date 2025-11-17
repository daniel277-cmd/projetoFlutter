// lib/products/productController.dart
import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'productModel.dart';
import 'productRepository.dart';
import 'productRemoteRepository.dart';

class ProductController extends GetxController {
  final localRepo = ProductRepository();
  final remoteRepo = ProductRemoteRepository();

  // Lista de produtos da tela
  final products = <Product>[].obs;

  // Loading e erro
  final isLoading = false.obs;
  final error = RxnString();

  // Campo de pesquisa usado pela UI
  final search = ''.obs;

  // Subscrição ao authStateChanges
  StreamSubscription<User?>? _authSub;

  /// UID pode ser nulo enquanto não houver usuário autenticado
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();

    // 1) Se já existe usuário logado, inicia sync imediatamente
    if (uid != null) {
      // Carrega local e inicia sincronização
      load();
      syncFromFirebase();
    }

    // 2) Observa mudanças de autenticação e inicia a sincronização
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        // Usuário entrou -> sincroniza e carrega dados
        try {
          await sync(); // envia pendências locais primeiro
        } catch (_) {}
        syncFromFirebase(); // configura listener remoto
        await load(); // recarrega lista local
      } else {
        // Usuário saiu -> apenas recarrega local (ou limpa se desejar)
        await load();
      }
    });
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  // ============================================
  // 🔄 SINCRONIZAÇÃO BIDIRECIONAL
  // ============================================
  /// Sincroniza pendências locais para o remoto, e puxa dados do remoto
  Future<void> sync() async {
    // Não tenta sincronizar sem uid
    if (uid == null) return;

    final dirty = await localRepo.getDirty();

    for (final p in dirty) {
      if (p.deleted) {
        // Se marcado como deletado localmente
        if (p.remoteId != null) {
          try {
            await remoteRepo.deleteRemote(p.remoteId!);
          } catch (e) {
            // ignore: continue to next, do not crash entire sync
          }
        }
        await localRepo.hardDelete(p.id!);
      } else {
        // Criar remoto se não existir
        if (p.remoteId == null) {
          try {
            final remoteId = await remoteRepo.createRemote(p, uid!);
            await localRepo.setRemoteId(p.id!, remoteId);
            await localRepo.markSynced(p.id!);
          } catch (e) {
            // se falhar, mantém como dirty
          }
        } else {
          try {
            await remoteRepo.updateRemote(p);
            await localRepo.markSynced(p.id!);
          } catch (e) {
            // mantém dirty para nova tentativa
          }
        }
      }
    }

    // Baixar dados atualizados do remoto e aplicar localmente
    try {
      final cloud = await remoteRepo.fetchAllOnce(uid!);
      for (final r in cloud) {
        await localRepo.upsertFromRemote(r);
      }
    } catch (e) {
      // falha ao buscar do remoto -> silencioso
    }

    await load();
  }

  // Listener em tempo real (stream)
  StreamSubscription? _firebaseListener;
  void syncFromFirebase() {
    // protege contra chamadas múltiplas
    _firebaseListener?.cancel();

    if (uid == null) return;

    _firebaseListener = remoteRepo.fetchStream(uid!).listen((data) async {
      for (final p in data) {
        try {
          await localRepo.upsertFromRemote(p);
        } catch (e) {
          // ignore
        }
      }
      await load();
    }, onError: (e) {
      // opcional: registrar erro
    });
  }

  // ============================================
  // CRUD + PESQUISA
  // ============================================
  /// Carrega do repositório local com filtro opcional
  Future<void> load([String? q]) async {
    try {
      isLoading.value = true;
      final term = q ?? search.value;
      final rows = await localRepo.getAll(q: term);
      products.assignAll(rows);
    } catch (e) {
      error.value = 'Falha ao carregar produtos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cria produto localmente (marca dirty) e dispara sync
  Future<bool> create({
    required String name,
    required double price,
    required int stock,
    String? sku,
    String? description,
  }) async {
    try {
      isLoading.value = true;

      final p = Product(
        name: name,
        price: price,
        stock: stock,
        sku: sku,
        description: description,
        dirty: true,
      );

      await localRepo.create(p);

      // tenta sincronizar (se houver uid)
      await sync();

      return true;
    } catch (e) {
      error.value = 'Falha ao salvar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza produto localmente e marca dirty, depois sync
  Future<bool> updateProduct(Product p) async {
    try {
      isLoading.value = true;

      final updated = p.copyWith(
        updatedAt: DateTime.now(),
        dirty: true,
      );

      await localRepo.update(updated);
      await sync();

      return true;
    } catch (e) {
      error.value = 'Falha ao atualizar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Marca produto como deletado (soft delete) e sincroniza
  Future<void> remove(int id) async {
    try {
      isLoading.value = true;
      final p = await localRepo.getById(id);
      if (p == null) return;

      await localRepo.update(
        p.copyWith(deleted: true, dirty: true),
      );

      await sync();
    } catch (e) {
      error.value = 'Falha ao excluir: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // Utilitários de estoque
  // ============================================
  Future<void> adjustStock({required int id, required int delta}) async {
    try {
      await localRepo.adjustStock(id: id, delta: delta);
      await sync();
    } catch (e) {
      // ignore
    }
  }

  // ============================================
  // Validação
  // ============================================
  String? validate({
    required String name,
    required String priceStr,
    required String stockStr,
  }) {
    if (name.trim().isEmpty) return 'Nome é obrigatório.';
    final price = double.tryParse(priceStr.replaceAll(',', '.'));
    if (price == null || price < 0) return 'Preço inválido.';
    final stock = int.tryParse(stockStr);
    if (stock == null || stock < 0) return 'Estoque inválido.';
    return null;
  }
}
