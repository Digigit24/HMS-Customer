class LoginResponse {
  final String access;
  final String refresh;
  final String? message;

  LoginResponse({
    required this.access,
    required this.refresh,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // ✅ TOKENS ARE AT TOP LEVEL
    final tokens = (json['tokens'] is Map)
        ? Map<String, dynamic>.from(json['tokens'])
        : {};

    final access = (tokens['access'] ?? '').toString().trim();
    final refresh = (tokens['refresh'] ?? '').toString().trim();

    return LoginResponse(
      message: json['message']?.toString(),
      access: access,
      refresh: refresh,
    );
  }
}
