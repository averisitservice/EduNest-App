import 'package:edunest/app/UI/features/fee/fee_amount_dialog.dart';
import 'package:edunest/app/UI/features/fee/fee_payment_handler.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/fee_detail_model.dart';
import 'package:edunest/app/data/repository/fee_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeePaymentPage extends StatefulWidget {
  const FeePaymentPage({super.key});

  @override
  State<FeePaymentPage> createState() => _FeePaymentPageState();
}

class _FeePaymentPageState extends State<FeePaymentPage> {
  final FeeRepo _feeRepo = FeeRepo();
  late final FeePaymentHandler _paymentHandler;

  FeeDetailModel? _detail;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
    _paymentHandler = FeePaymentHandler(
      onPaymentStarted: () => setState(() => _isProcessing = true),
      onPaymentSuccess: () {
        setState(() => _isProcessing = false);
        _loadDetail();
      },
      onPaymentFailed: () => setState(() => _isProcessing = false),
      showMessage: (msg, {isError = false}) =>
          _showSnack(msg, isError: isError),
    );
  }

  @override
  void dispose() {
    _paymentHandler.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _feeRepo.getFeeDetail();
      if (!mounted) return;
      setState(() => _detail = detail);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAmountDialog() async {
    final detail = _detail;
    if (detail == null || detail.pendingAmount <= 0) return;

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return FeeAmountDialog(pendingAmount: detail.pendingAmount);
      },
    );

    if (amount != null) {
      _paymentHandler.startPayment(amount);
    }
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
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverviewCard(detail),
            const SizedBox(height: 16),
            _buildPaymentHistory(detail),
            const SizedBox(height: 16),
            _buildNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(FeeDetailModel detail) {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingDefault),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        border: Border.all(color: AppColors.lightBackground),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fee Overview',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: AppValues.fontSizeDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAmountColumn(
                  'Total Fee',
                  detail.totalFee,
                  AppColors.darkText,
                ),
              ),
              Expanded(
                child: _buildAmountColumn(
                  'Paid Amount',
                  detail.paidAmount,
                  AppColors.notificationGreenIcon,
                ),
              ),
              Expanded(
                child: _buildAmountColumn(
                  'Pending Amount',
                  detail.pendingAmount,
                  detail.pendingAmount > 0
                      ? AppColors.notificationOrangeIcon
                      : AppColors.notificationGreenIcon,
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          if (detail.pendingAmount > 0) ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.blueBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: AppValues.iconSize22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount Due',
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: AppValues.fontSizeSmall,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${detail.pendingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: AppValues.fontSizeTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                EdunestButton(
                  title: 'Pay Now',
                  onPressed: _isProcessing ? null : _showAmountDialog,
                  isLoading: _isProcessing,
                  radius: AppValues.radius12,
                  fontSize: AppValues.fontSizeBody,
                  width: 110,
                  height: 44,
                  verticalPadding: 0,
                  gradientColors: const [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ],
            ),
          ] else ...[
            Row(
              children: const [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.notificationGreenIcon,
                  size: AppValues.iconSize20,
                ),
                SizedBox(width: 10),
                Text(
                  'Fees fully paid for this academic year.',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: AppValues.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountColumn(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkGrey,
            fontSize: AppValues.fontSizeSmall,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontSize: AppValues.fontSizeSubTitle - 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(FeeDetailModel detail) {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingDefault),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        border: Border.all(color: AppColors.lightBackground),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Past Payments',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: AppValues.fontSizeDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (detail.payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppValues.paddingMedium),
              child: Text(
                'No payments made yet.',
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: AppValues.fontSizeBody,
                ),
              ),
            )
          else
            for (int i = 0; i < detail.payments.length; i++) ...[
              _buildPaymentRow(detail.payments[i]),
              if (i != detail.payments.length - 1) const Divider(height: 24),
            ],
        ],
      ),
    );
  }

  Widget _buildPaymentRow(FeePaymentItem payment) {
    final displayDate = payment.paymentDate.isNotEmpty
        ? '${DateUtil.getDay(payment.paymentDate)} ${DateUtil.getMonth(payment.paymentDate)} ${DateUtil.getYear(payment.paymentDate)}'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.notificationGreenBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.notificationGreenIcon,
            size: AppValues.iconSize20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayDate.isNotEmpty
                    ? 'Paid on: $displayDate'
                    : payment.paymentMode,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: AppValues.fontSizeBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Transaction ID: ${payment.receiptNo}',
                style: const TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: AppValues.fontSizeSmall,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${payment.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: AppColors.notificationGreenIcon,
                fontSize: AppValues.fontSizeBody,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppValues.margin4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.notificationGreenBg,
                borderRadius: BorderRadius.circular(AppValues.radius20),
              ),
              child: const Text(
                'Paid',
                style: TextStyle(
                  color: AppColors.notificationGreenIcon,
                  fontSize: AppValues.fontSizeCaption + 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingDefault),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: AppValues.iconSize20,
          ),
          SizedBox(width: AppValues.margin10),
          Expanded(
            child: Text(
              'Please pay the pending amount before the due date to avoid late fee charges.',
              style: TextStyle(
                color: AppColors.darkGrey,
                fontSize: AppValues.fontSizeSmall,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
