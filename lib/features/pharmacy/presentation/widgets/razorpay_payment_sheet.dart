import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';

class RazorpayPaymentSheet extends StatefulWidget {
  final double amount;
  final String orderId;
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const RazorpayPaymentSheet({
    super.key,
    required this.amount,
    required this.orderId,
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<RazorpayPaymentSheet> createState() => _RazorpayPaymentSheetState();
}

class _RazorpayPaymentSheetState extends State<RazorpayPaymentSheet> {
  bool isProcessing = false;
  String selectedMethod = 'upi';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isProcessing
                ? _buildProcessingView()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAmountSection(),
                        const Divider(height: 1),
                        _buildPaymentMethods(),
                      ],
                    ),
                  ),
          ),
          if (!isProcessing) _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/razorpay_logo.png',
            height: 24,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.payment,
              color: Color(0xFF3395FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Razorpay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3395FF),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MediXpert Pharmacy',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Order #${widget.orderId}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Amount to pay',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '₹${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Select Payment Method',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        _buildPaymentOption(
          'upi',
          'UPI',
          Icons.account_balance_wallet_outlined,
          'Pay via any UPI app',
        ),
        _buildPaymentOption(
          'card',
          'Card',
          Icons.credit_card,
          'Credit / Debit / ATM Card',
        ),
        _buildPaymentOption(
          'netbanking',
          'Net Banking',
          Icons.account_balance,
          'Select your bank',
        ),
        _buildPaymentOption(
          'wallet',
          'Wallets',
          Icons.wallet,
          'Paytm, PhonePe, Amazon Pay',
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
      String value, String title, IconData icon, String subtitle) {
    final isSelected = selectedMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
          color: isSelected ? const Color(0xFF3395FF).withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3395FF).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF3395FF) : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3395FF),
                size: 24,
              )
            else
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3395FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Pay ₹${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF3395FF),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing Payment...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please do not press back or close the app',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment() {
    setState(() {
      isProcessing = true;
    });

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);

        // Show payment selection dialog
        _showPaymentResultDialog();
      }
    });
  }

  void _showPaymentResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Simulate Payment Result'),
        content: const Text(
          'This is a dummy payment integration.\nChoose the result you want to simulate:',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onFailure();
            },
            child: const Text(
              'Simulate Failure',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Simulate Success'),
          ),
        ],
      ),
    );
  }
}
