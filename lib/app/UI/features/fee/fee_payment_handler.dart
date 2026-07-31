import 'package:flutter/foundation.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/data/repository/fee_repo.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class FeePaymentHandler {
  final FeeRepo _feeRepo = FeeRepo();
  final Razorpay _razorpay = Razorpay();

  final VoidCallback onPaymentStarted;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentFailed;
  final void Function(String message, {bool isError}) showMessage;

  int? _pendingOrderId;

  FeePaymentHandler({
    required this.onPaymentStarted,
    required this.onPaymentSuccess,
    required this.onPaymentFailed,
    required this.showMessage,
  }) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> startPayment(double amount) async {
    onPaymentStarted();
    try {
      final order = await _feeRepo.createFeeOrder(amount);

      final options = {
        'key': order.keyId,
        'amount': (order.amount * 100).round(),
        'currency': order.currency,
        'order_id': order.razorpayOrderRef,
        'name': 'EduNest',
        'description': 'School Fee Payment',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#0F65D6'},
      };

      _pendingOrderId = order.razorpayOrderId;
      _razorpay.open(options);
    } catch (e) {
      onPaymentFailed();
      showMessage(ErrorHelper.toApiException(e).message, isError: true);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final orderId = _pendingOrderId;
    if (orderId == null) {
      onPaymentFailed();
      return;
    }

    try {
      final verified = await _feeRepo.verifyFeePayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (verified) {
        showMessage('Payment successful.');
        onPaymentSuccess();
      } else {
        showMessage(
          'Payment could not be verified. Please contact the school office.',
          isError: true,
        );
        onPaymentFailed();
      }
    } catch (e) {
      showMessage(ErrorHelper.toApiException(e).message, isError: true);
      onPaymentFailed();
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    onPaymentFailed();
    showMessage(
      response.message ?? 'Payment failed. Please try again.',
      isError: true,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    onPaymentFailed();
    showMessage(
      'Opened ${response.walletName ?? 'external wallet'} for payment.',
    );
  }
}
