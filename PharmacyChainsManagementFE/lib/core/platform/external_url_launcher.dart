import 'external_url_launcher_stub.dart'
    if (dart.library.html) 'external_url_launcher_web.dart';

Future<bool> openExternalUrl(Uri uri) => openExternalUrlImpl(uri);
