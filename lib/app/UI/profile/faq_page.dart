import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/global_widgets/edunest_divider.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'How are fees managed in the ERP?',
      'answer':
          'Fees are managed through automated fee structures, online payments, receipts, and detailed reports.',
    },
    {
      'question': "Can parents view their child's academic progress?",
      'answer':
          'Yes. Parents can view attendance, exam results, report cards, homework, notices, and teacher messages in real-time through the Parent Portal or mobile app.',
    },
    {
      'question': 'How are exam results and report cards generated?',
      'answer':
          'Exam results and report cards are generated automatically based on configured grading systems.',
    },
    {
      'question': 'Is student data safe in the ERP?',
      'answer':
          'Yes, student data is completely safe and secure in the ERP with role-based access control, data encryption, and regular backups.',
    },
    {
      'question': 'Does the ERP support online classes and links?',
      'answer':
          'Yes, the ERP supports scheduling online classes and sharing meeting links (Zoom, Google Meet, Teams) directly with students and parents.',
    },
    {
      'question': 'Who do I contact if I need help?',
      'answer':
          'For anything related to your marks, attendance, fees, or profile details, please contact your class teacher or the school office through the School Contacts section.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rw(8.0),
                  vertical: context.rh(8.0),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primary,
                        size: context.rw(AppValues.appBarIconSize),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'FAQS',
                          style: TextStyle(
                            fontSize: context.rf(22),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.rw(48)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.rw(20.0),
                    vertical: context.rh(10.0),
                  ),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    final String question = faq['question']!;
                    final String answer = faq['answer']!;
                    final bool isExpanded = _expandedIndex == index;

                    return Container(
                      margin: EdgeInsets.only(
                        bottom: context.rh(AppValues.paddingDefault),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.colorWhite,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.colorBlack.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusDefault),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedIndex = null;
                              } else {
                                _expandedIndex = index;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(
                            context.rw(AppValues.radiusDefault),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              context.rw(AppValues.paddingDefault),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question,
                                        style: TextStyle(
                                          fontSize: context.rf(15),
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: context.rw(16)),
                                    Icon(
                                      isExpanded
                                          ? Icons.remove_rounded
                                          : Icons.add_rounded,
                                      color: AppColors.darkText,
                                      size: context.rw(AppValues.iconDefaultSize),
                                    ),
                                  ],
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: isExpanded
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const EdunestDivider(
                                              height: 10,
                                              thickness: 0.5,
                                            ),
                                            Text(
                                              answer,
                                              style: TextStyle(
                                                fontSize: context.rf(13),
                                                color: AppColors.darkGrey,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
