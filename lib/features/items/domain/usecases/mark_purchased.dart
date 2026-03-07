import '../entities/item.dart';
import '../repositories/item_repository.dart';

class MarkPurchased {
  final ItemRepository _itemRepository;

  const MarkPurchased(this._itemRepository);

  Future<void> call(String id) async {
    final item = await _itemRepository.getItemById(id);
    if (item == null) {
      return;
    }

    final updatedItem = item.copyWith(status: ItemStatus.purchased);
    await _itemRepository.updateItem(updatedItem);
  }
}

