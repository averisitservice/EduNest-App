import 'package:edunest/app/UI/features/homework_detail_page.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  List<HomeworkModelItem> _homework = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  Future<void> _loadHomework() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final homework = await featuresRepo.getStudentHomework();
      if (!mounted) return;
      setState(() => _homework = homework);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          'Homework',
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

    if (_homework.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHomework,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'No homework posted yet.',
                style: TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHomework,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _homework.length,
        itemBuilder: (context, index) {
          final item = _homework[index];
          return _buildHomeworkCard(context, item);
        },
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, HomeworkModelItem item) {
    final displayDate = item.dueDate.isNotEmpty
        ? '${DateUtil.getDay(item.dueDate)} ${DateUtil.getMonth(item.dueDate)} ${DateUtil.getYear(item.dueDate)}'
        : '';

    return InkWell(
      onTap: () {
        Get.to(() => HomeworkDetailPage(homeworkId: item.id));
      },
      borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.blueBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                SubjectIconService.iconFor(item.subjectName),
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subjectName,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (displayDate.isNotEmpty) ...[
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.darkGrey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
