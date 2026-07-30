import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SubjectProgress {
  final String subjectName;
  final double percentage;
  final int score;
  final int total;
  final IconData? icon;
  final String? customIconText;
  final Color themeColor;
  final Color circleBgColor;

  const SubjectProgress({
    required this.subjectName,
    required this.percentage,
    required this.score,
    required this.total,
    this.icon,
    this.customIconText,
    required this.themeColor,
    required this.circleBgColor,
  });
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<SubjectProgress> subjects = const [
      SubjectProgress(
        subjectName: 'English',
        percentage: 0.85,
        score: 85,
        total: 100,
        icon: Icons.menu_book_rounded,
        themeColor: Color(0xFF0F65D6),
        circleBgColor: Color(0xFFEAF4FC),
      ),
      SubjectProgress(
        subjectName: 'Mathematics',
        percentage: 0.76,
        score: 76,
        total: 100,
        icon: Icons.calculate_outlined,
        themeColor: Color(0xFF16A34A),
        circleBgColor: Color(0xFFF0FDF4),
      ),
      SubjectProgress(
        subjectName: 'Science',
        percentage: 0.82,
        score: 82,
        total: 100,
        icon: Icons.science_outlined,
        themeColor: Color(0xFF9333EA),
        circleBgColor: Color(0xFFF3E8FF),
      ),
      SubjectProgress(
        subjectName: 'Social Studies',
        percentage: 0.70,
        score: 70,
        total: 100,
        icon: Icons.public_outlined,
        themeColor: Color(0xFFD97706),
        circleBgColor: Color(0xFFFEF3C7),
      ),
      SubjectProgress(
        subjectName: 'Hindi',
        percentage: 0.88,
        score: 88,
        total: 100,
        customIconText: 'अ',
        themeColor: Color(0xFFE11D48),
        circleBgColor: Color(0xFFFFE4E6),
      ),
      SubjectProgress(
        subjectName: 'Computer',
        percentage: 0.80,
        score: 80,
        total: 100,
        icon: Icons.desktop_windows_outlined,
        themeColor: Color(0xFF0891B2),
        circleBgColor: Color(0xFFCFFAFE),
      ),
    ];

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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallProgressCard(),
                const SizedBox(height: 20),
                const Text(
                  'Subject Wise Performance',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSubjectPerformanceCard(subjects),
                const SizedBox(height: 20),
                const Text(
                  'Recent Test / Exam Results',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRecentResultsCard(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard() {
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
              const Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '78%',
                      style: TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Good Job! Keep it up.',
                      style: TextStyle(color: AppColors.darkGrey, fontSize: 12),
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
                      child: const LinearProgressIndicator(
                        value: 0.78,
                        minHeight: 8,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF16A34A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '390',
                            style: TextStyle(color: Color(0xFF16A34A)),
                          ),
                          TextSpan(
                            text: ' / 500',
                            style: TextStyle(
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

  Widget _buildSubjectPerformanceCard(List<SubjectProgress> subjects) {
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
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: sub.circleBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: sub.customIconText != null
                    ? Text(
                        sub.customIconText!,
                        style: TextStyle(
                          color: sub.themeColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Icon(sub.icon, color: sub.themeColor, size: 20),
              ),
              const SizedBox(width: 14),
              // Name and progress bar
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
                        value: sub.percentage,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          sub.themeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Percentage text and fraction score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(sub.percentage * 100).toInt()}%',
                    style: TextStyle(
                      color: sub.themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sub.score} / ${sub.total}',
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

  Widget _buildRecentResultsCard() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unit Test - 1',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '20 May 2025',
                  style: TextStyle(color: AppColors.darkGrey, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '78%',
                style: TextStyle(
                  color: Color(0xFF0F65D6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '390 / 500',
                style: TextStyle(color: AppColors.darkGrey, fontSize: 11.5),
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
    );
  }
}
