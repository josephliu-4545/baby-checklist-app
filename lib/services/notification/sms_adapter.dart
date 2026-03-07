abstract class SmsAdapter {
  Future<void> sendSms({
    required String phoneNumber,
    required String message,
  });
}

