# Razorpay Payment Integration Guide

This document explains how to use the unified Razorpay payment integration for consultations, pharmacy orders, and other services.

## Overview

The payment integration uses the new unified DigiHMS API endpoints (`/api/orders/razorpay/`) that work across all service types:
- Consultation (appointments)
- Pharmacy
- Diagnostic
- Laboratory
- Nursing Care
- Home Healthcare

## Architecture

### Key Components

1. **Models** (`lib/core/data/models/razorpay_order.dart`):
   - `RazorpayOrderRequest` - Create order request DTO
   - `RazorpayOrderResponse` - Create order response DTO
   - `RazorpayVerificationRequest` - Payment verification request DTO
   - `RazorpayVerificationResponse` - Payment verification response DTO

2. **Repository** (`lib/core/data/repositories/order_repository.dart`):
   - `createRazorpayOrder()` - Creates order on backend
   - `verifyRazorpayPayment()` - Verifies payment on backend
   - `getFeeTypes()` - Gets available fee types
   - `listOrders()` - Lists all orders
   - `getOrderDetails()` - Gets order details

3. **Services**:
   - **RazorpayService** (`lib/core/services/razorpay_service.dart`):
     - Handles Razorpay SDK integration
     - Opens checkout UI
     - Manages payment callbacks
   - **PaymentService** (`lib/core/services/payment_service.dart`):
     - Orchestrates the complete payment flow
     - Manages order creation and verification
     - Provides high-level APIs for consultation and pharmacy payments

4. **UI Components**:
   - **PaymentSuccessPage** (`lib/core/features/payment/presentation/pages/payment_success_page.dart`):
     - Universal success page for all payment types
     - Shows order details and visit information

## Payment Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User initiates payment (Appointment/Pharmacy)           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Create Order on Backend                                  │
│    POST /api/orders/razorpay/create/                        │
│    → Returns razorpay_order_id, razorpay_key_id             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Open Razorpay Checkout                                   │
│    → User completes payment                                 │
│    → Razorpay returns payment_id, order_id, signature       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Verify Payment on Backend                                │
│    POST /api/orders/razorpay/verify/                        │
│    → Backend validates signature                            │
│    → Creates OPD bill for consultations                     │
│    → Marks order as paid                                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Show Success Page & Navigate                             │
└─────────────────────────────────────────────────────────────┘
```

## Usage Examples

### Consultation Payment

```dart
import 'package:get/get.dart';
import 'package:your_app/core/services/payment_service.dart';
import 'package:your_app/core/features/payment/presentation/pages/payment_success_page.dart';

