import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/home/widgets/drawer_menu.dart';
import 'package:edunest/app/global_widgets/permission_dialog.dart';
import 'package:edunest/app/UI/notifications/notification_page.dart';
import 'package:edunest/app/UI/features/timetable_page.dart';
import 'package:edunest/app/UI/features/exam_schedule_page.dart';
import 'package:edunest/app/UI/features/homework/homework_page.dart';
import 'package:edunest/app/UI/features/notes_page.dart';
import 'package:edunest/app/UI/features/results_page.dart';
import 'package:edunest/app/UI/features/fee/fee_payment_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student_home_model.dart';
import 'package:edunest/app/data/repository/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileRepo _profileRepo = ProfileRepo();

  StudentHomeModel? _home;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPermissionPrompts();
    });
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _profileRepo.getStudentHome();
      if (!mounted) return;
      setState(() => _home = data);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkAndShowPermissionPrompts() async {
    // Check location permission prompt
    final hasAskedLocation = await CommonService.hasAskedLocationPermission();
    if (!hasAskedLocation) {
      if (!mounted) return;
      final allowed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionDialog(
          icon: Icons.location_on_outlined,
          message: 'Allow EduNest to access this device\'s location?',
          onAllow: () => Navigator.pop(context, true),
          onDeny: () => Navigator.pop(context, false),
        ),
      );

      await CommonService.setAskedLocationPermission(true);

      if (allowed == true) {
        try {
          await Permission.location.request();
        } catch (_) {}
      }
    }

    // Check notification permission prompt
    final hasAskedNotification =
        await CommonService.hasAskedNotificationPermission();
    if (!hasAskedNotification) {
      if (!mounted) return;
      final allowed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PermissionDialog(
          icon: Icons.notifications_none_outlined,
          message: 'Allow EduNest to send you notifications?',
          onAllow: () => Navigator.pop(context, true),
          onDeny: () => Navigator.pop(context, false),
        ),
      );

      await CommonService.setAskedNotificationPermission(true);

      if (allowed == true) {
        try {
          await Permission.notification.request();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = _home;
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (home == null) {
      return const Scaffold(
        body: Center(child: Text('Student details not found')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const DrawerMenu(),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: AppColors.transparent,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.notes_rounded,
              color: AppColors.darkText,
              size: 28,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'EduNest',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.darkText,
                  size: 28,
                ),
                onPressed: () {
                  Get.to(() => const NotificationPage());
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: AppColors.colorWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
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
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeaderCard(home),
                const SizedBox(height: 20),
                _buildFeatureGrid(),
                const SizedBox(height: 20),
                _buildStatsRow(home),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(StudentHomeModel student) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            bottom: -4,
            child: Icon(
              Icons.school_outlined,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.03),
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 3.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.blueBackground,
                  backgroundImage: student.photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(student.photoUrl)
                      : null,
                  child: student.photoUrl.isEmpty
                      ? const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                          size: 28,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.studentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${student.displayClass}  •  Roll No. ${student.rollNo}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      student.academicYearName.isNotEmpty
                          ? 'Academic Year ${student.academicYearName}'
                          : '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureItem(
                Icons.calendar_month_rounded,
                'Time Table',
                AppColors.blueBackground,
                AppColors.primary,
                onTap: () {
                  Get.to(() => const TimetablePage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.assignment_rounded,
                'Exam',
                AppColors.notificationOrangeBg,
                AppColors.notificationOrangeIcon,
                onTap: () {
                  Get.to(() => const ExamSchedulePage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.bar_chart_rounded,
                'Marks & Results',
                AppColors.notificationRedBg,
                AppColors.notificationRedIcon,
                onTap: () {
                  Get.to(() => const ResultsPage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.campaign_rounded,
                'Announcements',
                AppColors.notificationPurpleBg,
                AppColors.notificationPurpleIcon,
                onTap: () {},
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildFeatureItem(
                Icons.note_alt_rounded,
                'Home Work',
                AppColors.notificationGreenBg,
                AppColors.notificationGreenIcon,
                onTap: () {
                  Get.to(() => const HomeworkPage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.book_rounded,
                'Notes',
                AppColors.lightGreen,
                AppColors.iconGreen,
                onTap: () {
                  Get.to(() => const NotesPage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.account_balance_wallet_rounded,
                'Fee Details',
                AppColors.notificationAmberBg,
                AppColors.notificationAmberIcon,
                onTap: () {
                  Get.to(() => const FeePaymentPage());
                },
              ),
            ),
            Expanded(
              child: _buildFeatureItem(
                Icons.exit_to_app_rounded,
                'Request Leave',
                AppColors.notificationCyanBg,
                AppColors.notificationCyanIcon,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(StudentHomeModel home) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppValues.paddingDefault),
            decoration: BoxDecoration(
              color: AppColors.colorWhite,
              borderRadius: BorderRadius.circular(AppValues.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: AppColors.colorBlack.withValues(alpha: 0.03),
                  blurRadius: AppValues.radiusMedium,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.blueBackground,
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusSmall + 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppValues.paddingSmall),
                    const Text(
                      "Today's Attendance",
                      style: TextStyle(
                        fontSize: AppValues.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppValues.paddingXSmall + 4,
                        vertical: AppValues.paddingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(
                          AppValues.radiusSmall + 4,
                        ),
                      ),
                      child: Text(
                        CommonService.getTodayStatusLabel(home.todayStatus),
                        style: const TextStyle(
                          color: AppColors.iconGreen,
                          fontSize: AppValues.fontSizeCaption + 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppValues.paddingLarge),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          const Text(
                            'This Month Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppValues.fontSizeCaption + 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: AppValues.paddingSmall),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: CircularProgressIndicator(
                                    value: home.thisMonthPercent / 100,
                                    strokeWidth: 6.0,
                                    color: AppColors.iconGreen,
                                    backgroundColor: AppColors.lightBackground,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${home.thisMonthPercent.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: AppValues.fontSizeSubTitle,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.iconGreen,
                                      ),
                                    ),
                                    const Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontSize: AppValues.fontSizeCaption - 2,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          const Text(
                            'Average Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppValues.fontSizeCaption + 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: AppValues.paddingSmall),
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 76,
                                  height: 76,
                                  child: CircularProgressIndicator(
                                    value: home.averagePercent / 100,
                                    strokeWidth: 6.0,
                                    color: AppColors.primary,
                                    backgroundColor: AppColors.lightBackground,
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${home.averagePercent.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: AppValues.fontSizeSubTitle,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const Text(
                                      'Average',
                                      style: TextStyle(
                                        fontSize: AppValues.fontSizeCaption - 2,
                                        color: AppColors.darkGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 90,
                      color: AppColors.borderGrey.withValues(alpha: 0.5),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Column(
                          children: [
                            _buildLegendItem(
                              Icons.check_circle_outline_rounded,
                              'Present',
                              '${home.presentDays}',
                              AppColors.notificationGreenIcon,
                              AppColors.notificationGreenBg,
                            ),
                            const SizedBox(height: AppValues.paddingSmall),
                            _buildLegendItem(
                              Icons.cancel_outlined,
                              'Absent',
                              '${home.absentDays}',
                              AppColors.notificationRedIcon,
                              AppColors.notificationRedBg,
                            ),
                            const SizedBox(height: AppValues.paddingSmall),
                            _buildLegendItem(
                              Icons.access_time_rounded,
                              'Late',
                              '${home.lateDays}',
                              AppColors.notificationAmberIcon,
                              AppColors.notificationAmberBg,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppValues.paddingLarge),
                const Divider(
                  height: AppValues.dividerHeight,
                  thickness: AppValues.dividerThickness / 2,
                ),
                const SizedBox(height: AppValues.paddingSmall + 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'View Attendance',
                      style: TextStyle(
                        fontSize: AppValues.fontSizeBody - 1,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: AppValues.iconSizeMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color bgColor,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppValues.radiusSmall),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppValues.fontSizeCaption + 1,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppValues.fontSizeCaption + 2,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64.0,
              height: 64.0,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
