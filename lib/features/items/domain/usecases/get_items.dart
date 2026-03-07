import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetItems {
  final ItemRepository _itemRepository;

  const GetItems(this._itemRepository);

  Future<List<Item>> call() {
    return _itemRepository.getAllItems();
  }
}

