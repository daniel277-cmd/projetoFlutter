// ignore_for_file: file_names

//PROPRIEDADES E ATRIBUTOS DO PRODUTO
class Product {
  final int? id; // ID local (SQLite)
  final String? remoteId; // ID remoto (Firestore)
  final String name; // Nome do produto (obrigatório)
  final String? sku; // Código SKU (opcional)
  final double price; // Preço (obrigatório)
  final int stock; // Estoque (obrigatório)
  final String? description; // Descrição (opcional)
  final DateTime createdAt; // Data de criação
  final DateTime updatedAt; // Data de atualização
  final bool dirty; // Marcador de sincronização
  final bool deleted; // Soft delete

  Product({
    this.id,
    this.remoteId,
    required this.name, // Obrigatório
    this.sku,
    required this.price, // Obrigatório
    required this.stock, // Obrigatório
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.dirty = false, // Padrão: não modificado
    this.deleted = false, // Padrão: não deletado
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Product copyWith({
    int? id,
    String? remoteId,
    String? name,
    String? sku,
    double? price,
    int? stock,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? dirty,
    bool? deleted,
  }) {
    return Product(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
    );
  }

  factory Product.fromMap(Map<String, dynamic> m) => Product(
    id: m['id'] as int?,
    remoteId: m['remoteId'] as String?,
    name: m['name'] as String,
    sku: m['sku'] as String?,
    price: (m['price'] as num).toDouble(),
    stock: (m['stock'] as num).toInt(),
    description: m['description'] as String?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAt'] as int),
    dirty: (m['dirty'] ?? 0) == 1,
    deleted: (m['deleted'] ?? 0) == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'remoteId': remoteId,
    'name': name,
    'sku': sku,
    'price': price,
    'stock': stock,
    'description': description,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'dirty': dirty ? 1 : 0,
    'deleted': deleted ? 1 : 0,
  };

  Map<String, dynamic> toFirestore(String ownerUid) => {
    'ownerUid': ownerUid,
    'name': name,
    'sku': sku,
    'price': price,
    'stock': stock,
    'description': description,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'deleted': deleted,
  };

  static Product fromFirestore(Map<String, dynamic> d, {String? remoteId}) {
    return Product(
      remoteId: remoteId,
      name: d['name'] as String,
      sku: d['sku'] as String?,
      price: (d['price'] as num).toDouble(),
      stock: (d['stock'] as num).toInt(),
      description: d['description'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(d['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(d['updatedAt'] as int),
      deleted: (d['deleted'] ?? false) as bool,
      dirty: false,
    );
  }
}
