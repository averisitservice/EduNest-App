import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeworkDetailPage extends StatefulWidget {
  final int homeworkId;

  const HomeworkDetailPage({super.key, required this.homeworkId});

  @override
  State<HomeworkDetailPage> createState() => _HomeworkDetailPageState();
}

class _HomeworkDetailPageState extends State<HomeworkDetailPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  HomeworkDetailModel? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await featuresRepo.getHomeworkDetail(widget.homeworkId);
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

  String _getFileName(String path) {
    if (path.isEmpty) return 'Attachment';
    return path.split('/').last;
  }

  bool _isImageAttachment(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp');
  }

  bool _isOverdue(String dueDateStr) {
    if (dueDateStr.isEmpty) return false;
    try {
      final due = DateTime.parse(dueDateStr).toLocal();
      final dueOnly = DateTime(due.year, due.month, due.day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      return dueOnly.isBefore(todayOnly);
    } catch (_) {
      return false;
    }
  }

  void _submitHomework() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Homework submission is coming soon.')),
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
          'Homework Details',
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

    final item = _detail!;
    final assignedDate = item.updatedDate.isNotEmpty
        ? '${DateUtil.getDay(item.updatedDate)} ${DateUtil.getMonth(item.updatedDate)} ${DateUtil.getYear(item.updatedDate)}'
        : '--';
    final dueDate = item.dueDate.isNotEmpty
        ? '${DateUtil.getDay(item.dueDate)} ${DateUtil.getMonth(item.dueDate)} ${DateUtil.getYear(item.dueDate)}'
        : '--';
    final filename = _getFileName(item.attachmentUrl ?? '');
    final hasAttachment =
        item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty;
    final overdue = _isOverdue(item.dueDate);

    final subjectColor = SubjectIconService.colorFor(item.subjectName);
    final subjectBg = SubjectIconService.bgColorFor(item.subjectName);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(item, subjectColor, subjectBg, assignedDate, dueDate, overdue),
                const SizedBox(height: 16),
                _buildDescriptionCard(item),
                if (hasAttachment) ...[
                  const SizedBox(height: 16),
                  _buildAttachmentsCard(item, filename),
                ],
                const SizedBox(height: 16),
                _buildStatusCard(overdue),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
        _buildSubmitButton(),
      ],
    );
  }

  Widget _buildHeaderCard(
    HomeworkDetailModel item,
    Color subjectColor,
    Color subjectBg,
    String assignedDate,
    String dueDate,
    bool overdue,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: subjectBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  SubjectIconService.iconFor(item.subjectName),
                  color: subjectColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: subjectBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.subjectName,
                        style: TextStyle(
                          color: subjectColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.lightBackground),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.event_available_rounded, 'Assigned Date', assignedDate, AppColors.darkText),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.event_busy_rounded,
            'Due Date',
            dueDate,
            overdue ? AppColors.errorColor : AppColors.darkText,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.person_rounded, 'Teacher', item.teacherName, AppColors.darkText),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.darkGrey),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.darkGrey, fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(HomeworkDetailModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(color: AppColors.darkText, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            item.description.isNotEmpty ? item.description : 'No description provided.',
            style: const TextStyle(color: AppColors.darkGrey, fontSize: 13.5, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(HomeworkDetailModel item, String filename) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attachments',
            style: TextStyle(color: AppColors.darkText, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_isImageAttachment(item.attachmentUrl!)) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                color: AppColors.subtleBg,
                child: Image.network(
                  item.attachmentUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_outlined, color: AppColors.darkGrey, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load preview',
                            style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.subtleBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.fileBadgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.fileBadgeBorder),
                  ),
                  child: const Icon(Icons.description_outlined, color: AppColors.fileBadgeIcon, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    filename,
                    style: const TextStyle(color: AppColors.darkText, fontSize: 13.5, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.file_download_outlined, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool overdue) {
    final label = overdue ? 'Overdue' : 'Pending';
    final color = overdue ? AppColors.notificationRedIcon : AppColors.notificationGreenIcon;
    final bg = overdue ? AppColors.notificationRedBg : AppColors.notificationGreenBg;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Status',
            style: TextStyle(color: AppColors.darkText, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _submitHomework,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppValues.radiusDefault)),
            ),
            child: const Text(
              'Submit Homework',
              style: TextStyle(color: AppColors.colorWhite, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
