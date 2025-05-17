class RouteNames {
  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // User routes
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String forgotPassword = '/user/forgot-password';
  static const String userDashboard = '/user/dashboard';
  static const String userChatbot = '/user/chatbot';
  static const String userEducation = '/user/education';
  static const String userEducationDetail = '/user/education/:articleId';
  static const String userProfile = '/user/profile';
  static const String editUserProfile = '/user/profile/edit';

  // Program routes
  static const String programExplorer = '/user/programs/explorer';
  static const String programRecommendations = '/user/programs/recommendations';
  static const String programDetail = '/user/programs/:programId';

  // Admin routes
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminForgotPassword = '/admin/forgot-password';
  static const String adminRegister = '/admin/register';

  // Admin User Management routes
  static const String adminUserList = '/admin/users';
  static const String adminEditUser = '/admin/users/edit';

  // Admin Program Management routes
  static const String adminProgramList = '/admin/programs';
  static const String adminProgramDetail = '/admin/programs/detail';
  static const String adminAddProgram = '/admin/programs/add';

  // Admin Submission Management routes
  static const String adminSubmissionManagement = '/admin/submissions';
  static const String adminSubmissionDetail = '/admin/submissions/detail';

  // Admin Education Content Management routes
  static const String adminEducationContent = '/admin/education';
  static const String adminAddContent = '/admin/education/add';
  static const String adminContentEditor = '/admin/education/editor';

  // Admin Profile Management routes
  static const String adminProfile = '/admin/profile';
  static const String adminEditProfile = '/admin/profile/edit';
}
