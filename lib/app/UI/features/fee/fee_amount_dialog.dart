import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';

class FeeAmountDialog extends StatefulWidget {
  final double pendingAmount;

  const FeeAmountDialog({super.key, required this.pendingAmount});

  @override
  State<FeeAmountDialog> createState() => _FeeAmountDialogState();
}

class _FeeAmountDialogState extends State<FeeAmountDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.pendingAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      ),
      backgroundColor: AppColors.colorWhite,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppValues.paddingDefault),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: AppValues.fontSizeTitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Specify the amount you would like to pay towards your pending school fees.',
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: AppValues.fontSizeSmall + 1,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: AppValues.fontSizeBody,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount to pay',
                      labelStyle: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: AppValues.fontSizeBody,
                        fontWeight: FontWeight.w600,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Enter amount',
                      hintStyle: const TextStyle(
                        color: AppColors.borderGrey,
                        fontSize: AppValues.fontSizeBody,
                      ),
                      prefixText: '₹ ',
                      prefixStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        fontSize: AppValues.fontSizeBody,
                      ),
                      helperText:
                          'Pending: ₹${widget.pendingAmount.toStringAsFixed(0)}',
                      helperStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: AppValues.fontSizeSmall,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppValues.paddingDefault,
                        vertical: AppValues.paddingMedium,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusDefault,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderGrey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusDefault,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusDefault,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.errorColor,
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusDefault,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.errorColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Enter a valid amount';
                      }
                      if (parsed > widget.pendingAmount) {
                        return 'Cannot exceed pending amount';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: EdunestButton(
                        title: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        useGradient: false,
                        backgroundColor: AppColors.lightBackground,
                        textColor: AppColors.darkText,
                        radius: AppValues.radius12,
                        height: 44,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: EdunestButton(
                        title: 'Proceed',
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.pop(
                              context,
                              double.parse(_controller.text.trim()),
                            );
                          }
                        },
                        radius: AppValues.radius12,
                        height: 44,
                        gradientColors: const [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
