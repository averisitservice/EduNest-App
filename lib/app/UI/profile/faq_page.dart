import 'package:edunest/app/core/values/app_colors.dart';
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'FAQS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    final String question = faq['question']!;
                    final String answer = faq['answer']!;
                    final bool isExpanded = _expandedIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
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
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      isExpanded
                                          ? Icons.remove_rounded
                                          : Icons.add_rounded,
                                      color: AppColors.darkText,
                                      size: 24,
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
                                            const Divider(
                                              height: 20,
                                              thickness: 0.5,
                                            ),
                                            Text(
                                              answer,
                                              style: const TextStyle(
                                                fontSize: 13,
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
