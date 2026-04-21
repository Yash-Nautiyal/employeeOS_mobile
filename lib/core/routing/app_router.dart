import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:employeeos/core/routing/app_redirects.dart';
import 'package:employeeos/core/routing/app_route_observer.dart';
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/core/routing/auth_router_refresh_notifier.dart';
import 'package:employeeos/core/routing/routing_splash_page.dart';
import 'package:employeeos/view/auth/presentation/pages/auth_view.dart';
import 'package:employeeos/view/chat/data/test_data.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/pages/chat_view.dart';
import 'package:employeeos/view/chat/presentation/pages/thread_page.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/filemanager/presentation/pages/filemanager_view.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_page.dart';
import 'package:employeeos/view/home/presentation/pages/home_view.dart';
import 'package:employeeos/view/kanban/presentation/pages/kanban_view.dart';
import 'package:employeeos/view/layout/presentation/pages/layout.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_posting.dart';
import 'package:employeeos/view/recruitment/presentation/pages/interview_scheduling_view.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_application_view.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_posting_page.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/add_posting/add_job_posting_page.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/edit_posting/job_editing.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/view_posting/job_view_page.dart';
import 'package:employeeos/view/user_management/presentation/pages/create_user_page.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_account.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_cards.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_profile.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
                final conversationId = state.pathParameters['conversationId'];
                final extra = state.extra is ChatThreadRouteExtra
                    ? state.extra as ChatThreadRouteExtra
                    : null;
                final fallbackConversations = testConversations;
                final fallbackSelected = fallbackConversations
                    .where((c) => c.id == conversationId)
                    .cast<Conversation?>()
                    .firstWhere((c) => c != null, orElse: () => null);
                return ThreadPage(
                  selectedConversation: extra?.conversation ?? fallbackSelected,
                  conversations: extra?.conversations ?? fallbackConversations,
                  currentUserId: extra?.currentUserId ?? 'user-123',
                  onConversationTap: (_) {},
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
