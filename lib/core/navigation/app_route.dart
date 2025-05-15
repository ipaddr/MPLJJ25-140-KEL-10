import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/auth/presentation/pages/splash_page.dart';
import 'package:socio_care/features/auth/presentation/pages/onboarding_page.dart';
import 'package:socio_care/features/auth/presentation/pages/login_page.dart';
import 'package:socio_care/features/auth/presentation/pages/register_page.dart';
import 'package:socio_care/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:socio_care/features/user/chatbot_ai/presentation/pages/ai_chatbot_page.dart';
import 'package:socio_care/features/user/dashboard/presentation/pages/user_dashboard_page.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_detail_page.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_list_page.dart';
import 'package:socio_care/features/user/profile/presentation/pages/edit_user_data_page.dart';
import 'package:socio_care/features/user/profile/presentation/pages/user_profile_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/program_detail_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/program_explorer_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/my_recommendations_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  routes: [
    // Auth flow routes
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.editUserProfile,
      name: 'edit-profile',
      builder: (context, state) => const EditUserDataPage(),
    ),
    GoRoute(
      path: RouteNames.userEducationDetail,
      name: 'education-detail',
      builder:
          (context, state) => EducationDetailPage(
            articleId: state.pathParameters['articleId'] ?? '',
            title:
                (state.extra as Map<String, dynamic>?)?['title'] ??
                'Article Title',
            content:
                (state.extra as Map<String, dynamic>?)?['content'] ??
                'Article Content',
          ),
    ),

    // User feature routes
    GoRoute(
      path: RouteNames.userDashboard,
      name: 'dashboard',
      builder: (context, state) => const UserDashboardPage(),
    ),
    GoRoute(
      path: RouteNames.userChatbot,
      name: 'chatbot',
      builder: (context, state) => const AiChatbotPage(),
    ),
    GoRoute(
      path: RouteNames.userEducation,
      name: 'education',
      builder: (context, state) => const EducationListPage(),
    ),
    GoRoute(
      path: RouteNames.userProfile,
      name: 'profile',
      builder: (context, state) => const UserProfilePage(),
    ),

    // Program routes
    GoRoute(
      path: RouteNames.programExplorer,
      name: 'program-explorer',
      builder: (context, state) => const ProgramExplorerPage(),
    ),
    GoRoute(
      path: RouteNames.programRecommendations,
      name: 'recommendations',
      builder: (context, state) => const MyRecommendationsPage(),
    ),
    GoRoute(
      path: RouteNames.programDetail,
      name: 'program-detail',
      builder:
          (context, state) => ProgramDetailPage(
            programId: state.pathParameters['programId'] ?? '',
            isRecommended:
                (state.extra as Map<String, dynamic>?)?['isRecommended'] ??
                false,
          ),
    ),
  ],
);
