import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsLauncher {
  static bool looksLikePhoneNumber(String input) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return false;
    }

    final normalized = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!RegExp(r'^\+?\d+$').hasMatch(normalized)) {
      return false;
    }

    final digitsOnly = normalized.replaceFirst('+', '');
    return digitsOnly.length >= 8;
  }

  static Future<bool> openComposer({
    required String phoneNumber,
    required String message,
  }) async {
    if (kIsWeb) {
      return false;
    }

    final normalized = phoneNumber.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: normalized,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
