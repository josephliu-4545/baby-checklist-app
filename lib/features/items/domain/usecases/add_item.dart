import '../entities/item.dart';
import '../repositories/item_repository.dart';

class AddItem {
  final ItemRepository _itemRepository;

  const AddItem(this._itemRepository);

  Future<void> call(Item item) {
    return _itemRepository.addItem(item);
  }
}

