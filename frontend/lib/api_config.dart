class ApiConfig {
  // Replace with your actual live Render backend URL
  static const String baseUrl = 'https://YOUR-ACTUAL-RENDER-URL.onrender.com';
  
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
}