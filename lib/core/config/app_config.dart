class AppConfig {
  // IMPORTANT: Change this to your Django backend URL
  // For local development: Use your computer's IP address (not localhost)
  // For production: Use your deployed backend URL

  // Example configurations:
  // Local development (Windows/Mac): 'http://192.168.1.100:8000'
  // Local development (Android emulator): 'http://10.0.2.2:8000'
  // Production: 'https://your-backend.com'

  static const String baseUrl = 'https://hms.celiyo.com';

  // Or use this for local development:
  // static const String baseUrl = 'http://192.168.1.100:8000';

  // API endpoints
  static const String apiVersion = '/api';

  // Request headers configuration
  static const String appOrigin = 'https://admin.gorehospital.com';
  static const String appReferer = 'https://admin.gorehospital.com/';

  // For local development, change origin to match your setup:
  // static const String appOrigin = 'http://localhost:3000';
  // static const String appReferer = 'http://localhost:3000/';

  // Timeout configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Get your local IP address (for development)
  // Windows: Run 'ipconfig' in CMD, look for 'IPv4 Address'
  // Mac/Linux: Run 'ifconfig' or 'ip addr', look for 'inet'
  // Example: 192.168.1.100

  static String get fullApiUrl => '$baseUrl$apiVersion';
}
