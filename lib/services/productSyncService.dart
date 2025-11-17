// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:teladelogin/products/productModel.dart';
// import 'package:teladelogin/products/productRemoteRepository.dart';
// import 'package:teladelogin/products/productRepository.dart';


// class ProductSyncService {
//   final ProductRepository local;
//   final ProductRemoteRepository remote;
//   StreamSubscription? _connSub;
//   StreamSubscription? _remoteSub;

//   ProductSyncService({required this.local, required this.remote});

//   Future<void> init() async {
//     await pullFromRemote();

//     _remoteSub = remote.watchAll().listen((snap) async {
//       for (final change in snap.docChanges) {
//         final data = change.doc.data();
//         if (data == null) continue;
//         final p = Product.fromFirestore(data, remoteId: change.doc.id);
//         final current = p.remoteId == null ? null : await local.getByRemoteId(p.remoteId!);

//         if (current == null || p.updatedAt.isAfter(current.updatedAt)) {
//           if (p.deleted) {
//             if (current?.id != null) {
//               await local.hardDelete(current!.id!);
//             }
//           } else {
//             await local.upsertFromRemote(p);
//           }
//         }
//       }
//     });

//     _connSub = Connectivity().onConnectivityChanged.listen((status) async {
//       if (status != ConnectivityResult.none) {
//         await pushDirty();
//       }
//     });

//     final now = await Connectivity().checkConnectivity();
//     if (now != ConnectivityResult.none) {
//       await pushDirty();
//     }
//   }

//   Future<void> dispose() async {
//     await _connSub?.cancel();
//     await _remoteSub?.cancel();
//   }

//   Future<void> pullFromRemote() async {
//     final all = await remote.fetchAllOnce();
//     for (final p in all) {
//       final current = p.remoteId == null ? null : await local.getByRemoteId(p.remoteId!);
//       if (current == null || p.updatedAt.isAfter(current.updatedAt)) {
//         if (p.deleted) {
//           if (current?.id != null) await local.hardDelete(current!.id!);
//         } else {
//           await local.upsertFromRemote(p);
//         }
//       }
//     }
//   }

//   Future<void> pushDirty() async {
//     final dirty = await local.getDirty();
//     for (final p in dirty) {
//       if (p.deleted) {
//         if (p.remoteId != null) {
//           await remote.deleteRemote(p.remoteId!);
//           if (p.id != null) await local.hardDelete(p.id!);
//         } else {
//           if (p.id != null) await local.hardDelete(p.id!);
//         }
//         continue;
//       }

//       await remote.upsert(p);
//       await pullFromRemote();
//       if (p.id != null && p.remoteId != null) {
//         await local.markSynced(p.id!);
//       }
//     }
//   }
// }
