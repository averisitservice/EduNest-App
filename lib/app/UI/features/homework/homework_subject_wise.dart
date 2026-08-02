import 'package:edunest/app/UI/features/homework/homework_date_wise.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/data/model/homework/homework_model.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:flutter/material.dart';

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
    return subjects;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.homework.isEmpty) {
      return const EdunestEmptyState(subtitle: 'No homework posted yet.');
    }

    final subjects = _getUniqueSubjects();

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

    final items =
        widget.homework
            .where(
              (item) => item.subjectName.toLowerCase() == subject.toLowerCase(),
            )
            .toList()
          ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    final subColor = SubjectIconService.colorFor(subject);
    final subBg = SubjectIconService.bgColorFor(subject);

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
              border: Border.all(color: AppColors.borderGrey),
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
                    SubjectIconService.iconFor(subject),
                    color: subColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    subject,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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
                : Container(
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
          ),
      ],
    );
  }
}
