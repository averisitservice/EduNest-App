import 'package:flutter/material.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/core/utils/responsive.dart';

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
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
      ),
      backgroundColor: AppColors.colorWhite,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: context.isFoldableOrTablet ? 420 : 320,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Enter Amount',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: context.rf(AppValues.fontSizeTitle),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.rh(12)),
                Text(
                  'Specify the amount you would like to pay towards your pending school fees.',
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: context.rf(AppValues.fontSizeSmall + 1),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.rh(20)),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontSize: context.rf(AppValues.fontSizeBody),
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkText,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount to pay',
                      labelStyle: TextStyle(
                        color: AppColors.darkText,
                        fontSize: context.rf(AppValues.fontSizeBody),
                        fontWeight: FontWeight.w600,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        color: AppColors.borderGrey,
                        fontSize: context.rf(AppValues.fontSizeBody),
                      ),
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                        fontSize: context.rf(AppValues.fontSizeBody),
                      ),
                      helperText:
                          'Pending: ₹${widget.pendingAmount.toStringAsFixed(0)}',
                      helperStyle: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: context.rf(AppValues.fontSizeSmall),
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.rw(AppValues.paddingDefault),
                        vertical: context.rh(AppValues.paddingMedium),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.borderGrey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.errorColor,
                          width: 1.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
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
                SizedBox(height: context.rh(24)),
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
                    SizedBox(width: context.rw(12)),
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
