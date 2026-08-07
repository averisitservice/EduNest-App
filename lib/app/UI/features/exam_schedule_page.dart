import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/exam/exam_schedule_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExamSchedulePage extends StatefulWidget {
  const ExamSchedulePage({super.key});

  @override
  State<ExamSchedulePage> createState() => _ExamSchedulePageState();
}

class _ExamSchedulePageState extends State<ExamSchedulePage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  int _selectedTabIndex = 0;
  ExamsModel? _exams;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final exams = await featuresRepo.getStudentExams();
      if (!mounted) return;
      setState(() => _exams = exams);
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
        title: Text(
          'Exam Schedule',
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

    final exams = _exams;
    final upcoming = exams?.upcoming ?? [];
    final past = exams?.past ?? [];
    final currentExams = _selectedTabIndex == 0 ? upcoming : past;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: context.rw(16.0),
        vertical: context.rh(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabSwitcher(),
          SizedBox(height: context.rh(18)),
          Text(
            _selectedTabIndex == 0 ? 'Upcoming Exams' : 'Past Exams',
            style: TextStyle(
              fontSize: context.rf(AppValues.fontSizeDefault),
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: context.rh(12)),
          if (currentExams.isEmpty)
            SizedBox(
              height: context.rh(260),
              child: EdunestEmptyState(
                subtitle: _selectedTabIndex == 0
                    ? 'No upcoming exams.'
                    : 'No past exams.',
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentExams.length,
              itemBuilder: (context, index) =>
                  _buildExamCard(currentExams[index]),
            ),
          SizedBox(height: context.rh(6)),
          if (_selectedTabIndex == 0 && upcoming.isNotEmpty)
            _buildSummaryCard(upcoming),
          SizedBox(height: context.rh(14)),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: context.rh(48),
      padding: EdgeInsets.all(context.rw(AppValues.margin4)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(14)),
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
        children: [_buildTab('Upcoming Exams', 0), _buildTab('Past Exams', 1)],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.rf(AppValues.fontSizeBody),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.colorWhite : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamCard(ExamItem item) {
    final isUpcoming = item.status == 'Upcoming';

    return Container(
      margin: EdgeInsets.only(bottom: context.rh(AppValues.radius12)),
      padding: EdgeInsets.all(context.rw(14)),
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
        children: [
          Container(
            width: context.rw(66),
            height: context.rh(72),
            decoration: BoxDecoration(
              color: AppColors.blueBackground,
              borderRadius: BorderRadius.circular(context.rw(14)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateUtil.getDay(item.examDate),
                  style: TextStyle(
                    fontSize: context.rf(22),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: context.rh(2)),
                Text(
                  DateUtil.getMonth(item.examDate),
                  style: TextStyle(
                    fontSize: context.rf(AppValues.fontSizeSmall),
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
                Text(
                  DateUtil.getYear(item.examDate),
                  style: TextStyle(
                    fontSize: context.rf(11),
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: context.rw(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subjectName,
                  style: TextStyle(
                    fontSize: context.rf(AppValues.fontSizeDefault),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: context.rh(6)),

                Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: context.rw(15),
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: context.rw(6)),
                    Expanded(
                      child: Text(
                        item.examName,
                        style: TextStyle(
                          fontSize: context.rf(12.5),
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rh(4)),
                Row(
                  children: [
                    Icon(
                      Icons.stars_outlined,
                      size: context.rw(15),
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: context.rw(6)),
                    Expanded(
                      child: Text(
                        '${item.maxMarks} Marks',
                        style: TextStyle(
                          fontSize: context.rf(12.5),
                          color: AppColors.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: context.rw(8)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.rw(10),
              vertical: context.rh(5),
            ),
            decoration: BoxDecoration(
              color: isUpcoming
                  ? AppColors.notificationOrangeBg
                  : AppColors.notificationGreenBg,
              borderRadius: BorderRadius.circular(context.rw(AppValues.radius20)),
            ),
            child: Text(
              item.status,
              style: TextStyle(
                fontSize: context.rf(11.5),
                fontWeight: FontWeight.w600,
                color: isUpcoming
                    ? AppColors.notificationOrangeIcon
                    : AppColors.notificationGreenIcon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<ExamItem> upcoming) {
    final next = upcoming.first;
    return Container(
      padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
        border: Border.all(color: AppColors.lightBackground),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: context.rw(44),
                  height: context.rw(44),
                  decoration: const BoxDecoration(
                    color: AppColors.colorWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                    size: context.rw(AppValues.iconSize22),
                  ),
                ),
                SizedBox(width: context.rw(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Upcoming',
                        style: TextStyle(
                          fontSize: context.rf(11.5),
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: context.rh(2)),
                      Text(
                        '${upcoming.length}',
                        style: TextStyle(
                          fontSize: context.rf(AppValues.fontSizeTitle),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: context.rh(AppValues.iconLargeSize),
            margin: EdgeInsets.symmetric(
              horizontal: context.rw(AppValues.smallMargin),
            ),
            color: AppColors.borderGrey,
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: context.rw(44),
                  height: context.rw(44),
                  decoration: const BoxDecoration(
                    color: AppColors.colorWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: AppColors.primary,
                    size: context.rw(AppValues.iconSize22),
                  ),
                ),
                SizedBox(width: context.rw(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Exam',
                        style: TextStyle(
                          fontSize: context.rf(11.5),
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: context.rh(2)),
                      Text(
                        '${DateUtil.getDay(next.examDate)} ${DateUtil.getMonth(next.examDate)}',
                        style: TextStyle(
                          fontSize: context.rf(13.5),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        next.subjectName,
                        style: TextStyle(
                          fontSize: context.rf(11.5),
                          color: AppColors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
