class ApiConfig {
  // Make sure this matches your exact Render backend URL from your dashboard
  static const String baseUrl = 'https://law-firm-system.onrender.com';
  
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
}