Future<void> bookAppointmentWithPayment({
  required int appointmentId,
  required int patientId,
  required double consultationFee,
}) async {
  // Get payment service
  final paymentService = Get.find<PaymentService>();

  // Process payment
  await paymentService.processConsultationPayment(
    appointmentId: appointmentId,
    patientId: patientId,
    amount: consultationFee,
    notes: 'Online consultation payment',
    onSuccess: (verificationResponse) {
      // Payment successful!
      print('Order ID: ${verificationResponse.orderId}');
      print('Visit ID: ${verificationResponse.visitId}');
      print('Visit Number: ${verificationResponse.visitNumber}');
      print('Bill Number: ${verificationResponse.billNumber}');

      // Navigate to success page
      Get.to(() => PaymentSuccessPage(
        verificationResponse: verificationResponse,
        title: 'Appointment Confirmed!',
        subtitle: 'Your consultation has been booked successfully.',
        onContinue: () {
          // Navigate to appointment details or visit page
          Get.offAllNamed('/appointments');
        },
      ));
    },
    onFailure: (error) {
      // Payment failed
      Get.snackbar(
        'Payment Failed',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    },
  );
}
```

### Pharmacy Payment

```dart
import 'package:get/get.dart';
import 'package:your_app/features/pharmacy/presentation/controller/pharmacy_controller.dart';
import 'package:your_app/core/features/payment/presentation/pages/payment_success_page.dart';

Future<void> checkoutPharmacyOrder() async {
  final pharmacyController = Get.find<PharmacyController>();

  // Sync cart to backend first
  final synced = await pharmacyController.syncCartToBackend();
  if (!synced) {
    Get.snackbar('Error', 'Failed to sync cart');
    return;
  }

  // Process payment
  await pharmacyController.processPharmacyPaymentUnified(
    notes: 'Pharmacy order payment',
    onSuccess: (verificationResponse) {
      // Payment successful!
      Get.to(() => PaymentSuccessPage(
        verificationResponse: verificationResponse,
        title: 'Order Placed Successfully!',
        subtitle: 'Your pharmacy order has been confirmed.',
        onContinue: () {
          Get.offAllNamed('/orders');
        },
      ));
    },
    onFailure: (error) {
      Get.snackbar('Payment Failed', error);
    },
  );
}
```

### Advanced: Custom Payment with Fees

```dart
import 'package:your_app/core/data/models/razorpay_order.dart';
import 'package:your_app/core/services/payment_service.dart';

Future<void> customPaymentWithFees() async {
  final paymentService = Get.find<PaymentService>();

  // Define custom fees
  final fees = [
    OrderFee(feeTypeId: 1, amount: 50.0), // Service charge
    OrderFee(feeTypeId: 2), // GST (will be auto-calculated)
  ];

  await paymentService.processPharmacyPayment(
    items: [
      OrderItem(
        serviceId: 123,
        contentType: ContentType.pharmacyProduct,
        quantity: 2,
      ),
    ],
    patientId: patientId,
    fees: fees,
    notes: 'Custom pharmacy order with fees',
    onSuccess: (response) {
      // Handle success
    },
    onFailure: (error) {
      // Handle failure
    },
  );
}
```

## API Reference

### PaymentService Methods

#### `processConsultationPayment()`

Process payment for a consultation appointment.

**Parameters:**
- `appointmentId` (int, required) - The appointment ID
- `patientId` (int, required) - The patient ID
- `amount` (double?, optional) - Consultation fee
- `patientName` (String?, optional) - Patient name
- `patientEmail` (String?, optional) - Patient email
- `patientPhone` (String?, optional) - Patient phone
- `notes` (String?, optional) - Payment notes
- `onSuccess` (Function, required) - Success callback
- `onFailure` (Function, required) - Failure callback

**Example:**
```dart
await paymentService.processConsultationPayment(
  appointmentId: 456,
  patientId: 123,
  notes: 'Consultation payment',
  onSuccess: (response) => print('Success'),
  onFailure: (error) => print('Failed: $error'),
);
```

#### `processPharmacyPayment()`

Process payment for pharmacy orders.

**Parameters:**
- `items` (List<OrderItem>, required) - List of order items
- `patientId` (int, required) - The patient ID
- `fees` (List<OrderFee>?, optional) - Additional fees
- `notes` (String?, optional) - Payment notes
- `onSuccess` (Function, required) - Success callback
- `onFailure` (Function, required) - Failure callback

### PharmacyController Methods

#### `processPharmacyPaymentUnified()`

High-level method to process pharmacy payment using the unified API.

**Parameters:**
- `notes` (String?, optional) - Payment notes
- `fees` (List<OrderFee>?, optional) - Additional fees
- `onSuccess` (Function, required) - Success callback
- `onFailure` (Function, required) - Failure callback

## Service Types

Available service types for orders:

```dart
class ServiceType {
  static const String consultation = 'consultation';
  static const String diagnostic = 'diagnostic';
  static const String laboratory = 'laboratory';
  static const String pharmacy = 'pharmacy';
  static const String nursingCare = 'nursing_care';
  static const String homeHealthcare = 'home_healthcare';
}
```

## Content Types

Available content types for order items:

```dart
class ContentType {
  static const String appointment = 'appointment';
  static const String diagnosticOrder = 'diagnosticorder';
  static const String labOrder = 'laborder';
  static const String pharmacyProduct = 'pharmacyproduct';
}
```

## Error Handling

The integration handles various error scenarios:

1. **Authentication Errors** (401):
   - Automatically clears tokens
   - Shows "Session expired" message

2. **Validation Errors** (400):
   - Returns specific error messages from backend
   - Examples: "appointment_id required", "Razorpay not configured"

3. **Payment Verification Errors**:
   - Invalid signature
   - Order already paid
   - Order not found

4. **Network Errors**:
   - Connection timeouts
   - Server errors

## Testing

### Test Razorpay Credentials

Use these test credentials for development:

```dart
// lib/core/config/razorpay_config.dart
class RazorpayConfig {
  static const String keyId = 'rzp_test_xxxxxxxxxxxxx';
  static const String keySecret = 'YOUR_SECRET_KEY';
}
```

### Test Cards

- **Success**: 4111 1111 1111 1111
- **Failure**: 4000 0000 0000 0002

Any CVV, any future expiry date.

## Migration from Old API

If you're migrating from the old pharmacy-specific Razorpay endpoints:

### Old Approach (Pharmacy-specific)
```dart
// OLD - Don't use
final orderData = await repo.createRazorpayOrder(amount: 500.0);
final order = await repo.verifyRazorpayPayment(
  razorpayOrderId: orderId,
  razorpayPaymentId: paymentId,
  razorpaySignature: signature,
);
```

### New Approach (Unified)
```dart
// NEW - Recommended
await pharmacyController.processPharmacyPaymentUnified(
  onSuccess: (response) => handleSuccess(response),
  onFailure: (error) => handleFailure(error),
);
```

## Notes

1. **Patient ID**: The payment APIs require a `patient_id`. Currently, the `PaymentService.getCurrentPatientId()` method tries to get this from the user ID. In production, you may need to fetch the patient profile from an API endpoint.

2. **Appointment Creation**: The consultation payment flow assumes the appointment is already created. You should create the appointment first, then process the payment with the returned appointment ID.

3. **Backend Order Creation**: The unified API creates orders on the DigiHMS backend, which then creates Razorpay orders. This ensures better security and order tracking.

4. **Visit & OPD Bill**: For consultation orders, the backend automatically creates a Visit and OPD Bill after successful payment verification.

## Troubleshooting

### Payment not opening

- Check if Razorpay credentials are configured correctly
- Verify that the backend order creation succeeded
- Check console logs for errors

### Payment verification failed

- Ensure the signature is passed correctly from Razorpay callbacks
- Check if the order ID matches the backend order
- Verify backend Razorpay configuration

### Order not found error

- Make sure you're using the correct order_id (from create response)
- Check if the order exists in the database
- Verify authentication headers are set correctly

## Support

For issues or questions:
1. Check the console logs for detailed error messages
2. Verify API endpoint responses in network inspector
3. Consult the backend API documentation
4. Contact the DigiHMS support team
