import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/item_firestore_datasource.dart';
import '../models/item_model.dart';

class ItemRepositoryImpl implements ItemRepository {
  final ItemFirestoreDataSource _firestoreDataSource;
  final fb.FirebaseAuth _auth;

  const ItemRepositoryImpl(
    this._firestoreDataSource,
    this._auth,
  );

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('Not authenticated');
    }
    return uid;
  }

  @override
  Future<List<Item>> getAllItems() async {
    final models = await _firestoreDataSource.getAll(uid: _uid);
    return models.map((e) => e.toEntity()).toList(growable: false);
  }

  @override
  Future<Item?> getItemById(String id) async {
    final model = await _firestoreDataSource.getById(uid: _uid, id: id);
    return model?.toEntity();
  }

  @override
  Future<void> addItem(Item item) {
    final model = ItemModel.fromEntity(item);
    return _firestoreDataSource.set(uid: _uid, item: model);
  }

  @override
  Future<void> updateItem(Item item) {
    final model = ItemModel.fromEntity(item);
    return _firestoreDataSource.update(uid: _uid, item: model);
  }

  @override
  Future<void> deleteItem(String id) {
    return _firestoreDataSource.delete(uid: _uid, id: id);
  }
}
