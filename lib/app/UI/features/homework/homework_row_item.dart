import 'package:edunest/app/UI/features/homework/homework_detail_page.dart';
import 'package:edunest/app/core/helper/homework_status_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
