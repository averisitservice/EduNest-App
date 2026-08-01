import 'package:edunest/app/UI/features/homework/homework_detail_page.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeworkSubjectWise extends StatefulWidget {
  final List<HomeworkModelItem> homework;

  const HomeworkSubjectWise({super.key, required this.homework});

  @override
  State<HomeworkSubjectWise> createState() => _HomeworkSubjectWiseState();
}

class _HomeworkSubjectWiseState extends State<HomeworkSubjectWise> {
  final Set<String> _expandedSubjects = {};

  List<String> _getUniqueSubjects() {
    final subjects = widget.homework
        .map((item) => item.subjectName)
        .toSet()
        .toList();
    subjects.sort();
    return ['All Subjects', ...subjects];
  }

  String _getSubtitle(String subject) {
    final name = subject.toLowerCase();
    if (name.contains('art') ||
        name.contains('draw') ||
        name.contains('musi') ||
        name.contains('sport') ||
        name.contains('phys')) {
      return 'Other';
    }
    return 'Classwork';
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _getUniqueSubjects();

    if (widget.homework.isEmpty) {
      return const Center(
        child: Text(
          'No homework found.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectAccordionItem(subject);
      },
    );
  }

  Widget _buildSubjectAccordionItem(String subject) {
    final isExpanded = _expandedSubjects.contains(subject);

    final items = widget.homework.where((item) {
      if (subject == 'All Subjects') return true;
      return item.subjectName.toLowerCase() == subject.toLowerCase();
    }).toList();

    // Sort newest date first
    items.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    final subColor = SubjectIconService.colorFor(
      subject == 'All Subjects' ? null : subject,
    );
    final subBg = SubjectIconService.bgColorFor(
      subject == 'All Subjects' ? null : subject,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedSubjects.remove(subject);
              } else {
                _expandedSubjects.add(subject);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.colorWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorBlack.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: subBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    SubjectIconService.iconFor(
                      subject == 'All Subjects' ? null : subject,
                    ),
                    color: subColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    subject.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.darkGrey,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 12.0),
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'No homework for this subject.',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final item in items) _buildHomeworkCard(item),
                    ],
                  ),
          ),
      ],
    );
  }

  Widget _buildHomeworkCard(HomeworkModelItem item) {
    final subColor = SubjectIconService.colorFor(item.subjectName);
    final subBg = SubjectIconService.bgColorFor(item.subjectName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Get.to(() => HomeworkDetailPage(homeworkId: item.id));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Section (Tinted Subject Header)
            Container(
              color: subBg,
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: subColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      SubjectIconService.iconFor(item.subjectName),
                      color: AppColors.colorWhite,
                      size: 20,
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
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getSubtitle(item.subjectName),
                          style: const TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Section (Homework Title & Description)
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: AppColors.darkGrey,
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
