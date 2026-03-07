import '../entities/item.dart';
import '../repositories/item_repository.dart';

class UpdateItem {
  final ItemRepository _itemRepository;

  const UpdateItem(this._itemRepository);

  Future<void> call(Item item) {
    return _itemRepository.updateItem(item);
  }
}

