import 'package:employeeos/core/routing/app_redirects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appRedirectForPath', () {
    test('sends unresolved auth to splash', () {
      final redirect = appRedirectForPath(
        path: '/app/user',
        isAuthResolving: true,
        isAuthenticated: false,
        isEmployee: false,
      );
      expect(redirect, '/splash');
    });

    test('keeps splash while auth is resolving', () {
      final redirect = appRedirectForPath(
        path: '/splash',
        isAuthResolving: true,
        isAuthenticated: false,
        isEmployee: false,
      );
      expect(redirect, isNull);
    });

    test('splash redirects authenticated users to app user', () {
      final redirect = appRedirectForPath(
        path: '/splash',
        isAuthResolving: false,
        isAuthenticated: true,
        isEmployee: false,
      );
      expect(redirect, '/app/user');
    });

    test('blocks unauthenticated access to app paths', () {
      final redirect = appRedirectForPath(
        path: '/app/recruitment/job-posting',
        isAuthResolving: false,
        isAuthenticated: false,
        isEmployee: false,
      );
      expect(redirect, '/auth');
    });

    test('redirects authenticated user off public entry routes', () {
      final redirect = appRedirectForPath(
        path: '/',
        isAuthResolving: false,
        isAuthenticated: true,
        isEmployee: false,
      );
      expect(redirect, '/app/user');
    });

    test('redirects employee away from recruitment routes', () {
      final redirect = appRedirectForPath(
        path: '/app/recruitment/job-posting/11',
        isAuthResolving: false,
        isAuthenticated: true,
        isEmployee: true,
      );
      expect(redirect, '/app/user');
    });
  });
}
