// 📚 MANUAL PRÁTICO - CRUD DE PRODUTOS
// Como usar o sistema já implementado no seu projeto

/*
==================================================
🏗️ ARQUITETURA ATUAL (JÁ IMPLEMENTADA)
==================================================

1. 📦 Model: Product (lib/products/productModel.dart)
   - Campos: id, remoteId, name, sku, price, stock, description
   - Timestamps: createdAt, updatedAt
   - Sync: dirty, deleted
   - Serialização: SQLite ↔ Firestore

2. 🗄️ Repositories:
   - ProductRepository: CRUD local (SQLite)
   - ProductRemoteRepository: CRUD remoto (Firestore)
   - ProductSyncService: Sincronização automática

3. 🎮 Controller: ProductController (GetX)
   - CRUD completo
   - Validações
   - Estado reativo

==================================================
🚀 COMO USAR - EXEMPLOS PRÁTICOS
==================================================
*/

// ===== 1. INICIALIZAR CONTROLLER =====
/*
import 'package:get/get.dart';
import 'package:teladelogin/products/productController.dart';

// Em qualquer tela/widget:
final controller = Get.put(ProductController());
*/

// ===== 2. CRIAR PRODUTO =====
/*
await controller.create(
  name: 'iPhone 15 Pro',
  sku: 'IP15P-128', 
  price: 8999.99,
  stock: 10,
  description: 'iPhone 15 Pro 128GB',
);

// Resultado: Produto salvo localmente + marcado para sync
*/

// ===== 3. LISTAR PRODUTOS =====
/*
// Carregar todos
await controller.load();

// Buscar por nome/SKU
await controller.load('iPhone');

// Acessar lista reativa
controller.products.listen((produtos) {
  print('Total: ${produtos.length}');
});
*/

// ===== 4. ATUALIZAR PRODUTO =====
/*
final produto = controller.products.first;
final atualizado = produto.copyWith(
  price: 7999.99,
  stock: 15,
);
await controller.updateProduct(atualizado);
*/

// ===== 5. EXCLUIR PRODUTO =====
/*
final produto = controller.products.first;
await controller.remove(produto.id!);
// Resultado: Soft delete (marcado como deleted=true)
*/

// ===== 6. AJUSTAR ESTOQUE =====
/*
// Usando Repository diretamente:
final repo = ProductRepository();
await repo.adjustStock(id: produtoId, delta: -5); // Remove 5
await repo.adjustStock(id: produtoId, delta: 10); // Adiciona 10
*/

/*
==================================================
🔄 SINCRONIZAÇÃO AUTOMÁTICA
==================================================

O ProductSyncService já implementa:

1. 📤 PUSH: Envia dados "dirty" para Firestore
2. 📥 PULL: Baixa dados do Firestore 
3. 🔄 REAL-TIME: Escuta mudanças em tempo real
4. 📡 CONECTIVIDADE: Sync automático quando volta online

Para usar manualmente:
*/

/*
import 'package:teladelogin/services/productSyncService.dart';

final syncService = ProductSyncService(
  local: ProductRepository(),
  remote: ProductRemoteRepository(),
);

await syncService.init(); // Inicializa sync
await syncService.pushDirty(); // Força envio
await syncService.pullFromRemote(); // Força download
*/

/*
==================================================
🎨 WIDGET EXEMPLO COMPLETO
==================================================
*/

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/products/productController.dart';

class ProdutosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos'),
        actions: [
          IconButton(
            onPressed: () => controller.load(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 BARRA DE BUSCA
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) => controller.load(query),
            ),
          ),
          
          // 📊 ESTATÍSTICAS
          Obx(() => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total', '${controller.products.length}'),
                _buildStat('Estoque Baixo', 
                  '${controller.products.where((p) => p.stock <= 5).length}'),
                _buildStat('Sem Estoque', 
                  '${controller.products.where((p) => p.stock == 0).length}'),
              ],
            ),
          )),
          
          SizedBox(height: 16),
          
          // 📋 LISTA DE PRODUTOS
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (controller.error.value != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(controller.error.value!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.load(),
                        child: Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }
              
              if (controller.products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Nenhum produto encontrado'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navegar para criar produto
                        },
                        child: Text('Adicionar Primeiro Produto'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final produto = controller.products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: produto.stock == 0 
                          ? Colors.red 
                          : produto.stock <= 5 
                            ? Colors.orange 
                            : Colors.green,
                        child: Text('${produto.stock}'),
                      ),
                      title: Text(produto.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('R\$ ${produto.price.toStringAsFixed(2)}'),
                          if (produto.sku != null) 
                            Text('SKU: ${produto.sku}', 
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'stock',
                            child: Row(
                              children: [
                                Icon(Icons.inventory, size: 20),
                                SizedBox(width: 8),
                                Text('Ajustar Estoque'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              // Navegar para tela de edição
                              break;
                            case 'stock':
                              _showStockDialog(context, controller, produto);
                              break;
                            case 'delete':
                              _showDeleteDialog(context, controller, produto);
                              break;
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar para ProductFormScreen
        },
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
  
  void _showStockDialog(BuildContext context, ProductController controller, Product produto) {
    // Dialog para ajustar estoque
  }
  
  void _showDeleteDialog(BuildContext context, ProductController controller, Product produto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Produto'),
        content: Text('Tem certeza que deseja excluir "${produto.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.remove(produto.id!);
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
*/

/*
==================================================
✅ RESUMO - SEU SISTEMA JÁ TEM:
==================================================

1. ✅ Model completo com sync
2. ✅ Repository local + remoto  
3. ✅ Controller com GetX
4. ✅ Sincronização automática
5. ✅ Validações básicas
6. ✅ Tratamento de erros
7. ✅ Operações de estoque
8. ✅ Busca por texto
9. ✅ Soft delete
10. ✅ Timestamps automáticos

==================================================
🚀 PRÓXIMOS PASSOS SUGERIDOS:
==================================================

1. 🎨 Melhorar ProductFormScreen
2. 📊 Adicionar relatórios/gráficos  
3. 📱 Implementar notificações push
4. 🏷️ Sistema de categorias
5. 📷 Upload de imagens
6. 📋 Códigos de barras
7. 👥 Controle de usuários/permissões
8. 📈 Analytics de vendas
*/