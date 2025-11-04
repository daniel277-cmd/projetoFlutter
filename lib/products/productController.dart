
import 'package:get/get.dart';
import 'package:teladelogin/products/productModel.dart';
import 'package:teladelogin/products/productRepository.dart';

class ProductController extends GetxController {
  final _repo = ProductRepository();

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final error = RxnString();
  final query = ''.obs;

  Future<void> load([String? q]) async {
    try {
      isLoading.value = true;
      error.value = null;
      final list = await _repo.getAll(q: (q ?? query.value));
      products.assignAll(list);
    } catch (e) {
      error.value = 'Falha ao carregar: $e';
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<bool> create({
    required String name,
    String? sku,
    required double price,
    required int stock,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      final p = Product(
        name: name,
        sku: sku,
        price: price,
        stock: stock,
        description: description,
      );
      await _repo.create(p);
      await load();
      return true;
    } catch (e) {
      error.value = 'Falha ao salvar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      isLoading.value = true;
      await _repo.update(product);
      await load();
      return true;
    } catch (e) {
      error.value = 'Falha ao atualizar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> remove(int id) async {
    try {
      isLoading.value = true;
      await _repo.delete(id);
      await load();
    } catch (e) {
      error.value = 'Falha ao excluir: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
