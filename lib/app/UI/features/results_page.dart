import 'package:edunest/app/UI/features/result_detail_page.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/exam/result_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  StudentResultsModel? _results;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await featuresRepo.getStudentResults();
      if (!mounted) return;
      setState(() => _results = results);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _progressColor(double percentage) {
    if (percentage >= 75) return const Color(0xFF16A34A);
    if (percentage >= 50) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  String _progressMessage(double percentage) {
    if (percentage >= 75) return 'Good Job! Keep it up.';
    if (percentage >= 50) return 'Doing okay, aim higher.';
    return 'Needs improvement.';
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
          'Marks & Results',
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
                onPressed: _loadResults,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final results = _results;
    if (results == null || results.exams.isEmpty) {
      return const EdunestEmptyState(
        title: 'No Results Yet',
        subtitle: 'Your exam results will appear here once published.',
        icon: Icons.grade_outlined,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallProgressCard(results),
          const SizedBox(height: 20),
          if (results.subjects.isNotEmpty) ...[
            const Text(
              'Subject Wise Performance',
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSubjectPerformanceCard(results.subjects),
            const SizedBox(height: 20),
          ],
          const Text(
            'Recent Test / Exam Results',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...results.exams.map(
            (exam) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecentResultCard(exam),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(StudentResultsModel results) {
    final percentage = results.overallPercentage;
    final color = _progressColor(percentage);

    return Container(
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
            'Overall Progress',
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _progressMessage(percentage),
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (percentage / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${results.overallObtained}',
                            style: TextStyle(color: color),
                          ),
                          TextSpan(
                            text: ' / ${results.overallMax}',
                            style: const TextStyle(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformanceCard(List<SubjectResultItem> subjects) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: subjects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          final sub = subjects[index];
          final themeColor = SubjectIconService.colorFor(sub.subjectName);
          final circleBgColor = SubjectIconService.bgColorFor(sub.subjectName);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: circleBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  SubjectIconService.iconFor(sub.subjectName),
                  color: themeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.subjectName,
                      style: const TextStyle(
                        color: AppColors.darkText,
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (sub.percentage / 100).clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sub.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sub.obtained} / ${sub.max}',
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentResultCard(ExamResultItem exam) {
    final dateText = exam.examDate != null
        ? '${DateUtil.getDay(exam.examDate)} ${DateUtil.getMonth(exam.examDate)} ${DateUtil.getYear(exam.examDate)}'
        : '--';
    final color = _progressColor(exam.percentage);

    return InkWell(
      borderRadius: BorderRadius.circular(16.0),
      onTap: () => Get.to(() => ResultDetailPage(examId: exam.examId)),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF4FC),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.assignment_outlined,
                color: Color(0xFF0F65D6),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.examName,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${exam.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exam.obtained} / ${exam.max}',
                  style: const TextStyle(
                    color: AppColors.darkGrey,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.borderGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
