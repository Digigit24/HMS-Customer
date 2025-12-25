class RazorpayConfig {
  // IMPORTANT: Replace these with your actual Razorpay API keys
  // Get your keys from: https://dashboard.razorpay.com/app/keys

  // For Testing: Use Test API Keys (starts with 'rzp_test_')
  // For Production: Use Live API Keys (starts with 'rzp_live_')

  // TODO: Replace with your Test Key ID
  static const String keyId = 'rzp_test_YOUR_KEY_ID_HERE';

  // TODO: Replace with your Test Key Secret (Keep this secure!)
  // Note: Key Secret should ideally be stored on backend for security
  static const String keySecret = 'YOUR_KEY_SECRET_HERE';

  // Company/Business Information
  static const String companyName = 'MediXpert Pharmacy';
  static const String companyLogo = 'https://your-logo-url.com/logo.png'; // Optional
  static const String companyDescription = 'Payment for pharmacy order';

  // Currency
  static const String currency = 'INR';

  // Theme color for Razorpay checkout (hex color without #)
  static const String themeColor = '4F46E5'; // Indigo color

  // Contact information (optional but recommended)
  static const String contactEmail = 'support@medixpert.com';
  static const String contactPhone = '+919876543210';

  // Payment timeout in seconds
  static const int timeoutDuration = 300; // 5 minutes

  // Enable/Disable payment methods
  static const bool enableUPI = true;
  static const bool enableCard = true;
  static const bool enableNetbanking = true;
  static const bool enableWallet = true;
  static const bool enableEMI = false;

  // Backend endpoints for Razorpay integration
  static const String createOrderEndpoint = '/pharmacy/razorpay/create-order/';
  static const String verifyPaymentEndpoint = '/pharmacy/razorpay/verify-payment/';

  // Retry configuration
  static const int maxRetryAttempts = 3;
  static const bool retryEnabled = true;
}
