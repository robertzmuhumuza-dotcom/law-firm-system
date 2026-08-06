class ApiConfig {
  // Updated with your exact live Render backend URL including -mrek
  static const String baseUrl = 'https://law-firm-system-mrek.onrender.com';
  
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
}