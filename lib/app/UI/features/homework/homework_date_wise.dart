import 'package:edunest/app/UI/features/homework/homework_detail_page.dart';
import 'package:edunest/app/core/helper/homework_status_helper.dart';
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
      return DateFormat('dd MMMM yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (homework.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              "That's all for now!",
              style: TextStyle(
                fontSize: AppValues.fontSizeBody,
                color: AppColors.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Pull down to refresh',
              style: TextStyle(
                fontSize: AppValues.fontSizeSmall,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      );
    }

    final sortedList = List<HomeworkModelItem>.from(homework)
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final items = grouped[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.darkGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    key,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: AppColors.colorWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGrey),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorBlack.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    HomeworkRowItem(item: items[i]),
                    if (i != items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: AppColors.lightBackground,
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class HomeworkRowItem extends StatelessWidget {
  final HomeworkModelItem item;

  const HomeworkRowItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final subColor = SubjectIconService.colorFor(item.subjectName);
    final status = HomeworkStatusHelper.forDueDate(item.dueDate);

    return InkWell(
      onTap: () {
        Get.to(() => HomeworkDetailPage(homeworkId: item.id));
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: subColor,
                borderRadius: BorderRadius.circular(8),
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
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  status != null
                      ? _buildStatusBadge(status)
                      : Text(
                          HomeworkStatusHelper.formatDueDate(item.dueDate),
                          style: const TextStyle(
                            color: AppColors.darkGrey,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkGrey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(HomeworkStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
