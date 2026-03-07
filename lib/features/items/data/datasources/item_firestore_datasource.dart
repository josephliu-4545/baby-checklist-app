import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/item_model.dart';

class ItemFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const ItemFirestoreDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> _itemsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('items');
  }

  Future<List<ItemModel>> getAll({required String uid}) async {
    final snap = await _itemsRef(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => ItemModel.fromFirestore(d.id, d.data()))
        .toList(growable: false);
  }

  Future<ItemModel?> getById({required String uid, required String id}) async {
    final doc = await _itemsRef(uid).doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      return null;
    }

    return ItemModel.fromFirestore(doc.id, data);
  }

  Future<void> set({required String uid, required ItemModel item}) {
    return _itemsRef(uid).doc(item.id).set(item.toFirestore());
  }

  Future<void> update({required String uid, required ItemModel item}) {
    return _itemsRef(uid).doc(item.id).set(item.toFirestore(), SetOptions(merge: true));
  }

  Future<void> delete({required String uid, required String id}) {
    return _itemsRef(uid).doc(id).delete();
  }
}
