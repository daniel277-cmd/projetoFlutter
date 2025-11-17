// // 🚀 EXEMPLOS PRÁTICOS DE USO DO CRUD DE PRODUTOS
// // Este arquivo mostra como usar o sistema já implementado

// import 'package:get/get.dart';
// import 'package:teladelogin/products/productController.dart';
// import 'package:teladelogin/products/productModel.dart';
// import 'package:teladelogin/products/productRemoteRepository.dart';
// import 'package:teladelogin/products/productRepository.dart';
// import 'package:flutter/material.dart';

// class ProductCrudExamples {
  
//   // ===== USANDO O CONTROLLER (RECOMENDADO) =====
  
//   static void exemploComController() async {
//     final controller = Get.put(ProductController());
    
//     // 1. CRIAR PRODUTO
//     await controller.create(
//       name: 'iPhone 15 Pro',
//       sku: 'IP15P-128GB',
//       price: 8999.99,
//       stock: 10,
//       description: 'iPhone 15 Pro 128GB Titânio Natural',
//     );
    
//     // 2. BUSCAR PRODUTOS
//     await controller.load(); // Carrega todos
//     await controller.load('iPhone'); // Busca por nome/SKU
    
//     // 3. ATUALIZAR PRODUTO
//     final produto = controller.products.first;
//     final produtoAtualizado = produto.copyWith(
//       price: 7999.99, // Novo preço
//       stock: 15, // Novo estoque
//     );
//     await controller.updateProduct(produtoAtualizado);
    
//     // 4. EXCLUIR PRODUTO
//     await controller.remove(produto.id!);
    
//     // 5. ACESSAR DADOS REATIVO
//     controller.products.listen((produtos) {
//       print('Total de produtos: ${produtos.length}');
//     });
//   }
  
//   // ===== USANDO REPOSITORY DIRETAMENTE =====
  
//   static void exemploComRepository() async {
//     final repo = ProductRepository();
    
//     // 1. CRIAR
//     final novoProduto = Product(
//       name: 'MacBook Air M2',
//       sku: 'MBA-M2-256',
//       price: 12999.99,
//       stock: 5,
//       description: 'MacBook Air M2 256GB Meia-noite',
//     );
//     final id = await repo.create(novoProduto);
//     print('Produto criado com ID: $id');
    
//     // 2. BUSCAR
//     final todos = await repo.getAll();
//     final porNome = await repo.getAll(q: 'MacBook');
//     final porId = await repo.getById(id);
    
//     // 3. ATUALIZAR
//     if (porId != null) {
//       final atualizado = porId.copyWith(price: 11999.99);
//       await repo.update(atualizado);
//     }
    
//     // 4. EXCLUIR (soft delete)
//     await repo.delete(id);
    
//     // 5. AJUSTAR ESTOQUE
//     await repo.adjustStock(id: id, delta: -2); // Remove 2 unidades
//     await repo.adjustStock(id: id, delta: 10); // Adiciona 10 unidades
//   }
  
//   // ===== SINCRONIZAÇÃO COM FIRESTORE =====
  
//   static void exemploSincronizacao() async {
//     final localRepo = ProductRepository();
//     final remoteRepo = ProductRemoteRepository();
    
//     // 1. CRIAR PRODUTO LOCALMENTE
//     final produto = Product(
//       name: 'AirPods Pro 2',
//       price: 2799.99,
//       stock: 20,
//     );
//     await localRepo.create(produto); // Fica marcado como "dirty"
    
//     // 2. SINCRONIZAR COM FIRESTORE
//     final produtosSujos = await localRepo.getDirty();
//     for (final p in produtosSujos) {
//       if (p.deleted) {
//         if (p.remoteId != null) {
//           await remoteRepo.deleteRemote(p.remoteId!);
//         }
//         await localRepo.hardDelete(p.id!);
//       } else {
//         await remoteRepo.upsert(p);
//         await localRepo.markSynced(p.id!);
//       }
//     }
    
