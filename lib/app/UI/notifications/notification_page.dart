import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Homework Uploaded',
      'subtitle': 'New homework has been uploaded for Mathematics.',
      'time': '10:30 AM',
      'isUnread': true,
      'icon': Icons.menu_book_rounded,
      'iconColor': AppColors.primary,
      'iconBgColor': AppColors.blueBackground,
    },
    {
      'title': 'Attendance Marked',
      'subtitle': 'Your attendance has been marked for today.',
      'time': '09:15 AM',
      'isUnread': true,
      'icon': Icons.calendar_today_rounded,
      'iconColor': AppColors.notificationGreenIcon,
      'iconBgColor': AppColors.notificationGreenBg,
    },
    {
      'title': 'Fee Receipt Generated',
      'subtitle': 'Your fee receipt for July 2026 has been generated.',
      'time': '08:45 AM',
      'isUnread': false,
      'icon': Icons.currency_rupee_rounded,
      'iconColor': AppColors.notificationOrangeIcon,
      'iconBgColor': AppColors.notificationOrangeBg,
    },
    {
      'title': 'School Announcement',
      'subtitle': 'Annual Sports Day will be held on 18 August 2026.',
      'time': 'Yesterday',
      'isUnread': false,
      'icon': Icons.campaign_outlined,
      'iconColor': AppColors.notificationPurpleIcon,
      'iconBgColor': AppColors.notificationPurpleBg,
    },
    {
      'title': 'Bus Update',
      'subtitle': 'Bus #GJ-01-AB-123 is on the way.',
      'time': 'Yesterday',
      'isUnread': false,
      'icon': Icons.directions_bus_rounded,
      'iconColor': AppColors.notificationCyanIcon,
      'iconBgColor': AppColors.notificationCyanBg,
    },
    {
      'title': 'Exam Schedule Published',
      'subtitle': 'Mid Term exam schedule is now available. Check now.',
      'time': '22 Jul 2026',
      'isUnread': false,
      'icon': Icons.assignment_outlined,
      'iconColor': AppColors.notificationRedIcon,
      'iconBgColor': AppColors.notificationRedBg,
    },
    {
      'title': 'Circular Published',
      'subtitle': 'New circular has been published regarding library hours.',
      'time': '21 Jul 2026',
      'isUnread': false,
      'icon': Icons.star_outline_rounded,
      'iconColor': AppColors.notificationAmberIcon,
      'iconBgColor': AppColors.notificationAmberBg,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
          'Notifications',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.colorWhite,
                    borderRadius: BorderRadius.circular(AppValues.radius20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorBlack.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.lightBackground,
                      indent: 60,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      final bool isUnread = item['isUnread'] as bool;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 14.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 18, right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnread
                                    ? AppColors.primary
                                    : AppColors.transparent,
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item['iconBgColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkText,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item['time'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkGrey,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Column(
                  children: const [
                    Text(
                      "You're all caught up!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We'll notify you when something new arrives.",
                      style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
