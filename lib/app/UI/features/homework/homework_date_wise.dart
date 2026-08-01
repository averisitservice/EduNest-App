import 'package:edunest/app/UI/features/homework/homework_detail_page.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeworkDateWise extends StatelessWidget {
  final List<HomeworkModelItem> homework;

  const HomeworkDateWise({super.key, required this.homework});

  String _formatHeaderDate(String dateStr) {
    if (dateStr.isEmpty) return 'No Date';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
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
    if (homework.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No homework found.',
              style: TextStyle(
                fontSize: AppValues.fontSizeBody,
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    final sortedList = List<HomeworkModelItem>.from(homework);
    // Sort newest date first
    sortedList.sort((a, b) => b.dueDate.compareTo(a.dueDate));

    final Map<String, List<HomeworkModelItem>> grouped = {};
    for (final item in sortedList) {
      final key = _formatHeaderDate(item.dueDate);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final keys = grouped.keys.toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final items = grouped[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 10.0, left: 4.0),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ),
            for (final item in items) _buildHomeworkCard(item),
          ],
        );
      },
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
