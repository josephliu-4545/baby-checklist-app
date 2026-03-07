import '../../domain/entities/item.dart';

class ItemLocalDataSource {
  final List<Item> _orderedItems = [];
  final Map<String, Item> _itemLookup = {};

  List<Item> getAll() {
    return List.unmodifiable(_orderedItems);
  }

  Item? getById(String id) {
    return _itemLookup[id];
  }

  void add(Item item) {
    _orderedItems.add(item);
    _itemLookup[item.id] = item;
  }

  void update(Item item) {
    final existing = _itemLookup[item.id];
    if (existing == null) {
      return;
    }

    final index = _orderedItems.indexWhere((i) => i.id == item.id);
    if (index < 0) {
      return;
    }

    _orderedItems[index] = item;
    _itemLookup[item.id] = item;
  }

  void delete(String id) {
    final existing = _itemLookup[id];
    if (existing == null) {
      return;
    }

    _orderedItems.removeWhere((item) => item.id == id);
    _itemLookup.remove(id);
  }
}
