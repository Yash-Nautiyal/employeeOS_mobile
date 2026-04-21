// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $routingSplashRoute,
      $homeRoute,
      $authRoute,
      $appRoute,
      $appUserRoute,
      $appHiringRoute,
      $appKanbanRoute,
      $appChatRoute,
      $appChatThreadRoute,
      $appFileManagerRoute,
      $appRecruitmentJobPostingRoute,
      $appRecruitmentJobPostingAddRoute,
      $appRecruitmentJobPostingDetailRoute,
      $appRecruitmentJobPostingEditRoute,
      $appRecruitmentJobApplicationRoute,
      $appRecruitmentInterviewSchedulingRoute,
      $appUserAccountRoute,
      $appUserProfileRoute,
      $appUserCardsRoute,
      $appCreateUserRoute,
    ];

RouteBase get $routingSplashRoute => GoRouteData.$route(
      path: '/splash',
      factory: $RoutingSplashRouteExtension._fromState,
    );

extension $RoutingSplashRouteExtension on RoutingSplashRoute {
  static RoutingSplashRoute _fromState(GoRouterState state) =>
      const RoutingSplashRoute();

  String get location => GoRouteData.$location(
        '/splash',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: $HomeRouteExtension._fromState,
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $authRoute => GoRouteData.$route(
      path: '/auth',
      factory: $AuthRouteExtension._fromState,
    );

extension $AuthRouteExtension on AuthRoute {
  static AuthRoute _fromState(GoRouterState state) => const AuthRoute();

  String get location => GoRouteData.$location(
        '/auth',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRoute => GoRouteData.$route(
      path: '/app',
      factory: $AppRouteExtension._fromState,
    );

extension $AppRouteExtension on AppRoute {
  static AppRoute _fromState(GoRouterState state) => const AppRoute();

  String get location => GoRouteData.$location(
        '/app',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appUserRoute => GoRouteData.$route(
      path: '/app/user',
      factory: $AppUserRouteExtension._fromState,
    );

extension $AppUserRouteExtension on AppUserRoute {
  static AppUserRoute _fromState(GoRouterState state) => const AppUserRoute();

  String get location => GoRouteData.$location(
        '/app/user',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appHiringRoute => GoRouteData.$route(
      path: '/app/hiring',
      factory: $AppHiringRouteExtension._fromState,
    );

extension $AppHiringRouteExtension on AppHiringRoute {
  static AppHiringRoute _fromState(GoRouterState state) =>
      const AppHiringRoute();

  String get location => GoRouteData.$location(
        '/app/hiring',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appKanbanRoute => GoRouteData.$route(
      path: '/app/kanban',
      factory: $AppKanbanRouteExtension._fromState,
    );

extension $AppKanbanRouteExtension on AppKanbanRoute {
  static AppKanbanRoute _fromState(GoRouterState state) =>
      const AppKanbanRoute();

  String get location => GoRouteData.$location(
        '/app/kanban',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appChatRoute => GoRouteData.$route(
      path: '/app/chat',
      factory: $AppChatRouteExtension._fromState,
    );

extension $AppChatRouteExtension on AppChatRoute {
  static AppChatRoute _fromState(GoRouterState state) => const AppChatRoute();

  String get location => GoRouteData.$location(
        '/app/chat',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appChatThreadRoute => GoRouteData.$route(
      path: '/app/chat/thread/:conversationId',
      factory: $AppChatThreadRouteExtension._fromState,
    );

extension $AppChatThreadRouteExtension on AppChatThreadRoute {
  static AppChatThreadRoute _fromState(GoRouterState state) =>
      AppChatThreadRoute(
        conversationId: state.pathParameters['conversationId']!,
        $extra: state.extra as ChatThreadRouteExtra?,
      );

  String get location => GoRouteData.$location(
        '/app/chat/thread/${Uri.encodeComponent(conversationId)}',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $appFileManagerRoute => GoRouteData.$route(
      path: '/app/files',
      factory: $AppFileManagerRouteExtension._fromState,
    );

extension $AppFileManagerRouteExtension on AppFileManagerRoute {
  static AppFileManagerRoute _fromState(GoRouterState state) =>
      const AppFileManagerRoute();

  String get location => GoRouteData.$location(
        '/app/files',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRecruitmentJobPostingRoute => GoRouteData.$route(
      path: '/app/recruitment/job-posting',
      factory: $AppRecruitmentJobPostingRouteExtension._fromState,
    );

extension $AppRecruitmentJobPostingRouteExtension
    on AppRecruitmentJobPostingRoute {
  static AppRecruitmentJobPostingRoute _fromState(GoRouterState state) =>
      const AppRecruitmentJobPostingRoute();

  String get location => GoRouteData.$location(
        '/app/recruitment/job-posting',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRecruitmentJobPostingAddRoute => GoRouteData.$route(
      path: '/app/recruitment/job-posting/add',
      factory: $AppRecruitmentJobPostingAddRouteExtension._fromState,
    );

extension $AppRecruitmentJobPostingAddRouteExtension
    on AppRecruitmentJobPostingAddRoute {
  static AppRecruitmentJobPostingAddRoute _fromState(GoRouterState state) =>
      const AppRecruitmentJobPostingAddRoute();

  String get location => GoRouteData.$location(
        '/app/recruitment/job-posting/add',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRecruitmentJobPostingDetailRoute => GoRouteData.$route(
      path: '/app/recruitment/job-posting/:jobId',
      factory: $AppRecruitmentJobPostingDetailRouteExtension._fromState,
    );

extension $AppRecruitmentJobPostingDetailRouteExtension
    on AppRecruitmentJobPostingDetailRoute {
  static AppRecruitmentJobPostingDetailRoute _fromState(GoRouterState state) =>
      AppRecruitmentJobPostingDetailRoute(
        jobId: state.pathParameters['jobId']!,
      );

  String get location => GoRouteData.$location(
        '/app/recruitment/job-posting/${Uri.encodeComponent(jobId)}',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRecruitmentJobPostingEditRoute => GoRouteData.$route(
      path: '/app/recruitment/job-posting/:jobId/edit',
      factory: $AppRecruitmentJobPostingEditRouteExtension._fromState,
    );

extension $AppRecruitmentJobPostingEditRouteExtension
    on AppRecruitmentJobPostingEditRoute {
  static AppRecruitmentJobPostingEditRoute _fromState(GoRouterState state) =>
      AppRecruitmentJobPostingEditRoute(
        jobId: state.pathParameters['jobId']!,
        $extra: state.extra as JobPosting,
      );

  String get location => GoRouteData.$location(
        '/app/recruitment/job-posting/${Uri.encodeComponent(jobId)}/edit',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}

RouteBase get $appRecruitmentJobApplicationRoute => GoRouteData.$route(
      path: '/app/recruitment/job-application',
      factory: $AppRecruitmentJobApplicationRouteExtension._fromState,
    );

extension $AppRecruitmentJobApplicationRouteExtension
    on AppRecruitmentJobApplicationRoute {
  static AppRecruitmentJobApplicationRoute _fromState(GoRouterState state) =>
      const AppRecruitmentJobApplicationRoute();

  String get location => GoRouteData.$location(
        '/app/recruitment/job-application',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appRecruitmentInterviewSchedulingRoute => GoRouteData.$route(
      path: '/app/recruitment/interview-scheduling',
      factory: $AppRecruitmentInterviewSchedulingRouteExtension._fromState,
    );

extension $AppRecruitmentInterviewSchedulingRouteExtension
    on AppRecruitmentInterviewSchedulingRoute {
  static AppRecruitmentInterviewSchedulingRoute _fromState(
          GoRouterState state) =>
      const AppRecruitmentInterviewSchedulingRoute();

  String get location => GoRouteData.$location(
        '/app/recruitment/interview-scheduling',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appUserAccountRoute => GoRouteData.$route(
      path: '/app/user-management/account',
      factory: $AppUserAccountRouteExtension._fromState,
    );

extension $AppUserAccountRouteExtension on AppUserAccountRoute {
  static AppUserAccountRoute _fromState(GoRouterState state) =>
      const AppUserAccountRoute();

  String get location => GoRouteData.$location(
        '/app/user-management/account',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appUserProfileRoute => GoRouteData.$route(
      path: '/app/user-management/profile',
      factory: $AppUserProfileRouteExtension._fromState,
    );

extension $AppUserProfileRouteExtension on AppUserProfileRoute {
  static AppUserProfileRoute _fromState(GoRouterState state) =>
      const AppUserProfileRoute();

  String get location => GoRouteData.$location(
        '/app/user-management/profile',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appUserCardsRoute => GoRouteData.$route(
      path: '/app/user-management/card',
      factory: $AppUserCardsRouteExtension._fromState,
    );

extension $AppUserCardsRouteExtension on AppUserCardsRoute {
  static AppUserCardsRoute _fromState(GoRouterState state) =>
      const AppUserCardsRoute();

  String get location => GoRouteData.$location(
        '/app/user-management/card',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appCreateUserRoute => GoRouteData.$route(
      path: '/app/user-management/create',
      factory: $AppCreateUserRouteExtension._fromState,
    );

extension $AppCreateUserRouteExtension on AppCreateUserRoute {
  static AppCreateUserRoute _fromState(GoRouterState state) =>
      const AppCreateUserRoute();

  String get location => GoRouteData.$location(
        '/app/user-management/create',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
