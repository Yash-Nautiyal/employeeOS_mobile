import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

String? appRedirect(GoRouterState state, AuthState authState) {
  final isAuthResolving = authState is AuthInitial || authState is AuthLoading;
  final isAuthenticated = authState is Authenticated;
  final isEmployee = authState.currentProfile?.isEmployee ?? false;

  return appRedirectForPath(
    path: state.uri.path,
    isAuthResolving: isAuthResolving,
    isAuthenticated: isAuthenticated,
    isEmployee: isEmployee,
  );
}

String? appRedirectForPath({
  required String path,
  required bool isAuthResolving,
  required bool isAuthenticated,
  required bool isEmployee,
}) {
  final isSplashPath = path == '/splash';
  final isAuthPath = path == '/auth';
  final isAppPath = path == '/app' || path.startsWith('/app/');

  if (isAuthResolving) {
    return isSplashPath ? null : '/splash';
  }

  if (isSplashPath) {
    return isAuthenticated ? '/app/user' : '/';
  }

  if (!isAuthenticated && isAppPath) return '/auth';
  if (isAuthenticated && (path == '/' || isAuthPath || path == '/app')) {
    return '/app/user';
  }

  final isRecruitmentPath = path.startsWith('/app/recruitment');
  if (isAuthenticated && isEmployee && isRecruitmentPath) return '/app/user';

  return null;
}
