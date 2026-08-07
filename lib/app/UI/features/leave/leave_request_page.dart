import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/repository/leave_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_date_picker.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  final LeaveRepo leaveRepo = LeaveRepo();
  final TextEditingController _reasonController = TextEditingController();

  DateTime _leaveDate = DateTime.now();
  bool _isSubmitting = false;
  String? _reasonError;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await EdunestDatePicker.pick(
      context,
      initialDate: _leaveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _leaveDate = picked);
    }
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _reasonError = 'Please enter a reason for leave.');
      return;
    }
    setState(() => _reasonError = null);

    setState(() => _isSubmitting = true);
    try {
      await leaveRepo.submitLeave(leaveDate: _leaveDate, reason: reason);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted successfully.')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        title: Text(
          'Leave Request',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: context.rf(AppValues.fontSizeTitle),
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
            padding: EdgeInsets.symmetric(
              horizontal: context.rw(16.0),
              vertical: context.rh(12.0),
            ),
            physics: const BouncingScrollPhysics(),
            child: _buildFormCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rw(20.0)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(16.0)),
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
        children: [
          SizedBox(height: context.rh(24)),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: context.rw(18),
                  color: AppColors.primary,
                ),
                SizedBox(width: context.rw(8)),
                Text(
                  'Leave Date',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: context.rf(14.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(8)),
          _buildDateField(),
          SizedBox(height: context.rh(6)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select the date for your leave.',
              style: TextStyle(color: AppColors.darkGrey, fontSize: context.rf(12)),
            ),
          ),
          SizedBox(height: context.rh(20)),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: context.rw(18), color: AppColors.primary),
                SizedBox(width: context.rw(8)),
                Text(
                  'Reason',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: context.rf(14.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(8)),
          EdunestTextField(
            labelText: '',
            hintText: 'Enter leave reason...',
            controller: _reasonController,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
            onChanged: (_) {
              if (_reasonError != null) {
                setState(() => _reasonError = null);
              }
            },
          ),
          SizedBox(height: context.rh(6)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _reasonError ??
                  'Please provide the reason for your leave request.',
              style: TextStyle(
                color: _reasonError != null
                    ? AppColors.errorColor
                    : AppColors.darkGrey,
                fontSize: context.rf(12),
                fontWeight: _reasonError != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
          SizedBox(height: context.rh(24)),
          EdunestButton(
            title: 'Submit Request',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(14),
        ),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: context.rw(18),
              color: AppColors.darkGrey,
            ),
            SizedBox(width: context.rw(12)),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(_leaveDate),
                style: TextStyle(
                  color: AppColors.darkText,
                  fontSize: context.rf(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.calendar_month_rounded,
              size: context.rw(20),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
