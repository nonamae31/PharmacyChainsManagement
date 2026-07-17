import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkConnectivityGuard extends StatelessWidget {
  const NetworkConnectivityGuard({super.key, required this.child});
  final Widget child;

  static bool isOffline(BuildContext context) {
    final results =
        context.dependOnInheritedWidgetOfExactType<_OfflineScope>()?.results ??
        [ConnectivityResult.none];
    return results.contains(ConnectivityResult.none);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final hasData = snapshot.hasData;
        final results = snapshot.data ?? [ConnectivityResult.none];
        final offline = results.contains(ConnectivityResult.none);

        return _OfflineScope(
          results: results,
          child: Stack(
            children: [
              child,
              if (hasData && offline)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Material(
                      color: Colors.redAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.wifi_off, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Offline mode - Features may be limited',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OfflineScope extends InheritedWidget {
  const _OfflineScope({required this.results, required super.child});

  final List<ConnectivityResult> results;

  @override
  bool updateShouldNotify(_OfflineScope oldWidget) =>
      results != oldWidget.results;
}
