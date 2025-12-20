class LoginRequest {
  final String emailOrPhone;
  final String password;

  LoginRequest({
    required this.emailOrPhone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    // IMPORTANT:
    // Change key "email" to "username" or "phone" if your backend needs it.
    return {
      'email': emailOrPhone,
      'password': password,
    };
  }
}
