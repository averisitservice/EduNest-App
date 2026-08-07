import 'package:edunest/app/UI/features/leave/leave_request_page.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/leave/leave_model.dart';
import 'package:edunest/app/data/repository/leave_repo.dart';
import 'package:edunest/app/global_widgets/edunest_confirm_dialog.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LeaveListPage extends StatefulWidget {
  const LeaveListPage({super.key});

  @override
  State<LeaveListPage> createState() => _LeaveListPageState();
}

class _LeaveListPageState extends State<LeaveListPage> {
  final LeaveRepo leaveRepo = LeaveRepo();

  List<LeaveModel> _leaves = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leaves = await leaveRepo.getLeaveList();
      if (!mounted) return;
      setState(() => _leaves = leaves);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openNewRequest() async {
    final submitted = await Get.to(() => const LeaveRequestPage());
    if (submitted == true) {
      _loadLeaves();
    }
  }

  Future<void> _confirmDelete(LeaveModel leave) async {
    final confirmed = await EdunestConfirmDialog.show(
      context,
      title: 'Delete Leave Request',
      message: 'Are you sure you want to delete this leave request?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true) return;

    setState(() => _deletingId = leave.leaveId);
    try {
      await leaveRepo.deleteLeave(leave.leaveId);
      if (!mounted) return;
      setState(() => _leaves.removeWhere((l) => l.leaveId == leave.leaveId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request deleted.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _deletingId = null);
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
          'My Leaves',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: context.rf(AppValues.fontSizeTitle),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
            onPressed: _openNewRequest,
          ),
        ],
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
          padding: EdgeInsets.all(context.rw(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rf(AppValues.fontSizeBody),
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: context.rh(16)),
              ElevatedButton(onPressed: _loadLeaves, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLeaves,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: context.rh(80)),
            const EdunestEmptyState(subtitle: 'No leave requests yet.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaves,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(16.0),
          vertical: context.rh(12.0),
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _leaves.length,
        itemBuilder: (context, index) => _buildLeaveCard(_leaves[index]),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveModel leave) {
    final displayDate = leave.leaveDate.isNotEmpty
        ? '${DateUtil.getDay(leave.leaveDate)} ${DateUtil.getMonth(leave.leaveDate)} ${DateUtil.getYear(leave.leaveDate)}'
        : '';
    final isPending = leave.status.toUpperCase() == 'PENDING';
    final isDeleting = _deletingId == leave.leaveId;

    return Container(
      margin: EdgeInsets.only(bottom: context.rh(AppValues.radius12)),
      padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
        border: Border.all(color: AppColors.lightBackground),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.02),
            blurRadius: AppValues.smallMargin,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.rw(44),
            height: context.rw(44),
            decoration: const BoxDecoration(
              color: AppColors.blueBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.exit_to_app_rounded,
              color: AppColors.primary,
              size: context.rw(22),
            ),
          ),
          SizedBox(width: context.rw(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayDate,
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontSize: context.rf(15),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(leave.status),
                  ],
                ),
                SizedBox(height: context.rh(6)),
                Text(
                  leave.reason,
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: context.rf(13),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            SizedBox(width: context.rw(8)),
            isDeleting
                ? SizedBox(
                    width: context.rw(20),
                    height: context.rw(20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.errorColor,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                      size: context.rw(22),
                    ),
                    onPressed: () => _confirmDelete(leave),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final upper = status.toUpperCase();
    Color bg;
    Color fg;
    switch (upper) {
      case 'APPROVED':
        bg = AppColors.notificationGreenBg;
        fg = AppColors.notificationGreenIcon;
        break;
      case 'REJECTED':
        bg = AppColors.notificationRedBg;
        fg = AppColors.notificationRedIcon;
        break;
      default:
        bg = AppColors.notificationAmberBg;
        fg = AppColors.notificationAmberIcon;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(8),
        vertical: context.rh(3),
      ),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(context.rw(6))),
      child: Text(
        upper,
        style: TextStyle(color: fg, fontSize: context.rf(10.5), fontWeight: FontWeight.bold),
      ),
    );
  }
}
