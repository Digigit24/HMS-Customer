class RazorpayConfig {
  // Razorpay API Keys
  // Get your keys from: https://dashboard.razorpay.com/app/keys

  // Test Key ID (safe to store in frontend)
  static const String keyId = 'rzp_test_RvnGEYQxe9VLGQ';

  // ⚠️ SECURITY WARNING: Key Secret should NEVER be stored in frontend
  // The secret (2ojbfy2ETMdpaEp93EelR76K) should remain on backend only
  // Frontend only needs the Key ID for Razorpay checkout

  // Company/Business Information
  static const String companyName = 'HMS Customer';
  static const String companyLogo = ''; // Optional
  static const String companyDescription = 'Payment for pharmacy order';

  // Currency
  static const String currency = 'INR';

  // Theme color for Razorpay checkout (hex color without #)
  static const String themeColor = '4F46E5'; // Indigo color

  // Contact information (optional but recommended)
  static const String contactEmail = 'support@hms.celiyo.com';
  static const String contactPhone = '+919876543210';

  // Payment timeout in seconds
  static const int timeoutDuration = 300; // 5 minutes

  // Enable/Disable payment methods
  static const bool enableUPI = true;
  static const bool enableCard = true;
  static const bool enableNetbanking = true;
  static const bool enableWallet = true;
  static const bool enableEMI = false;

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const bool retryEnabled = true;
}
