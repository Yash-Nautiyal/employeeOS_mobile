import 'package:employeeos/core/routing/routing_splash_page.dart';
import 'package:employeeos/view/auth/presentation/pages/auth_view.dart';
import 'package:employeeos/view/chat/data/test_data.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation;
import 'package:employeeos/view/chat/presentation/pages/chat_view.dart';
import 'package:employeeos/view/chat/presentation/pages/thread_page.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/filemanager/presentation/pages/filemanager_view.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_page.dart';
import 'package:employeeos/view/home/presentation/pages/home_view.dart';
import 'package:employeeos/view/kanban/presentation/pages/kanban_view.dart';
import 'package:employeeos/view/recruitment/domain/index.dart' show JobPosting;
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

part 'app_routes.g.dart';

@TypedGoRoute<RoutingSplashRoute>(path: '/splash')
class RoutingSplashRoute extends GoRouteData {
  const RoutingSplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RoutingSplashPage();
}

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeView();
}

@TypedGoRoute<AuthRoute>(path: '/auth')
class AuthRoute extends GoRouteData {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthView();
}

@TypedGoRoute<AppRoute>(path: '/app')
class AppRoute extends GoRouteData {
  const AppRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UserDashboardView();
}

@TypedGoRoute<AppUserRoute>(path: '/app/user')
class AppUserRoute extends GoRouteData {
  const AppUserRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UserDashboardView();
}

@TypedGoRoute<AppHiringRoute>(path: '/app/hiring')
class AppHiringRoute extends GoRouteData {
  const AppHiringRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HiringPage();
}

@TypedGoRoute<AppKanbanRoute>(path: '/app/kanban')
class AppKanbanRoute extends GoRouteData {
  const AppKanbanRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const KanbanView();
}

@TypedGoRoute<AppChatRoute>(path: '/app/chat')
class AppChatRoute extends GoRouteData {
  const AppChatRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatView();
}

class ChatThreadRouteExtra {
  const ChatThreadRouteExtra({
    required this.conversation,
    required this.conversations,
    required this.currentUserId,
  });

  final Conversation conversation;
  final List<Conversation> conversations;
  final String currentUserId;
}

@TypedGoRoute<AppChatThreadRoute>(path: '/app/chat/thread/:conversationId')
class AppChatThreadRoute extends GoRouteData {
  const AppChatThreadRoute({
    required this.conversationId,
    this.$extra,
  });

  final String conversationId;
  final ChatThreadRouteExtra? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final fallbackConversations = testConversations;
    final fallbackSelected = fallbackConversations
        .where((c) => c.id == conversationId)
        .cast<Conversation?>()
        .firstWhere((c) => c != null, orElse: () => null);
    final selectedConversation = $extra?.conversation ?? fallbackSelected;
    final conversations = $extra?.conversations ?? fallbackConversations;
    final currentUserId = $extra?.currentUserId ?? 'user-123';

    return ThreadPage(
      selectedConversation: selectedConversation,
      conversations: conversations,
      currentUserId: currentUserId,
      onConversationTap: (_) {},
    );
  }
}

@TypedGoRoute<AppFileManagerRoute>(path: '/app/files')
class AppFileManagerRoute extends GoRouteData {
  const AppFileManagerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FilemanagerView();
}

@TypedGoRoute<AppRecruitmentJobPostingRoute>(
  path: '/app/recruitment/job-posting',
)
class AppRecruitmentJobPostingRoute extends GoRouteData {
  const AppRecruitmentJobPostingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const JobPostingPage();
}

@TypedGoRoute<AppRecruitmentJobPostingAddRoute>(
  path: '/app/recruitment/job-posting/add',
)
class AppRecruitmentJobPostingAddRoute extends GoRouteData {
  const AppRecruitmentJobPostingAddRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const AddJobPostingPage();
}

@TypedGoRoute<AppRecruitmentJobPostingDetailRoute>(
  path: '/app/recruitment/job-posting/:jobId',
)
class AppRecruitmentJobPostingDetailRoute extends GoRouteData {
  const AppRecruitmentJobPostingDetailRoute({required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      JobViewPage(jobId: jobId);
}

@TypedGoRoute<AppRecruitmentJobPostingEditRoute>(
  path: '/app/recruitment/job-posting/:jobId/edit',
)
class AppRecruitmentJobPostingEditRoute extends GoRouteData {
  const AppRecruitmentJobPostingEditRoute({
    required this.jobId,
    required this.$extra,
  });

  final String jobId;
  final JobPosting $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      JobEditingPage(job: $extra);
}

@TypedGoRoute<AppRecruitmentJobApplicationRoute>(
  path: '/app/recruitment/job-application',
)
class AppRecruitmentJobApplicationRoute extends GoRouteData {
  const AppRecruitmentJobApplicationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const JobApplicationView();
}

@TypedGoRoute<AppRecruitmentInterviewSchedulingRoute>(
  path: '/app/recruitment/interview-scheduling',
)
class AppRecruitmentInterviewSchedulingRoute extends GoRouteData {
  const AppRecruitmentInterviewSchedulingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InterviewSchedulingView();
}

@TypedGoRoute<AppUserAccountRoute>(path: '/app/user-management/account')
class AppUserAccountRoute extends GoRouteData {
  const AppUserAccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UserAccount();
}

@TypedGoRoute<AppUserProfileRoute>(path: '/app/user-management/profile')
class AppUserProfileRoute extends GoRouteData {
  const AppUserProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UserProfile();
}

@TypedGoRoute<AppUserCardsRoute>(path: '/app/user-management/card')
class AppUserCardsRoute extends GoRouteData {
  const AppUserCardsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const UserCards();
}

@TypedGoRoute<AppCreateUserRoute>(path: '/app/user-management/create')
class AppCreateUserRoute extends GoRouteData {
  const AppCreateUserRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateUserPage();
}
