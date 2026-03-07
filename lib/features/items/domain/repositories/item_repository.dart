import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();

  Future<Item?> getItemById(String id);

  Future<void> addItem(Item item);

  Future<void> updateItem(Item item);

  Future<void> deleteItem(String id);
}

