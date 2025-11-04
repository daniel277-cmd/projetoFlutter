import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teladelogin/products/productController.dart';
import 'package:teladelogin/products/productModel.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormStateFields {
  final nameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    skuCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    descCtrl.dispose();
  }
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final c = Get.find<ProductController>();
  final f = _ProductFormStateFields();

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      f.nameCtrl.text = p.name;
      f.skuCtrl.text = p.sku ?? '';
      f.priceCtrl.text = p.price.toStringAsFixed(2);
      f.stockCtrl.text = p.stock.toString();
      f.descCtrl.text = p.description ?? '';
    }
  }

  @override
  void dispose() {
    f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? '✏️ Editar Produto' : '➕ Novo Produto'),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: f.nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.skuCtrl,
              decoration: const InputDecoration(labelText: 'SKU'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Preço (R\$) *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Estoque *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: f.descCtrl,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton.icon(
                  icon: c.isLoading.value
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(isEdit ? 'Salvar alterações' : 'Cadastrar'),
                  onPressed: c.isLoading.value
                      ? null
                      : () async {
                          final error = c.validate(
                            name: f.nameCtrl.text,
                            priceStr: f.priceCtrl.text,
                            stockStr: f.stockCtrl.text,
                          );
                          if (error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                            return;
                          }
                          final price = double.parse(f.priceCtrl.text.replaceAll(',', '.'));
                          final stock = int.parse(f.stockCtrl.text);

                          if (isEdit) {
                            final updated = widget.product!.copyWith(
                              name: f.nameCtrl.text.trim(),
                              sku: f.skuCtrl.text.trim().isEmpty ? null : f.skuCtrl.text.trim(),
                              price: price,
                              stock: stock,
                              description: f.descCtrl.text.trim().isEmpty ? null : f.descCtrl.text.trim(),
                              updatedAt: DateTime.now(),
                            );
                            final ok = await c.updateProduct(updated);
                            if (ok && mounted) Navigator.pop(context, true);
                          } else {
                            final ok = await c.create(
                              name: f.nameCtrl.text.trim(),
                              sku: f.skuCtrl.text.trim().isEmpty ? null : f.skuCtrl.text.trim(),
                              price: price,
                              stock: stock,
                              description: f.descCtrl.text.trim().isEmpty ? null : f.descCtrl.text.trim(),
                            );
                            if (ok && mounted) Navigator.pop(context, true);
                          }
                        },
                )),
          ],
        ),
      ),
    );
  }
}
