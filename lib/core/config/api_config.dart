class ApiConfig {
  static const String authBaseUrl = String.fromEnvironment('AUTH_BASE_URL',
      defaultValue: 'https://admin.celiyo.com/api');

  // Update this if Swagger says different
  static const String login = '/auth/login/';
}
