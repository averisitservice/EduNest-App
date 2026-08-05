import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    } catch (_) {
      // If error occurs or empty, retain basic structure
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Calculate statistics
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

  int get _holidayCount {
    return _attendanceMap.values
        .where((v) => v == 'HOLIDAY' || v == 'H')
        .length;
  }

  int get _totalWorkingCount {
    final computed = _presentCount + _absentCount + _leaveCount;
    if (_summary != null && _summary!.totalDays > 0) {
      final val = _summary!.totalDays - _holidayCount;
      return val > 0 ? val : computed;
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
    const primaryBlue = Color(0xFF0047AB);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'View Attendance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _focusedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  _focusedDay = picked;
                  _selectedDay = picked;
                });
                _loadAttendance();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryBlue))
            : RefreshIndicator(
                onRefresh: _loadAttendance,
                color: primaryBlue,
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
                      _buildMonthSummarySection(),
                      const SizedBox(height: 16),
                      _buildDisclaimerCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // 1. Overall Attendance Top Card
  Widget _buildOverallAttendanceCard() {
    final present = _presentCount;
    final absent = _absentCount;
    final leave = _leaveCount;
    final holiday = _holidayCount;
    final percent = _attendancePercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Donut Ring
          SizedBox(
            width: 105,
            height: 105,
            child: CustomPaint(
              painter: _AttendanceDonutPainter(
                present: present,
                absent: absent,
                leave: leave,
                holiday: holiday,
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
                        color: Color(0xFF0047AB),
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Divider
          Container(width: 1, height: 90, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 16),

          // Right Side Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Attendance',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2552),
                  ),
                ),
                const SizedBox(height: 10),
                // 2x2 Grid Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Present',
                        value: '$present',
                        unit: present == 1 ? 'Day' : 'Days',
                        dotColor: const Color(0xFF22C55E),
                        textColor: const Color(0xFF22C55E),
                      ),
                    ),
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Absent',
                        value: '$absent',
                        unit: absent == 1 ? 'Day' : 'Days',
                        dotColor: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
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
                        dotColor: const Color(0xFFF97316),
                        textColor: const Color(0xFFF97316),
                      ),
                    ),
                    Expanded(
                      child: _buildOverallStatItem(
                        label: 'Holiday',
                        value: '$holiday',
                        unit: holiday == 1 ? 'Day' : 'Days',
                        dotColor: const Color(0xFF94A3B8),
                        textColor: const Color(0xFF64748B),
                      ),
                    ),
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
                  color: Color(0xFF1E293B),
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Calendar Card
  Widget _buildCalendarCard() {
    final monthTitle = DateFormat('MMMM yyyy').format(_focusedDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Chevron Left, Month Title, Chevron Right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF0047AB),
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
                  color: Color(0xFF0047AB),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF0047AB),
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

          // Table Calendar
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
                color: Color(0xFF64748B),
              ),
              weekendStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
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
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Legend Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(
                label: 'Present',
                color: const Color(0xFF22C55E),
              ),
              _buildLegendItem(label: 'Absent', color: const Color(0xFFEF4444)),
              _buildLegendItem(label: 'Leave', color: const Color(0xFFF97316)),
              _buildLegendItem(
                label: 'Holiday',
                color: const Color(0xFF94A3B8),
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
            color: Color(0xFFCBD5E1),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    final status = _attendanceMap[dateKey] ?? '';

    Color bgColor = Colors.transparent;
    Color textColor = const Color(0xFF334155);
    bool hasStatusCircle = false;

    if (status == 'PRESENT' || status == 'P') {
      bgColor = const Color(0xFFDCFCE7); // Light Green fill
      textColor = const Color(0xFF15803D); // Bold Dark Green text
      hasStatusCircle = true;
    } else if (status == 'ABSENT' || status == 'A') {
      bgColor = const Color(0xFFEF4444); // Red fill
      textColor = Colors.white;
      hasStatusCircle = true;
    } else if (status == 'LEAVE' || status == 'LATE' || status == 'L') {
      bgColor = const Color(0xFFF97316); // Orange fill
      textColor = Colors.white;
      hasStatusCircle = true;
    } else if (status == 'HOLIDAY' || status == 'H') {
      bgColor = const Color(0xFFE2E8F0); // Grey fill
      textColor = const Color(0xFF475569);
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
              ? Border.all(color: const Color(0xFF0047AB), width: 2)
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
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  // 3. "This Month Summary" Section
  Widget _buildMonthSummarySection() {
    final present = _presentCount;
    final absent = _absentCount;
    final leave = _leaveCount;
    final holiday = _holidayCount;
    final totalWorking = _totalWorkingCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Month Summary',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F2552),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                value: '$present',
                line1: 'Present',
                line2: 'Days',
                bgColor: const Color(0xFFF0FDF4),
                textColor: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.cancel_rounded,
                iconColor: const Color(0xFFDC2626),
                value: '$absent',
                line1: 'Absent',
                line2: 'Days',
                bgColor: const Color(0xFFFEF2F2),
                textColor: const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFFEA580C),
                value: '$leave',
                line1: 'Leave',
                line2: leave == 1 ? 'Day' : 'Days',
                bgColor: const Color(0xFFFFF7ED),
                textColor: const Color(0xFFEA580C),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFF64748B),
                value: '$holiday',
                line1: 'Holiday',
                line2: holiday == 1 ? 'Day' : 'Days',
                bgColor: const Color(0xFFF8FAFC),
                textColor: const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFF2563EB),
                value: '$totalWorking',
                line1: 'Total Working',
                line2: 'Days',
                bgColor: const Color(0xFFEFF6FF),
                textColor: const Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String line1,
    required String line2,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            line1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.1,
            ),
          ),
          Text(
            line2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Disclaimer Note Box
  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: Color(0xFF2563EB), size: 22),
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
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Please contact school office for any discrepancies.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2563EB),
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

// Donut Painter for multi-colored circular chart
class _AttendanceDonutPainter extends CustomPainter {
  final int present;
  final int absent;
  final int leave;
  final int holiday;

  _AttendanceDonutPainter({
    required this.present,
    required this.absent,
    required this.leave,
    required this.holiday,
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

    final total = present + absent + leave + holiday;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (total == 0) {
      paint.color = const Color(0xFF22C55E);
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    const gapAngle = 0.08;

    final items = [
      (present, const Color(0xFF22C55E)),
      (absent, const Color(0xFFEF4444)),
      (leave, const Color(0xFFF97316)),
      (holiday, const Color(0xFF94A3B8)),
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
        oldDelegate.leave != leave ||
        oldDelegate.holiday != holiday;
  }
}
