import 'sms_adapter.dart';

class SmsMockAdapter implements SmsAdapter {
  const SmsMockAdapter();

  @override
  Future<void> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    // ignore: avoid_print
    print('MOCK SMS to $phoneNumber: $message');
  }
}

