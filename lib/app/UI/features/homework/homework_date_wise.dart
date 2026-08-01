import 'package:edunest/app/UI/features/homework/homework_row_item.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:flutter/material.dart';
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
                border: Border.all(color: AppColors.cardBorder),
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
