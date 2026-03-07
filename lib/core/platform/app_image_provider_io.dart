import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider<Object> appImageProvider({
  required String path,
  Uint8List? bytes,
}) {
  return FileImage(File(path));
}
