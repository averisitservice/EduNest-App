import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/home/widgets/drawer_menu.dart';
import 'package:edunest/app/UI/notifications/notification_page.dart';
import 'package:edunest/app/UI/features/timetable_page.dart';
import 'package:edunest/app/UI/features/exam_schedule_page.dart';
import 'package:edunest/app/UI/features/homework/homework_page.dart';
import 'package:edunest/app/UI/features/notes/notes_page.dart';
import 'package:edunest/app/UI/features/results_page.dart';
import 'package:edunest/app/UI/features/fee/fee_payment_page.dart';
import 'package:edunest/app/UI/features/attendance_page.dart';
import 'package:edunest/app/UI/features/leave/leave_list_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student/student_home_model.dart';
import 'package:edunest/app/data/repository/profile_repo.dart';
import 'package:edunest/app/core/utils/responsive.dart';
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
    final hasAskedLocation = await CommonService.hasAskedLocationPermission();
    if (!hasAskedLocation) {
      await CommonService.setAskedLocationPermission(true);
      try {
        await Permission.location.request();
      } catch (_) {}
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
            icon: Icon(
              Icons.notes_rounded,
              color: AppColors.darkText,
              size: context.rw(28),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Text(
          'EduNest',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: context.rf(AppValues.fontSizeTitle),
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
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.darkText,
                  size: context.rw(28),
                ),
                onPressed: () {
                  Get.to(() => const NotificationPage());
                },
              ),
              Positioned(
                right: context.rw(6),
                top: context.rh(6),
                child: Container(
                  padding: EdgeInsets.all(context.rw(4)),
                  decoration: const BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: AppColors.colorWhite,
                      fontSize: context.rf(10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: context.rw(8)),
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
            padding: EdgeInsets.symmetric(
              horizontal: context.rw(16.0),
              vertical: context.rh(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeaderCard(home),
                SizedBox(height: context.rh(20)),
                _buildFeatureGrid(),
                SizedBox(height: context.rh(20)),
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
      padding: EdgeInsets.all(context.rw(16.0)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(24.0)),
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
              size: context.rw(80),
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
                  radius: context.rw(38),
                  backgroundColor: AppColors.blueBackground,
                  backgroundImage: student.photoUrl.isNotEmpty
                      ? CachedNetworkImageProvider(student.photoUrl)
                      : null,
                  child: student.photoUrl.isEmpty
                      ? Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                          size: context.rw(28),
                        )
                      : null,
                ),
              ),
              SizedBox(width: context.rw(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.studentName,
                      style: TextStyle(
                        fontSize: context.rf(20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    SizedBox(height: context.rh(4)),
                    Text(
                      '${student.displayClass}  •  Roll No. ${student.rollNo}',
                      style: TextStyle(
                        fontSize: context.rf(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: context.rh(6)),
                    Text(
                      student.academicYearName.isNotEmpty
                          ? 'Academic Year ${student.academicYearName}'
                          : '',
                      style: TextStyle(
                        fontSize: context.rf(12),
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
                'Leave',
                AppColors.notificationCyanBg,
                AppColors.notificationCyanIcon,
                onTap: () {
                  Get.to(() => const LeaveListPage());
                },
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
            padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
            decoration: BoxDecoration(
              color: AppColors.colorWhite,
              borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
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
                      width: context.rw(36),
                      height: context.rw(36),
                      decoration: BoxDecoration(
                        color: AppColors.blueBackground,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusSmall + 2),
                        ),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: context.rw(18),
                      ),
                    ),
                    SizedBox(width: context.rw(AppValues.paddingSmall)),
                    Expanded(
                      child: Text(
                        "Today's Attendance",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.rf(AppValues.fontSizeDefault),
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.rw(AppValues.paddingXSmall + 4),
                        vertical: context.rh(AppValues.paddingXSmall),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.radiusSmall + 4),
                        ),
                      ),
                      child: Text(
                        CommonService.getTodayStatusLabel(home.todayStatus),
                        style: TextStyle(
                          color: AppColors.iconGreen,
                          fontSize: context.rf(AppValues.fontSizeCaption + 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.rh(AppValues.paddingLarge)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            'This Month Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.rf(AppValues.fontSizeCaption + 1),
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          SizedBox(height: context.rh(AppValues.paddingSmall)),
                          SizedBox(
                            width: context.rw(80),
                            height: context.rw(80),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: context.rw(76),
                                  height: context.rw(76),
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
                                      style: TextStyle(
                                        fontSize: context.rf(AppValues.fontSizeSubTitle),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.iconGreen,
                                      ),
                                    ),
                                    Text(
                                      'This Month',
                                      style: TextStyle(
                                        fontSize: context.rf(AppValues.fontSizeCaption - 2),
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
                          Text(
                            'Average Attendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.rf(AppValues.fontSizeCaption + 1),
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          SizedBox(height: context.rh(AppValues.paddingSmall)),
                          SizedBox(
                            width: context.rw(80),
                            height: context.rw(80),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: context.rw(76),
                                  height: context.rw(76),
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
                                      style: TextStyle(
                                        fontSize: context.rf(AppValues.fontSizeSubTitle),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      'Average',
                                      style: TextStyle(
                                        fontSize: context.rf(AppValues.fontSizeCaption - 2),
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
                      height: context.rh(90),
                      color: AppColors.borderGrey.withValues(alpha: 0.5),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: EdgeInsets.only(left: context.rw(4.0)),
                        child: Column(
                          children: [
                            _buildLegendItem(
                              Icons.check_circle_outline_rounded,
                              'Present',
                              '${home.presentDays}',
                              AppColors.notificationGreenIcon,
                              AppColors.notificationGreenBg,
                            ),
                            SizedBox(height: context.rh(AppValues.paddingSmall)),
                            _buildLegendItem(
                              Icons.cancel_outlined,
                              'Absent',
                              '${home.absentDays}',
                              AppColors.notificationRedIcon,
                              AppColors.notificationRedBg,
                            ),
                            SizedBox(height: context.rh(AppValues.paddingSmall)),
                            _buildLegendItem(
                              Icons.event_busy_rounded,
                              'Leave',
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
                SizedBox(height: context.rh(AppValues.paddingLarge)),
                const Divider(
                  height: AppValues.dividerHeight,
                  thickness: AppValues.dividerThickness / 2,
                ),
                SizedBox(height: context.rh(AppValues.paddingSmall + 2)),
                InkWell(
                  onTap: () {
                    Get.to(() => const AttendancePage());
                  },
                  borderRadius: BorderRadius.circular(context.rw(AppValues.radiusSmall)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: context.rh(4.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'View Attendance',
                          style: TextStyle(
                            fontSize: context.rf(AppValues.fontSizeBody - 1),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                          size: context.rw(AppValues.iconSizeMedium),
                        ),
                      ],
                    ),
                  ),
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
          width: context.rw(28),
          height: context.rw(28),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(context.rw(AppValues.radiusSmall)),
          ),
          child: Icon(icon, size: context.rw(16), color: iconColor),
        ),
        SizedBox(width: context.rw(8)),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: context.rf(AppValues.fontSizeCaption + 1),
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: context.rf(AppValues.fontSizeCaption + 2),
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
        padding: EdgeInsets.symmetric(
          vertical: context.rh(10.0),
          horizontal: context.rw(4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.rw(64.0),
              height: context.rw(64.0),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: context.rw(28.0)),
            ),
            SizedBox(height: context.rh(8.0)),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.rf(13),
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
