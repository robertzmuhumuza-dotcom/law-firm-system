class ApiConfig {
  static const String baseUrl = 'https://law-firm-system-mrek.onrender.com';
  
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  
  // Feature Endpoints
  static const String cases = '$baseUrl/api/cases';
  static const String documents = '$baseUrl/api/documents';
  static const String aiChat = '$baseUrl/api/ai/chat';
  static const String roles = '$baseUrl/api/roles';
}