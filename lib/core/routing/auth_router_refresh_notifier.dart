import 'dart:async';

import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:flutter/foundation.dart';

/// Bridges auth state changes into go_router refreshes.
class AuthRouterRefreshNotifier extends ChangeNotifier {
  AuthRouterRefreshNotifier(Stream<AuthState> authStream) {
    _subscription = authStream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
