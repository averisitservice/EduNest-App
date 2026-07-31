import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/fee_order_model.dart';
import 'package:edunest/app/data/model/student_model.dart';
import 'package:edunest/app/data/repository/fee_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class FeePaymentPage extends StatefulWidget {
  const FeePaymentPage({super.key});

  @override
  State<FeePaymentPage> createState() => _FeePaymentPageState();
}

class _FeePaymentPageState extends State<FeePaymentPage> {
  static const double dueAmount = 1000;

  final FeeRepo _feeRepo = FeeRepo();
  final Razorpay _razorpay = Razorpay();

  StudentModel? _student;
  FeeOrderModel? _pendingOrder;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadStudent() async {
    final student = await CommonService.getStudent();
    if (!mounted) return;
    setState(() => _student = student);
  }

  Future<void> _startPayment() async {
    setState(() => _isProcessing = true);
    try {
      final order = await _feeRepo.createFeeOrder();
      _pendingOrder = order;

      final options = {
        'key': order.keyId,
        'amount': (order.amount * 100).round(),
        'currency': order.currency,
        'order_id': order.razorpayOrderRef,
        'name': 'EduNest',
        'description': 'School Fee Payment',
        'prefill': {
          'contact': _student?.mobileNo ?? '',
          'email': _student?.email ?? '',
        },
        'theme': {'color': '#0F65D6'},
      };

      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnack(ErrorHelper.toApiException(e).message, isError: true);
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    final order = _pendingOrder;
    if (order == null) return;

    try {
      final verified = await _feeRepo.verifyFeePayment(
        razorpayOrderId: order.razorpayOrderId,
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (verified) {
        _showSnack('Payment successful! Fee of ₹${dueAmount.toStringAsFixed(0)} received.');
      } else {
        _showSnack('Payment could not be verified. Please contact the school office.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnack(ErrorHelper.toApiException(e).message, isError: true);
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showSnack(response.message ?? 'Payment failed. Please try again.', isError: true);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _showSnack('Opened ${response.walletName ?? 'external wallet'} for payment.');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.iconGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fee Details',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BackGroud.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                _buildBreakdownCard(),
                const SizedBox(height: 24),
                _buildPayButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Amount Due',
            style: TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '₹${dueAmount.toStringAsFixed(0)}',
            style: const TextStyle(color: AppColors.colorWhite, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.lightText, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _student != null
                      ? '${_student!.studentName} • ${_student!.displayClass}'
                      : 'Loading student details...',
                  style: const TextStyle(color: AppColors.lightText, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingDefault),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        border: Border.all(color: AppColors.lightBackground),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Breakdown',
            style: TextStyle(color: AppColors.darkText, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow('Tuition Fee', dueAmount),
          const Divider(height: 24),
          _buildBreakdownRow('Total Payable', dueAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.darkText : AppColors.darkGrey,
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: isTotal ? AppColors.primary : AppColors.darkText,
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.radiusLarge)),
          elevation: 0,
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: AppColors.colorWhite, strokeWidth: 2.4),
              )
            : Text(
                'Pay ₹${dueAmount.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.colorWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
