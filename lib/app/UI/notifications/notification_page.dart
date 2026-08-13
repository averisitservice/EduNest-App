import 'package:edunest/app/UI/features/announcement/announcement_detail_page.dart';
import 'package:edunest/app/UI/features/exam_schedule_page.dart';
import 'package:edunest/app/UI/features/homework/homework_detail_page.dart';
import 'package:edunest/app/UI/features/leave/leave_list_page.dart';
import 'package:edunest/app/UI/features/notes/notes_detail_page.dart';
import 'package:edunest/app/UI/features/result/result_detail_page.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/notification/notification_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const int _pageSize = 10;

  final FeaturesRepo featuresRepo = FeaturesRepo();

  final List<StudentNotificationItem> _notifications = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications(reset: true);
  }

  Future<void> _loadNotifications({bool reset = false}) async {
    setState(() {
      if (reset) {
        _isLoading = true;
        _currentPage = 0;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final result = await featuresRepo.getStudentNotifications(
        page: _currentPage,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        if (reset) {
          _notifications.clear();
        }
        _notifications.addAll(result.content);
        _hasMore = result.hasMore;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _currentPage++;
    await _loadNotifications();
  }

  ({IconData icon, Color iconColor, Color bgColor}) _styleFor(String type) {
    switch (type) {
      case 'HOMEWORK':
        return (
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.primary,
          bgColor: AppColors.blueBackground,
        );
      case 'NOTE':
        return (
          icon: Icons.note_alt_rounded,
          iconColor: AppColors.notificationGreenIcon,
          bgColor: AppColors.notificationGreenBg,
        );
      case 'EXAM_SCHEDULED':
        return (
          icon: Icons.assignment_outlined,
          iconColor: AppColors.notificationRedIcon,
          bgColor: AppColors.notificationRedBg,
        );
      case 'RESULT_PUBLISHED':
        return (
          icon: Icons.bar_chart_rounded,
          iconColor: AppColors.notificationAmberIcon,
          bgColor: AppColors.notificationAmberBg,
        );
      case 'LEAVE_STATUS':
        return (
          icon: Icons.event_available_rounded,
          iconColor: AppColors.notificationCyanIcon,
          bgColor: AppColors.notificationCyanBg,
        );
      case 'ANNOUNCEMENT':
        return (
          icon: Icons.campaign_outlined,
          iconColor: AppColors.notificationPurpleIcon,
          bgColor: AppColors.notificationPurpleBg,
        );
      case 'BIRTHDAY':
        return (
          icon: Icons.cake_rounded,
          iconColor: AppColors.notificationRedIcon,
          bgColor: AppColors.notificationRedBg,
        );
      default:
        return (
          icon: Icons.notifications_outlined,
          iconColor: AppColors.primary,
          bgColor: AppColors.blueBackground,
        );
    }
  }

  String _timeText(String? createdDate) {
    if (createdDate == null || createdDate.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(createdDate).toLocal();
      final now = DateTime.now();
      final isToday = dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day;
      final yesterday = now.subtract(const Duration(days: 1));
      final isYesterday = dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day;

      if (isToday) {
        final hour = dateTime.hour == 0
            ? 12
            : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
        return '$hour:$minute $ampm';
      }
      if (isYesterday) return 'Yesterday';

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (_) {
      return '';
    }
  }

  Future<void> _onNotificationTap(StudentNotificationItem item) async {
    if (!item.isRead) {
      setState(() {
        final index = _notifications.indexWhere(
          (n) => n.notificationId == item.notificationId,
        );
        if (index != -1) {
          _notifications[index] = StudentNotificationItem(
            notificationId: item.notificationId,
            type: item.type,
            referenceId: item.referenceId,
            title: item.title,
            body: item.body,
            isRead: true,
            createdDate: item.createdDate,
          );
        }
      });
      featuresRepo.markNotificationAsRead(item.notificationId).catchError((_) {});
    }

    final referenceId = item.referenceId;

    switch (item.type) {
      case 'HOMEWORK':
        if (referenceId != null) {
          Get.to(() => HomeworkDetailPage(homeworkId: referenceId));
        }
        break;
      case 'NOTE':
        if (referenceId != null) {
          Get.to(() => NotesDetailPage(noteId: referenceId));
        }
        break;
      case 'RESULT_PUBLISHED':
        if (referenceId != null) {
          Get.to(() => ResultDetailPage(examId: referenceId));
        }
        break;
      case 'EXAM_SCHEDULED':
        Get.to(() => const ExamSchedulePage());
        break;
      case 'LEAVE_STATUS':
        Get.to(() => const LeaveListPage());
        break;
      case 'ANNOUNCEMENT':
        Get.to(
          () => AnnouncementDetailPage(
            title: item.title,
            message: item.body,
            dateText: _timeText(item.createdDate),
          ),
        );
        break;
      case 'BIRTHDAY':
        Get.to(
          () => AnnouncementDetailPage(
            title: item.title,
            message: item.body,
            dateText: _timeText(item.createdDate),
            appBarTitle: 'Birthday',
            icon: Icons.cake_rounded,
            iconColor: AppColors.notificationRedIcon,
            iconBgColor: AppColors.notificationRedBg,
          ),
        );
        break;
      default:
        break;
    }
  }

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
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadNotifications(reset: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return const EdunestEmptyState(
        title: "You're all caught up!",
        subtitle: "We'll notify you when something new arrives.",
        icon: Icons.notifications_none_rounded,
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                final style = _styleFor(item.type);

                return InkWell(
                  onTap: () => _onNotificationTap(item),
                  child: Padding(
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
                            color: item.isRead
                                ? AppColors.transparent
                                : AppColors.primary,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: style.bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            style.icon,
                            color: style.iconColor,
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
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _timeText(item.createdDate),
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
                                item.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          if (_hasMore)
            _isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : OutlinedButton(
                    onPressed: _loadMore,
                    child: const Text('More'),
                  )
          else
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
    );
  }
}
