import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesDetailPage extends StatefulWidget {
  final int noteId;

  const NotesDetailPage({super.key, required this.noteId});

  @override
  State<NotesDetailPage> createState() => _NotesDetailPageState();
}

class _NotesDetailPageState extends State<NotesDetailPage> {
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
      final detail = await featuresRepo.getNoteDetail(widget.noteId);
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
          'Notes Details',
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
    final filename = _getFileName(item.attachmentUrl ?? '');
    final hasAttachment =
        item.attachmentUrl != null && item.attachmentUrl!.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(16.0),
        vertical: context.rh(12.0),
      ),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                    SubjectIconService.iconFor(item.subjectName),
                    color: AppColors.primary,
                    size: context.rw(22),
                  ),
                ),
                SizedBox(width: context.rw(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subjectName,
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontSize: context.rf(18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.rh(6)),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: context.rf(13.5),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: context.rh(12)),
                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: context.rw(16),
                            color: AppColors.primary,
                          ),
                          SizedBox(width: context.rw(6)),
                          Text(
                            item.teacherName,
                            style: TextStyle(
                              color: AppColors.darkGrey,
                              fontSize: context.rf(13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(16)),

          Container(
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
                    fontSize: context.rf(16),
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
                    fontSize: context.rf(14),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.rh(16)),

          if (hasAttachment) ...[
            Container(
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
                      fontSize: context.rf(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.rh(12)),
                  InkWell(
                    borderRadius: BorderRadius.circular(context.rw(12)),
                    onTap: () => _openAttachment(item.attachmentUrl!),
                    child: Container(
                      padding: EdgeInsets.all(context.rw(12.0)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(context.rw(12)),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.rw(8),
                              vertical: context.rh(6),
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(context.rw(6)),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: const Color(0xFFDC2626),
                              size: context.rw(22),
                            ),
                          ),
                          SizedBox(width: context.rw(14)),
                          Expanded(
                            child: Text(
                              filename,
                              style: TextStyle(
                                color: AppColors.darkText,
                                fontSize: context.rf(14),
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
            ),
          ],
        ],
      ),
    );
  }
}
