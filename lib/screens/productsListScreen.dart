import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/products/productController.dart';
import 'package:teladelogin/products/productModel.dart';
import 'package:teladelogin/screens/productFormScreen.dart';

class ProductsListScreen extends StatelessWidget {
  ProductsListScreen({super.key});

 final ProductController c = Get.find<ProductController>(); 
  final search = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Produtos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Início',
            onPressed: () => Get.offAllNamed('/home'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => c.load(),
          ),
        ],
      ),

      body: Column(
        children: [
          // Campo de busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nome ou SKU...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => search.value = v,
            ),
          ),

          // Lista de produtos com filtro
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (c.error.value != null) {
                return Center(child: Text(c.error.value!));
              }

              final filtro = search.value.toLowerCase();
              final lista = c.products.where((p) {
                return p.name.toLowerCase().contains(filtro) ||
                    (p.sku ?? '').toLowerCase().contains(filtro);
              }).toList();

              if (lista.isEmpty) {
                return const Center(child: Text('Nenhum produto encontrado.'));
              }

              return ListView.separated(
                itemCount: lista.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final Product p = lista[i];
                  return ListTile(
                    title: Text('${p.name}  (Estoque: ${p.stock})'),
                    subtitle: Text(
                      'SKU: ${p.sku ?? '-'}  •  R\$ ${p.price.toStringAsFixed(2)}'
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductFormScreen(product: p),
                              ),
                            );

                            if (updated == true) c.load();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Excluir',
                          onPressed: () => _confirmDelete(context, c, p),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.toNamed('/product-form');
          c.load(); // recarrega ao voltar
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        tooltip: 'Adicionar Produto',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ======= Confirmação de exclusão =======
  void _confirmDelete(
    BuildContext context,
    ProductController c,
    Product p,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Confirmar exclusão de "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok == true && p.id != null) {
      await c.remove(p.id!);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Produto excluído.')));
    }
  }
}
