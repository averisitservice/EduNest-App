import 'package:edunest/app/UI/features/leave/leave_request_page.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/leave/leave_model.dart';
import 'package:edunest/app/data/repository/leave_repo.dart';
import 'package:edunest/app/global_widgets/edunest_confirm_dialog.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
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
        title: const Text(
          'My Leaves',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
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
          children: const [
            SizedBox(height: 80),
            EdunestEmptyState(subtitle: 'No leave requests yet.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaves,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      margin: const EdgeInsets.only(bottom: AppValues.radius12),
      padding: const EdgeInsets.all(AppValues.paddingDefault),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
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
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.blueBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.exit_to_app_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayDate,
                        style: const TextStyle(
                          color: AppColors.darkText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(leave.status),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  leave.reason,
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(width: 8),
            isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.errorColor,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorColor,
                      size: 22,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        upper,
        style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}
