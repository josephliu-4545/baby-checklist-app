import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider<Object> appImageProvider({
  required String path,
  Uint8List? bytes,
}) {
  if (bytes == null) {
    throw UnsupportedError('Image bytes required on this platform.');
  }
  return MemoryImage(bytes);
}
