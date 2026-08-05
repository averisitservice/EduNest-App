import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/attendance/attendance_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  bool _isLoading = true;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  AttendanceSummaryModel? _summary;
  Map<String, String> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);

    final DateTime fromDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final DateTime toDate = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    );

    try {
      final summary = await featuresRepo.getStudentAttendance(
        fromDate: fromDate,
        toDate: toDate,
      );
      if (!mounted) return;

      final Map<String, String> map = {};
      for (var record in summary.records) {
        final key = DateFormat('yyyy-MM-dd').format(record.attendanceDate);
        map[key] = record.status.toUpperCase();
      }

      setState(() {
        _summary = summary;
        _attendanceMap = map;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _presentCount {
    if (_summary != null && _summary!.presentDays > 0) {
      return _summary!.presentDays;
    }
    return _attendanceMap.values
        .where((v) => v == 'PRESENT' || v == 'P')
        .length;
  }

  int get _absentCount {
    if (_summary != null && _summary!.absentDays > 0) {
      return _summary!.absentDays;
    }
    return _attendanceMap.values.where((v) => v == 'ABSENT' || v == 'A').length;
  }

  int get _leaveCount {
    if (_summary != null && _summary!.lateDays > 0) {
      return _summary!.lateDays;
    }
    return _attendanceMap.values
        .where((v) => v == 'LEAVE' || v == 'LATE' || v == 'L')
        .length;
  }

  int get _totalWorkingCount {
    final computed = _presentCount + _absentCount + _leaveCount;
    if (_summary != null && _summary!.totalDays > 0) {
      return _summary!.totalDays;
    }
    return computed;
  }

  double get _attendancePercent {
    if (_summary != null && _summary!.percent > 0) {
      return _summary!.percent;
    }
    final total = _totalWorkingCount;
    if (total == 0) return 0.0;
    return (_presentCount / total) * 100;
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
          'View Attendance',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : RefreshIndicator(
                  onRefresh: _loadAttendance,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverallAttendanceCard(),
                        const SizedBox(height: 16),
                        _buildCalendarCard(),
                        const SizedBox(height: 20),
                        _buildDisclaimerCard(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOverallAttendanceCard() {
    final present = _presentCount;
    final absent = _absentCount;
    final leave = _leaveCount;
    final percent = _attendancePercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            height: 105,
            child: CustomPaint(
              painter: _AttendanceDonutPainter(
                present: present,
                absent: absent,
                leave: leave,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Container(width: 1, height: 90, color: AppColors.borderGrey),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Present',
                        value: '$present',
                        unit: present == 1 ? 'Day' : 'Days',
                        dotColor: AppColors.notificationGreenIcon,
                        textColor: AppColors.notificationGreenIcon,
                      ),
                    ),
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Absent',
                        value: '$absent',
                        unit: absent == 1 ? 'Day' : 'Days',
                        dotColor: AppColors.notificationRedIcon,
                        textColor: AppColors.notificationRedIcon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Leave',
                        value: '$leave',
                        unit: leave == 1 ? 'Day' : 'Days',
                        dotColor: AppColors.notificationOrangeIcon,
                        textColor: AppColors.notificationOrangeIcon,
                      ),
                    ),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatItem({
    required String label,
    required String value,
    required String unit,
    required Color dotColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final monthTitle = DateFormat('MMMM yyyy').format(_focusedDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month - 1,
                      1,
                    );
                  });
                  _loadAttendance();
                },
              ),
              Text(
                monthTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    _focusedDay = DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                      1,
                    );
                  });
                  _loadAttendance();
                },
              ),
            ],
          ),
          const SizedBox(height: 6),

          TableCalendar(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            rowHeight: 44,
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              weekendStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isOutside: false),
              outsideBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isOutside: true),
              todayBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(day, isOutside: false, isToday: true),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildCalendarDayCell(
                    day,
                    isOutside: false,
                    isSelected: true,
                  ),
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _loadAttendance();
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.lightBackground),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                label: 'Present',
                color: AppColors.notificationGreenIcon,
              ),
              _buildLegendItem(
                label: 'Absent',
                color: AppColors.notificationRedIcon,
              ),
              _buildLegendItem(
                label: 'Leave',
                color: AppColors.notificationOrangeIcon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDayCell(
    DateTime day, {
    required bool isOutside,
    bool isToday = false,
    bool isSelected = false,
  }) {
    if (isOutside) {
      return Center(
        child: Text(
          '${day.day}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.borderGrey,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final status = _attendanceMap[dateKey] ?? '';

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.darkText;
    bool hasStatusCircle = false;

    if (status == 'PRESENT' || status == 'P') {
      bgColor = AppColors.notificationGreenBg;
      textColor = AppColors.notificationGreenIcon;
      hasStatusCircle = true;
    } else if (status == 'ABSENT' || status == 'A') {
      bgColor = AppColors.notificationRedBg;
      textColor = AppColors.notificationRedIcon;
      hasStatusCircle = true;
    } else if (status == 'LEAVE' || status == 'LATE' || status == 'L') {
      bgColor = AppColors.notificationOrangeBg;
      textColor = AppColors.notificationOrangeIcon;
      hasStatusCircle = true;
    }

    final isSelectedOrToday = isSelected || isSameDay(day, _selectedDay);

    return Center(
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: hasStatusCircle ? bgColor : Colors.transparent,
          shape: BoxShape.circle,
          border: isSelectedOrToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blueBackground,
        borderRadius: BorderRadius.circular(AppValues.radiusDefault),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance is updated regularly.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Please contact school office for any discrepancies.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDonutPainter extends CustomPainter {
  final int present;
  final int absent;
  final int leave;

  _AttendanceDonutPainter({
    required this.present,
    required this.absent,
    required this.leave,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 10.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final total = present + absent + leave;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (total == 0) {
      paint.color = AppColors.notificationGreenIcon;
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    const gapAngle = 0.08;

    final items = [
      (present, AppColors.notificationGreenIcon),
      (absent, AppColors.notificationRedIcon),
      (leave, AppColors.notificationOrangeIcon),
    ];

    final nonZeroCount = items.where((e) => e.$1 > 0).length;
    final totalGap = nonZeroCount > 1 ? gapAngle * nonZeroCount : 0.0;
    final availableAngle = (2 * math.pi) - totalGap;

    for (final item in items) {
      final count = item.$1;
      final color = item.$2;
      if (count <= 0) continue;

      final sweepAngle = (count / total) * availableAngle;
      paint.color = color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _AttendanceDonutPainter oldDelegate) {
    return oldDelegate.present != present ||
        oldDelegate.absent != absent ||
        oldDelegate.leave != leave;
  }
}
