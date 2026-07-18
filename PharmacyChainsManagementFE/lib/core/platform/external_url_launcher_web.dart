// ignore_for_file: avoid_web_libraries_in_flutter

// ignore: deprecated_member_use
import 'dart:html' as html;

Future<bool> openExternalUrlImpl(Uri uri) async {
  final anchor = html.AnchorElement(href: uri.toString())
    ..target = '_blank'
    ..rel = 'noopener noreferrer'
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  return true;
}
