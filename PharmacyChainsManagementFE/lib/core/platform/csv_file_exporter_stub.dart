import 'package:flutter/services.dart';

Future<bool> exportCsvFile({
  required String fileName,
  required String content,
}) async {
  await Clipboard.setData(ClipboardData(text: content));
  return false;
}
