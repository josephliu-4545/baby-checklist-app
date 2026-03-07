import '../entities/item.dart';
import '../repositories/item_repository.dart';
import '../../../../services/notification/notification_service.dart';

class DelegateItem {
  final ItemRepository _itemRepository;
  final NotificationService _notificationService;

  const DelegateItem(
    this._itemRepository,
    this._notificationService,
  );

  Future<void> call({
    required String itemId,
    required String delegatedTo,
  }) async {
    final item = await _itemRepository.getItemById(itemId);
    if (item == null) {
      return;
    }

    final updatedItem = item.copyWith(
      status: ItemStatus.delegated,
      delegatedTo: delegatedTo,
      delegationDate: DateTime.now(),
    );
    await _itemRepository.updateItem(updatedItem);
    await _notificationService.sendDelegationNotification(
      phoneNumber: delegatedTo,
      itemName: item.name,
    );
  }
}

