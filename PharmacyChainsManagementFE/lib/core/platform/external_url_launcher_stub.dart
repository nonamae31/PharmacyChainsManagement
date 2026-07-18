import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrlImpl(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
