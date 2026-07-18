// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:typed_data';

void downloadCsv(List<int> bytes, String fileName) {
  final blob = html.Blob([Uint8List.fromList(bytes)], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
}
