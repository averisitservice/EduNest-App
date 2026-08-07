import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_divider.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open attachment.')),
      );
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
          'Homework Details',
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
    final filename = _getFileName(item.attachmentUrl ?? '');
    final hasAttachment =
        item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty;

    final subjectColor = SubjectIconService.colorFor(item.subjectName);
    final subjectBg = SubjectIconService.bgColorFor(item.subjectName);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.rw(16.0),
              vertical: context.rh(12.0),
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(item, subjectColor, subjectBg, assignedDate),
                SizedBox(height: context.rh(16)),
                _buildDescriptionCard(item),
                if (hasAttachment) ...[
                  SizedBox(height: context.rh(16)),
                  _buildAttachmentsCard(item, filename),
                ],
                SizedBox(height: context.rh(90)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    HomeworkDetailModel item,
    Color subjectColor,
    Color subjectBg,
    String assignedDate,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rw(16.0)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.rw(48),
                height: context.rw(48),
                decoration: BoxDecoration(
                  color: subjectBg,
                  borderRadius: BorderRadius.circular(context.rw(12)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  SubjectIconService.iconFor(item.subjectName),
                  color: subjectColor,
                  size: context.rw(22),
                ),
              ),
              SizedBox(width: context.rw(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: context.rf(17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.rh(6)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rw(10),
                        vertical: context.rh(4),
                      ),
                      decoration: BoxDecoration(
                        color: subjectBg,
                        borderRadius: BorderRadius.circular(context.rw(8)),
                      ),
                      child: Text(
                        item.subjectName,
                        style: TextStyle(
                          color: subjectColor,
                          fontSize: context.rf(12),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.rh(16)),
          const EdunestDivider(color: AppColors.lightBackground, height: 0),
          SizedBox(height: context.rh(12)),
          _buildInfoRow(
            Icons.event_available_rounded,
            'Assigned Date',
            assignedDate,
            AppColors.darkText,
          ),
          SizedBox(height: context.rh(10)),
          _buildInfoRow(
            Icons.person_rounded,
            'Teacher',
            item.teacherName,
            AppColors.darkText,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color valueColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: context.rw(16), color: AppColors.darkGrey),
        SizedBox(width: context.rw(8)),
        SizedBox(
          width: context.rw(100),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: context.rf(12.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: context.rf(13),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(HomeworkDetailModel item) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rw(16.0)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: context.rf(15),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.rh(12)),
          Text(
            item.description.isNotEmpty
                ? item.description
                : 'No description provided.',
            style: TextStyle(
              color: AppColors.darkGrey,
              fontSize: context.rf(13.5),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(HomeworkDetailModel item, String filename) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.rw(16.0)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: context.rf(15),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.rh(12)),
          if (_isImageAttachment(item.attachmentUrl!)) ...[
            InkWell(
              borderRadius: BorderRadius.circular(context.rw(12)),
              onTap: () => _openAttachment(item.attachmentUrl!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.rw(12)),
                child: Container(
                  height: context.rh(200),
                  width: double.infinity,
                  color: AppColors.lightBackground,
                  child: Image.network(
                    item.attachmentUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.darkGrey,
                              size: context.rw(40),
                            ),
                            SizedBox(height: context.rh(8)),
                            Text(
                              'Failed to load preview',
                              style: TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: context.rf(12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: context.rh(12)),
          ],
          InkWell(
            borderRadius: BorderRadius.circular(context.rw(12)),
            onTap: () => _openAttachment(item.attachmentUrl!),
            child: Container(
              padding: EdgeInsets.all(context.rw(12.0)),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(context.rw(12)),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.rw(8),
                      vertical: context.rh(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blueBackground,
                      borderRadius: BorderRadius.circular(context.rw(6)),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: context.rw(22),
                    ),
                  ),
                  SizedBox(width: context.rw(14)),
                  Expanded(
                    child: Text(
                      filename,
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: context.rf(13.5),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.file_download_outlined,
                    color: AppColors.primary,
                    size: context.rw(24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