//     // 3. BAIXAR DADOS DO FIRESTORE
//     final remotos = await remoteRepo.fetchAllOnce();
//     for (final remoto in remotos) {
//       await localRepo.upsertFromRemote(remoto);
//     }
//   }
  
//   // ===== OPERAÇÕES AVANÇADAS =====
  
//   static void exemploOperacoesAvancadas() async {
//     final repo = ProductRepository();
    
//     // 1. PRODUTOS COM ESTOQUE BAIXO
//     final todos = await repo.getAll();
//     final estoqueBaixo = todos.where((p) => p.stock <= 5).toList();
//     print('Produtos com estoque baixo: ${estoqueBaixo.length}');
    
//     // 2. PRODUTO MAIS CARO
//     if (todos.isNotEmpty) {
//       final maisCaro = todos.reduce((a, b) => a.price > b.price ? a : b);
//       print('Produto mais caro: ${maisCaro.name} - R\$ ${maisCaro.price}');
//     }
    
//     // 3. VALOR TOTAL DO ESTOQUE
//     final valorTotal = todos.fold<double>(
//       0, (sum, p) => sum + (p.price * p.stock)
//     );
//     print('Valor total do estoque: R\$ ${valorTotal.toStringAsFixed(2)}');
    
//     // 4. PRODUTOS POR CATEGORIA (usando descrição)
//     final porCategoria = <String, List<Product>>{};
//     for (final produto in todos) {
//       final categoria = produto.description?.split(' ').first ?? 'Outros';
//       porCategoria.putIfAbsent(categoria, () => []).add(produto);
//     }
//   }
  
//   // ===== VALIDAÇÕES E TRATAMENTO DE ERROS =====
  
//   static void exemploValidacoes() async {
//     final controller = Get.put(ProductController());
    
//     // 1. VALIDAÇÃO DE DADOS
//     final erro = controller.validate(
//       name: '', // ❌ Nome vazio
//       priceStr: 'abc', // ❌ Preço inválido
//       stockStr: '-5', // ❌ Estoque negativo
//     );
    
//     if (erro != null) {
//       print('Erro de validação: $erro');
//       return;
//     }
    
//     // 2. TRATAMENTO DE ERROS ASSÍNCRONOS
//     try {
//       await controller.create(
//         name: 'Produto Teste',
//         price: 99.99,
//         stock: 10,
//       );
//     } catch (e) {
//       print('Erro ao criar produto: $e');
//       // Mostrar snackbar ou dialog de erro
//     }
    
//     // 3. VERIFICAR STATUS DE CARREGAMENTO
//     if (controller.isLoading.value) {
//       print('Aguardando operação...');
//     }
    
//     if (controller.error.value != null) {
//       print('Erro detectado: ${controller.error.value}');
//     }
//   }
// }

// // ===== WIDGET EXEMPLO DE USO =====



// class ExemploWidgetProdutos extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ProductController());
    
//     return Scaffold(
//       appBar: AppBar(title: Text('Produtos')),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }
        
//         if (controller.error.value != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: 64, color: Colors.red),
//                 SizedBox(height: 16),
//                 Text(controller.error.value!),
//                 SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => controller.load(),
//                   child: Text('Tentar Novamente'),
//                 ),
//               ],
//             ),
//           );
//         }
        
//         return ListView.builder(
//           itemCount: controller.products.length,
//           itemBuilder: (context, index) {
//             final produto = controller.products[index];
//             return ListTile(
//               title: Text(produto.name),
//               subtitle: Text('R\$ ${produto.price} • Estoque: ${produto.stock}'),
//               trailing: PopupMenuButton(
//                 itemBuilder: (context) => [
//                   PopupMenuItem(
//                     value: 'edit',
//                     child: Text('Editar'),
//                   ),
//                   PopupMenuItem(
//                     value: 'delete',
//                     child: Text('Excluir'),
//                   ),
//                 ],
//                 onSelected: (value) {
//                   if (value == 'delete') {
//                     controller.remove(produto.id!);
//                   }
//                   // Implementar edição...
//                 },
//               ),
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navegar para tela de criar produto
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }