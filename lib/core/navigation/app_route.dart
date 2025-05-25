import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socio_care/core/navigation/route_names.dart';
import 'package:socio_care/features/admin/dashboard/presentation/pages/admin_dashboard_pages.dart';
import 'package:socio_care/features/admin/profile/presentation/pages/admin_profile_page.dart';
import 'package:socio_care/features/admin/profile/presentation/pages/edit_admin_data_page.dart';
import 'package:socio_care/features/admin/program_management/presentation/pages/admin_edit_program_page.dart';
import 'package:socio_care/features/auth/presentation/pages/splash_page.dart';
import 'package:socio_care/features/auth/presentation/pages/onboarding_page.dart';
import 'package:socio_care/features/user/auth/presentation/pages/user_login_page.dart';
import 'package:socio_care/features/user/auth/presentation/pages/user_new_password_page.dart';
import 'package:socio_care/features/user/auth/presentation/pages/user_otp_page.dart';
import 'package:socio_care/features/user/auth/presentation/pages/user_register_page.dart';
import 'package:socio_care/features/user/auth/presentation/pages/user_forgot_password_page.dart';
import 'package:socio_care/features/user/chatbot_ai/presentation/pages/ai_chatbot_page.dart';
import 'package:socio_care/features/user/dashboard/presentation/pages/user_dashboard_page.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_detail_page.dart';
import 'package:socio_care/features/user/education/presentation/pages/education_list_page.dart';
import 'package:socio_care/features/user/profile/presentation/pages/edit_user_data_page.dart';
import 'package:socio_care/features/user/profile/presentation/pages/user_application_page.dart';
import 'package:socio_care/features/user/profile/presentation/pages/user_profile_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/program_detail_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/program_explorer_page.dart';
import 'package:socio_care/features/user/programs/presentation/pages/my_recommendations_page.dart';
import 'package:socio_care/features/admin/auth/presentation/pages/admin_login_page.dart';
import 'package:socio_care/features/admin/auth/presentation/pages/admin_register_page.dart';
import 'package:socio_care/features/admin/auth/presentation/pages/admin_forgot_password_page.dart';
import 'package:socio_care/features/admin/auth/presentation/pages/admin_otp_page.dart';
import 'package:socio_care/features/admin/auth/presentation/pages/admin_new_password_page.dart';
import 'package:socio_care/features/admin/user_management/presentation/pages/admin_user_list_page.dart';
import 'package:socio_care/features/admin/user_management/presentation/pages/admin_edit_user_page.dart';
import 'package:socio_care/features/admin/program_management/presentation/pages/admin_program_list_page.dart';
import 'package:socio_care/features/admin/program_management/presentation/pages/admin_program_detail_page.dart';
import 'package:socio_care/features/admin/program_management/presentation/pages/admin_add_program_page.dart';
import 'package:socio_care/features/admin/submission_management/presentation/pages/admin_submission_list_page.dart';
import 'package:socio_care/features/admin/submission_management/presentation/pages/admin_submission_detail_page.dart';
import 'package:socio_care/features/admin/submission_management/presentation/pages/admin_edit_submission_page.dart'; // ✅ NEW
import 'package:socio_care/features/admin/education_content/presentation/pages/admin_content_list_page.dart';
import 'package:socio_care/features/admin/education_content/presentation/pages/admin_content_editor_page.dart';

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

    // User routes
    GoRoute(
      path: RouteNames.login,
      name: 'user-login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      name: 'user-register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      name: 'user-forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.userOtp,
      name: 'user-otp',
      builder:
          (context, state) =>
              UserOtpPage(resetData: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: RouteNames.userNewPassword,
      name: 'user-new-password',
      builder:
          (context, state) => UserNewPasswordPage(
            resetData: state.extra as Map<String, dynamic>?,
          ),
    ),
    GoRoute(
      path: RouteNames.editUserProfile,
      name: 'user-edit-profile',
      builder: (context, state) => const EditUserDataPage(),
    ),

    // User Dashboard & Features
    GoRoute(
      path: RouteNames.userDashboard,
      name: 'user-dashboard',
      builder: (context, state) => const UserDashboardPage(),
    ),
    GoRoute(
      path: RouteNames.userChatbot,
      name: 'user-chatbot',
      builder: (context, state) => const AiChatbotPage(),
    ),
    GoRoute(
      path: RouteNames.userProfile,
      name: 'user-profile',
      builder: (context, state) => const UserProfilePage(),
    ),
    // ✅ NEW: User Applications route
    GoRoute(
      path: RouteNames.userApplications,
      name: 'user-applications',
      builder: (context, state) => const UserApplicationsPage(),
    ),

    // User Education routes
    GoRoute(
      path: RouteNames.userEducation,
      name: 'user-education',
      builder: (context, state) => const EducationListPage(),
    ),
    GoRoute(
      path: RouteNames.userEducationDetail,
      name: 'user-education-detail',
      builder:
          (context, state) => EducationDetailPage(
            articleId: state.pathParameters['articleId'] ?? '',
          ),
    ),

    // User Program routes
    GoRoute(
      path: RouteNames.programExplorer,
      name: 'user-program-explorer',
      builder: (context, state) => const ProgramExplorerPage(),
    ),
    GoRoute(
      path: RouteNames.programRecommendations,
      name: 'user-recommendations',
      builder: (context, state) => const MyRecommendationsPage(),
    ),
    GoRoute(
      path: RouteNames.programDetail,
      name: 'user-program-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProgramDetailPage(
          programId: state.pathParameters['programId'] ?? '',
          isRecommended: extra?['isRecommended'] ?? false,
        );
      },
    ),

    // Admin Authentication routes
    GoRoute(
      path: RouteNames.adminLogin,
      name: 'admin-login',
      builder: (context, state) => const AdminLoginPage(),
    ),
    GoRoute(
      path: RouteNames.adminRegister,
      name: 'admin-register',
      builder: (context, state) => const AdminRegisterPage(),
    ),
    GoRoute(
      path: RouteNames.adminForgotPassword,
      name: 'admin-forgot-password',
      builder: (context, state) => const AdminForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.adminOtp,
      name: 'admin-otp',
      builder:
          (context, state) => AdminOtpPage(
            resetData: state.extra as Map<String, dynamic>? ?? {},
          ),
    ),
    GoRoute(
      path: RouteNames.adminNewPassword,
      name: 'admin-new-password',
      builder:
          (context, state) => AdminNewPasswordPage(
            resetData: state.extra as Map<String, dynamic>? ?? {},
          ),
    ),

    // Admin Dashboard
    GoRoute(
      path: RouteNames.adminDashboard,
      name: 'admin-dashboard',
      builder: (context, state) => const AdminDashboardPage(),
    ),

    // Admin User Management routes
    GoRoute(
      path: RouteNames.adminUserManagement,
      name: 'admin-user-management',
      builder: (context, state) => const AdminUserListPage(),
    ),
    GoRoute(
      path: '${RouteNames.adminEditUser}/:userId',
      name: 'admin-edit-user',
      builder:
          (context, state) =>
              AdminEditUserPage(userId: state.pathParameters['userId'] ?? ''),
    ),

    // Admin Program Management routes
    GoRoute(
      path: RouteNames.adminProgramList,
      name: 'admin-program-list',
      builder: (context, state) => const AdminProgramListPage(),
    ),
    GoRoute(
      path: RouteNames.adminAddProgram,
      name: 'admin-add-program',
      builder: (context, state) => const AdminAddProgramPage(),
    ),
    GoRoute(
      path: '/admin/programs/detail/:programId',
      name: 'admin-program-detail',
      builder: (context, state) {
        final programId = state.pathParameters['programId']!;
        return AdminProgramDetailPage(programId: programId);
      },
    ),
    GoRoute(
      path: '/admin/programs/edit/:programId',
      name: 'admin-edit-program',
      builder: (context, state) {
        final programId = state.pathParameters['programId']!;
        return AdminEditProgramPage(programId: programId);
      },
    ),

    // Admin Submission Management routes
    GoRoute(
      path: RouteNames.adminSubmissionManagement,
      name: 'admin-submission-management',
      builder: (context, state) => const AdminSubmissionListPage(),
    ),
    GoRoute(
      path: '${RouteNames.adminSubmissionDetail}/:submissionId',
      name: 'admin-submission-detail',
      builder:
          (context, state) => AdminSubmissionDetailPage(
            submissionId: state.pathParameters['submissionId'] ?? '',
          ),
    ),
    // ✅ NEW: Admin Edit Submission route
    GoRoute(
      path: '${RouteNames.adminEditSubmission}/:submissionId',
      name: 'admin-edit-submission',
      builder:
          (context, state) => AdminEditSubmissionPage(
            submissionId: state.pathParameters['submissionId'] ?? '',
          ),
    ),

    // Admin Education Content Management routes
    GoRoute(
      path: RouteNames.adminEducationContent,
      name: 'admin-education-content',
      builder: (context, state) => const AdminContentListPage(),
    ),
    GoRoute(
      path: RouteNames.adminAddContent,
      name: 'admin-add-content',
      builder: (context, state) => const AdminContentEditorPage(),
    ),
    GoRoute(
      path: '${RouteNames.adminContentEditor}/:contentId',
      name: 'admin-content-editor-edit',
      builder:
          (context, state) => AdminContentEditorPage(
            contentId: state.pathParameters['contentId'],
          ),
    ),
    GoRoute(
      path: RouteNames.adminContentEditor,
      name: 'admin-content-editor-new',
      builder: (context, state) => const AdminContentEditorPage(),
    ),

    // Admin Profile Management routes
    GoRoute(
      path: RouteNames.adminProfile,
      name: 'admin-profile',
      builder: (context, state) => const AdminProfilePage(),
    ),
    GoRoute(
      path: RouteNames.adminEditProfile,
      name: 'admin-edit-profile',
      builder: (context, state) => const AdminEditProfilePage(),
    ),
  ],
);