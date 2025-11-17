import 'package:cloud_firestore/cloud_firestore.dart';
import 'productModel.dart';

class ProductRemoteRepository {
  final _db = FirebaseFirestore.instance.collection('products');

  // Criar no Firestore
  Future<String> createRemote(Product p, String ownerUid) async {
    final doc = await _db.add(p.toFirestore(ownerUid));
    return doc.id;
  }

  // Atualizar no Firestore
  Future<void> updateRemote(Product p) async {
    if (p.remoteId == null) return;
    await _db.doc(p.remoteId).update(p.toFirestore(""));
  }

  // Excluir no Firestore
  Future<void> deleteRemote(String remoteId) async {
    await _db.doc(remoteId).update({"deleted": true});
  }

  // Buscar uma vez (não stream)
  Future<List<Product>> fetchAllOnce(String ownerUid) async {
    final q = await _db.where("ownerUid", isEqualTo: ownerUid).get();

    return q.docs.map((d) {
      return Product.fromFirestore(
        d.data(),
        remoteId: d.id,
      );
    }).toList();
  }

  // Stream em tempo real
  Stream<List<Product>> fetchStream(String ownerUid) {
    return _db
        .where("ownerUid", isEqualTo: ownerUid)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        return Product.fromFirestore(
          d.data(),
          remoteId: d.id,
        );
      }).toList();
    });
  }
}
