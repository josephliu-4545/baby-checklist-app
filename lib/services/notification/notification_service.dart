import 'sms_adapter.dart';

class NotificationService {
  static NotificationService? _instance;

  static NotificationService get instance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('NotificationService has not been initialized');
    }
    return instance;
  }

  final SmsAdapter _smsAdapter;

  NotificationService._(this._smsAdapter);

  factory NotificationService(SmsAdapter adapter) {
    final existing = _instance;
    if (existing != null) {
      return existing;
    }

    final created = NotificationService._(adapter);
    _instance = created;
    return created;
  }

  Future<void> sendDelegationNotification({
    required String phoneNumber,
    required String itemName,
  }) {
    final message = 'You have been delegated to purchase: $itemName';
    return _smsAdapter.sendSms(
      phoneNumber: phoneNumber,
      message: message,
    );
  }
}

