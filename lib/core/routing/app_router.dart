import '../../view/index.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_redirects.dart';
import 'app_route_observer.dart';
import 'app_routes.dart';
import 'auth_router_refresh_notifier.dart';
import 'routing_splash_page.dart';

import '../../view/chat/presentation/bloc/chat_bloc.dart';
import '../../view/recruitment/domain/index.dart' show JobPosting;
import '../../core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/di/service_locator.dart';

class AppRouterFactory {
  AppRouterFactory._();

  static GoRouter create(AuthBloc authBloc) {
    final authRefresh = AuthRouterRefreshNotifier(authBloc.stream);
    return GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/splash',
          builder: (context, state) => const RoutingSplashPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthView(),
        ),
        ShellRoute(
          builder: (context, state, child) => Layout(
            selectedItem: _selectedItemForPath(state.uri.path),
            child: child,
          ),
          routes: <RouteBase>[
            GoRoute(
              path: '/app',
              builder: (context, state) => const UserDashboardView(),
            ),
            GoRoute(
              path: '/app/user',
              builder: (context, state) => const UserDashboardView(),
            ),
            GoRoute(
              path: '/app/hiring',
              builder: (context, state) => const HiringPage(),
            ),
            GoRoute(
              path: '/app/kanban',
              builder: (context, state) => const KanbanView(),
            ),
            GoRoute(
              path: '/app/chat',
              builder: (context, state) => const ChatView(),
            ),
            GoRoute(
              path: '/app/chat/thread/:conversationId',
              builder: (context, state) {
                // final conversationId = state.pathParameters['conversationId'];
                final extra = state.extra is ChatThreadRouteExtra
                    ? state.extra as ChatThreadRouteExtra
                    : const ChatThreadRouteExtra(
                        currentUserId: '',
                      );

                final conversationId =
                    state.pathParameters['conversationId'] ?? '';

                return BlocProvider.value(
                  value: sl<ChatBloc>(),
                  child: ThreadPage(
                    selectedConversation: extra.conversation,
                    conversationId: conversationId,
                    conversations: extra.conversations,
                    currentUserId: extra.currentUserId,
                    onConversationTap: (_) {},
                  ),
                );
              },
            ),
            GoRoute(
              path: '/app/chat/new',
              builder: (context, state) {
                // final conversationId = state.pathParameters['conversationId'];
                final extra = state.extra is ChatThreadRouteExtra
                    ? state.extra as ChatThreadRouteExtra
                    : const ChatThreadRouteExtra(currentUserId: '');

                return BlocProvider.value(
                  value: sl<ChatBloc>(),
                  child: ThreadPage(
                    selectedConversation: null,
                    conversationId: 'new',
                    conversations: extra.conversations,
                    currentUserId: extra.currentUserId,
                    onConversationTap: (_) {},
                  ),
                );
              },
            ),
            GoRoute(
              path: '/app/files',
              builder: (context, state) => const FilemanagerView(),
            ),
            GoRoute(
              path: '/app/recruitment/job-posting',
              builder: (context, state) => const JobPostingPage(),
            ),
            GoRoute(
              path: '/app/recruitment/job-posting/add',
              builder: (context, state) => const AddJobPostingPage(),
            ),
            GoRoute(
              path: '/app/recruitment/job-posting/:jobId',
              builder: (context, state) =>
                  JobViewPage(jobId: state.pathParameters['jobId']),
            ),
            GoRoute(
              path: '/app/recruitment/job-posting/:jobId/edit',
              builder: (context, state) {
                final job = state.extra is JobPosting
                    ? state.extra as JobPosting
                    : null;
                if (job == null) return const JobPostingPage();
                return JobEditingPage(job: job);
              },
            ),
            GoRoute(
              path: '/app/recruitment/job-application',
              builder: (context, state) => const JobApplicationView(),
            ),
            GoRoute(
              path: '/app/recruitment/interview-scheduling',
              builder: (context, state) => const InterviewSchedulingView(),
            ),
            GoRoute(
              path: '/app/user-management/account',
              builder: (context, state) => const UserAccount(),
            ),
            GoRoute(
              path: '/app/user-management/profile',
              builder: (context, state) => const UserProfile(),
            ),
            GoRoute(
              path: '/app/user-management/card',
              builder: (context, state) => const UserCards(),
            ),
            GoRoute(
              path: '/app/user-management/create',
              builder: (context, state) => const CreateUserPage(),
            ),
          ],
        ),
      ],
      initialLocation: '/splash',
      refreshListenable: authRefresh,
      observers: <NavigatorObserver>[AppRouteObserver()],
      redirect: (context, state) => appRedirect(state, authBloc.state),
    );
  }

  static String _selectedItemForPath(String path) {
    if (path.startsWith('/app/recruitment/job-posting')) return 'Job Posting';
    if (path.startsWith('/app/recruitment/job-application')) {
      return 'Job Application';
    }
    if (path.startsWith('/app/recruitment/interview-scheduling')) {
      return 'Interview Scheduling';
    }
    if (path.startsWith('/app/hiring')) return 'Hirings';
    if (path.startsWith('/app/kanban')) return 'Kanban';
    if (path.startsWith('/app/chat')) return 'Chat';
    if (path.startsWith('/app/files')) return 'File Manager';
    if (path.startsWith('/app/user-management/account')) return 'Account';
    if (path.startsWith('/app/user-management/profile')) return 'Profile';
    if (path.startsWith('/app/user-management/card')) return 'Card';
    if (path.startsWith('/app/user-management/create')) return 'Create User';
    return 'User';
  }
}
