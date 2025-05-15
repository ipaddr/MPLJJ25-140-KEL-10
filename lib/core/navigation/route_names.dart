class RouteNames {
  // Auth routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // User routes
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
}
