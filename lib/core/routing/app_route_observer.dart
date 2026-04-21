import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Centralized route observer hook for navigation analytics/logging.
class AppRouteObserver extends NavigatorObserver {
  void _logRoute(String event, Route<dynamic>? route) {
    if (!kDebugMode || route == null) return;
    final name = route.settings.name ?? route.runtimeType.toString();
    debugPrint('[nav][$event] $name');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('push', route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logRoute('pop', route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _logRoute('replace', newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
