import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:flutter/material.dart';

class _SubjectStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _SubjectStyle(this.icon, this.iconColor, this.bgColor);
}

const List<_SubjectStyle> _subjectStyles = [
  _SubjectStyle(Icons.menu_book_rounded, Color(0xFF0F65D6), Color(0xFFEAF4FC)),
  _SubjectStyle(Icons.science_outlined, Color(0xFF16A34A), Color(0xFFF0FDF4)),
  _SubjectStyle(Icons.edit_note_rounded, Color(0xFF9333EA), Color(0xFFF3E8FF)),
  _SubjectStyle(Icons.language_rounded, Color(0xFFD97706), Color(0xFFFEF3C7)),
  _SubjectStyle(
    Icons.desktop_windows_outlined,
    Color(0xFF0891B2),
    Color(0xFFCFFAFE),
  ),
  _SubjectStyle(Icons.public_rounded, Color(0xFFDC2626), Color(0xFFFEE2E2)),
];

_SubjectStyle _styleFor(String subjectName) {
  final index = subjectName.isEmpty
      ? 0
      : subjectName.codeUnits.fold<int>(0, (sum, c) => sum + c) %
            _subjectStyles.length;
  return _subjectStyles[index];
}

class HomeworkItemCard extends StatelessWidget {
  final HomeworkModelItem item;
  final bool showDueDate;

  const HomeworkItemCard({
    super.key,
    required this.item,
    this.showDueDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(item.subjectName);
    final displayDate = showDueDate && item.dueDate.isNotEmpty
        ? '${DateUtil.getDay(item.dueDate)} ${DateUtil.getMonth(item.dueDate)} ${DateUtil.getYear(item.dueDate)}'
        : '';

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: style.bgColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(style.icon, color: style.iconColor, size: 26),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.darkGrey,
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                    if (displayDate.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                        ],
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),
                ],
                if (item.attachmentUrl != null &&
                    item.attachmentUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Attachment',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
