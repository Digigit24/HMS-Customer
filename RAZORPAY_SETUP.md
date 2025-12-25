# Razorpay Payment Integration Setup Guide

This guide will help you integrate Razorpay payment gateway into your HMS Customer application.

## Table of Contents
1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Frontend Setup](#frontend-setup)
4. [Backend Setup](#backend-setup)
5. [Testing](#testing)
6. [Going Live](#going-live)
7. [Troubleshooting](#troubleshooting)

## Overview

The Razorpay integration includes:
- ✅ **Complete order flow** - Create order → Payment → Verification
- ✅ **Dark/Light mode support** - Fully themed payment UI
- ✅ **Multiple payment methods** - UPI, Cards, Net Banking, Wallets
- ✅ **Secure payment verification** - Backend signature verification
- ✅ **Error handling** - Graceful failure handling
- ✅ **Order management** - Automatic order creation after payment

## Getting Started

### 1. Create Razorpay Account

1. Visit [https://razorpay.com](https://razorpay.com)
2. Sign up for a business account
3. Complete KYC verification (for live mode)
4. Get your API keys from [Dashboard → Settings → API Keys](https://dashboard.razorpay.com/app/keys)

### 2. Get API Keys

You'll receive two sets of keys:

**Test Mode Keys** (for development):
- Test Key ID: `rzp_test_XXXXXXXXXXXX`
- Test Key Secret: `XXXXXXXXXXXX`

**Live Mode Keys** (for production):
- Live Key ID: `rzp_live_XXXXXXXXXXXX`
- Live Key Secret: `XXXXXXXXXXXX`

> ⚠️ **Security Note**: Never commit your secret keys to version control!

## Frontend Setup

### Step 1: Install Dependencies

The `razorpay_flutter` package is already added to `pubspec.yaml`. Install it:

```bash
flutter pub get
```

### Step 2: Configure Razorpay Keys

Open `lib/core/config/razorpay_config.dart` and replace the placeholder keys:

```dart
// Replace with your Test Key ID
static const String keyId = 'rzp_test_YOUR_KEY_ID_HERE';

// Replace with your Test Key Secret (for backend use)
static const String keySecret = 'YOUR_KEY_SECRET_HERE';
```

**Example:**
```dart
static const String keyId = 'rzp_test_1234567890ABC';
static const String keySecret = 'abcdef1234567890';
```

### Step 3: Customize Company Details (Optional)

In the same file, you can customize:

```dart
// Company Information
static const String companyName = 'MediXpert Pharmacy'; // Your business name
static const String companyLogo = 'https://your-logo-url.com/logo.png';
static const String contactEmail = 'support@medixpert.com';
static const String contactPhone = '+919876543210';

// Theme color (hex without #)
static const String themeColor = '4F46E5'; // Indigo
```

### Step 4: Android Setup

Add Razorpay permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application
        ...
        android:usesCleartextTraffic="true">

        <!-- Add Razorpay activity -->
        <activity
            android:name="com.razorpay.CheckoutActivity"
            android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
            android:exported="true"
            android:theme="@style/CheckoutTheme">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

Add ProGuard rules in `android/app/proguard-rules.pro`:

```proguard
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
  public void onPayment*(...);
}
```

### Step 5: iOS Setup

Add to `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

Run:
```bash
cd ios && pod install && cd ..
```

## Backend Setup

The frontend expects these Django REST API endpoints:

### Endpoint 1: Create Razorpay Order

**URL:** `POST /api/pharmacy/razorpay/create-order/`

**Request Body:**
```json
{
    "amount": 450.00,
    "notes": "Delivery instructions...",
    "voucher_code": "MEDIXPERT"
}
```

**Response:**
```json
{
    "razorpay_order_id": "order_XXXXXXXXXXXX",
    "amount": 45000,
    "currency": "INR",
    "status": "created"
}
```

**Python/Django Example:**

```python
# views.py
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
import razorpay

RAZORPAY_KEY_ID = 'rzp_test_YOUR_KEY_ID'
RAZORPAY_KEY_SECRET = 'YOUR_KEY_SECRET'

client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_razorpay_order(request):
    """Create Razorpay order before payment"""
    try:
        amount = request.data.get('amount')
        notes = request.data.get('notes', '')
        voucher_code = request.data.get('voucher_code', '')

        # Amount in paise (multiply by 100)
        amount_in_paise = int(float(amount) * 100)

        # Create Razorpay order
        razorpay_order = client.order.create({
            'amount': amount_in_paise,
            'currency': 'INR',
            'notes': {
                'customer_notes': notes,
                'voucher_code': voucher_code,
            }
        })

        return Response({
            'razorpay_order_id': razorpay_order['id'],
            'amount': razorpay_order['amount'],
            'currency': razorpay_order['currency'],
            'status': razorpay_order['status'],
        })

    except Exception as e:
        return Response({'error': str(e)}, status=400)
```

### Endpoint 2: Verify Payment and Create Order

**URL:** `POST /api/pharmacy/razorpay/verify-payment/`

**Request Body:**
```json
{
    "razorpay_order_id": "order_XXXXXXXXXXXX",
    "razorpay_payment_id": "pay_XXXXXXXXXXXX",
    "razorpay_signature": "signature_string",
    "notes": "Delivery instructions...",
    "voucher_code": "MEDIXPERT"
}
```

**Response:**
```json
{
    "id": 123,
    "status": "confirmed",
    "payment_status": "paid",
    "total_amount": 450.00,
    "created_at": "2025-01-15T10:30:00Z",
    ...
}
```

**Python/Django Example:**

```python
# views.py
import hmac
import hashlib

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_razorpay_payment(request):
    """Verify payment and create pharmacy order"""
    try:
        razorpay_order_id = request.data.get('razorpay_order_id')
        razorpay_payment_id = request.data.get('razorpay_payment_id')
        razorpay_signature = request.data.get('razorpay_signature')

        # Verify signature
        generated_signature = hmac.new(
            RAZORPAY_KEY_SECRET.encode(),
            f"{razorpay_order_id}|{razorpay_payment_id}".encode(),
            hashlib.sha256
        ).hexdigest()

        if generated_signature != razorpay_signature:
            return Response({'error': 'Invalid payment signature'}, status=400)

        # Fetch payment details from Razorpay
        payment = client.payment.fetch(razorpay_payment_id)

        if payment['status'] != 'captured' and payment['status'] != 'authorized':
            return Response({'error': 'Payment not successful'}, status=400)

        # Get user's cart
        cart = PharmacyCart.objects.filter(user=request.user).first()
        if not cart:
            return Response({'error': 'Cart not found'}, status=404)

        # Create order
        order = PharmacyOrder.objects.create(
            user=request.user,
            cart=cart,
            total_amount=cart.total_amount,
            status='confirmed',
            payment_status='paid',
            payment_method='razorpay',
            razorpay_order_id=razorpay_order_id,
            razorpay_payment_id=razorpay_payment_id,
            notes=request.data.get('notes', ''),
            voucher_code=request.data.get('voucher_code', ''),
        )

        # Clear cart
        cart.cart_items.all().delete()

        # Serialize and return order
        from .serializers import PharmacyOrderSerializer
        serializer = PharmacyOrderSerializer(order)
        return Response(serializer.data)

    except Exception as e:
        return Response({'error': str(e)}, status=400)
```

### Backend Dependencies

Install Razorpay Python SDK:

```bash
pip install razorpay
```

Add to `requirements.txt`:
```
razorpay==1.4.1
```

### URL Configuration

```python
# urls.py
from django.urls import path
from . import views

urlpatterns = [
    # ... existing urls
    path('razorpay/create-order/', views.create_razorpay_order),
    path('razorpay/verify-payment/', views.verify_razorpay_payment),
]
```

## Testing

### Test Mode

1. Use **Test API Keys** in `razorpay_config.dart`
2. Run the app: `flutter run`
3. Add items to cart and proceed to checkout
4. Select "Pay Online with Razorpay"
5. Use test card credentials:

**Test Cards:**
- **Success:** 4111 1111 1111 1111
- **CVV:** Any 3 digits
- **Expiry:** Any future date
- **Name:** Any name

**Test UPI:**
- **VPA:** success@razorpay

**Test Wallets:**
- All wallets work in test mode

### Debug Logs

Check console logs for:
```
✅ Payment Success: pay_XXXXXXXXXXXX
✅ Order ID: order_XXXXXXXXXXXX
✅ Signature: XXXXXXXXXXXX
```

## Going Live

### 1. Complete KYC

- Submit business documents on Razorpay Dashboard
- Wait for verification (1-2 business days)
- Receive activation email

### 2. Switch to Live Keys

```dart
// razorpay_config.dart
static const String keyId = 'rzp_live_YOUR_LIVE_KEY_ID';
static const String keySecret = 'YOUR_LIVE_KEY_SECRET';
```

Update backend as well!

### 3. Enable Payment Methods

On Razorpay Dashboard:
- Go to Settings → Configuration → Payment Methods
- Enable: UPI, Cards, Net Banking, Wallets
- Set payment capture to **Automatic**

### 4. Setup Webhooks (Recommended)

For handling payment failures, refunds, etc:

1. Go to Dashboard → Settings → Webhooks
2. Add webhook URL: `https://your-backend.com/api/razorpay/webhook/`
3. Select events: `payment.captured`, `payment.failed`, `refund.created`
4. Copy webhook secret

**Backend webhook handler:**
```python
@api_view(['POST'])
def razorpay_webhook(request):
    """Handle Razorpay webhook events"""
    webhook_secret = 'YOUR_WEBHOOK_SECRET'
    webhook_signature = request.headers.get('X-Razorpay-Signature')

    # Verify webhook signature
    generated_signature = hmac.new(
        webhook_secret.encode(),
        request.body,
        hashlib.sha256
    ).hexdigest()

    if generated_signature != webhook_signature:
        return Response({'error': 'Invalid signature'}, status=400)

    # Process event
    event = request.data.get('event')
    payload = request.data.get('payload')

    if event == 'payment.failed':
        # Handle failed payment
        pass
    elif event == 'refund.created':
        # Handle refund
        pass

    return Response({'status': 'ok'})
```

## Troubleshooting

### Payment Gateway Not Opening

**Issue:** Razorpay checkout doesn't open

**Solution:**
- Verify API key in `razorpay_config.dart`
- Check internet connection
- Review Android/iOS setup steps
- Check console for error logs

### Signature Verification Failed

**Issue:** Payment succeeds but verification fails

**Solution:**
- Ensure backend uses same Key Secret
- Check signature generation logic
- Verify order ID matches

### Payment Stuck on Processing

**Issue:** Payment shows processing indefinitely

**Solution:**
- Check backend endpoint is reachable
- Verify backend returns correct response format
- Check for CORS issues
- Review Django logs

### Dark Mode Colors Look Wrong

**Issue:** Payment UI colors don't match theme

**Solution:**
- The `RazorpayPaymentSheet` automatically uses `ThemeController`
- Check theme is properly initialized in `main.dart`
- Razorpay's native checkout uses its own theme

## Support

### Razorpay Support
- Documentation: [https://razorpay.com/docs/](https://razorpay.com/docs/)
- Support: [https://razorpay.com/support/](https://razorpay.com/support/)
- Phone: 1800-102-0480 (India)

### Test Credentials
- All test credentials: [https://razorpay.com/docs/payments/payments/test-card-details/](https://razorpay.com/docs/payments/payments/test-card-details/)

## Next Steps

After integration:

1. ✅ Test thoroughly in test mode
2. ✅ Complete KYC verification
3. ✅ Switch to live keys
4. ✅ Test with small real transaction
5. ✅ Monitor first few transactions
6. ✅ Setup webhooks for automation
7. ✅ Implement refund flow (if needed)

---

**Built with ❤️ for HMS Customer App**
