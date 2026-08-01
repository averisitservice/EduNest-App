import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/repository/leave_repo.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_text_field.dart';
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

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _leaveDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _leaveDate = picked);
    }
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason for leave.')),
      );
      return;
    }

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
        title: const Text(
          'Leave Request',
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(16.0),
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.blueBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Request Details',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Please provide the details for your leave request.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.darkGrey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          _sectionLabel(Icons.calendar_today_rounded, 'Leave Date'),
          const SizedBox(height: 8),
          _buildDateField(),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select the date for your leave.',
              style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          _sectionLabel(Icons.edit_outlined, 'Reason'),
          const SizedBox(height: 8),
          EdunestTextField(
            labelText: '',
            hintText: 'Enter leave reason...',
            controller: _reasonController,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
            padding: const EdgeInsets.all(AppValues.paddingDefault),
          ),
          const SizedBox(height: 6),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Please provide the reason for your leave request.',
              style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          EdunestButton(
            title: 'Submit Request',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      borderRadius: BorderRadius.circular(AppValues.radiusDefault),
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(AppValues.radiusDefault),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.darkGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(_leaveDate),
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
