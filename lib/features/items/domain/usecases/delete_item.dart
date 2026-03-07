import '../repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository _itemRepository;

  const DeleteItem(this._itemRepository);

  Future<void> call(String id) {
    return _itemRepository.deleteItem(id);
  }
}

