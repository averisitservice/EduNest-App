import 'package:edunest/app/core/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/attendance/attendance_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  bool _isLoading = true;
  bool _showingMonth = false;
  AttendanceSummaryModel? _summary;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);

    final today = DateTime.now();
    final DateTime fromDate = _showingMonth
        ? DateTime(today.year, today.month, 1)
        : today.subtract(const Duration(days: 6));

    try {
      final summary = await featuresRepo.getStudentAttendance(
        fromDate: fromDate,
        toDate: today,
      );
      if (!mounted) return;
      setState(() => _summary = summary);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleRange() {
    setState(() => _showingMonth = !_showingMonth);
    _loadAttendance();
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
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppValues.paddingDefault,
                    vertical: AppValues.paddingSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRangeHeader(),
                      const SizedBox(height: 16),
                      _buildStatusRow(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _showingMonth
                                ? 'This Month Attendance'
                                : 'Last 7 Days Attendance',
                            style: const TextStyle(
                              fontSize: AppValues.fontSizeDefault,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          _buildViewMoreButton(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAttendanceDetailsList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRangeHeader() {
    final summary = _summary;
    final percent = summary != null ? summary.percent.toStringAsFixed(0) : '0';
    final attended = summary != null
        ? summary.presentDays + summary.lateDays
        : 0;
    final total = summary?.totalDays ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showingMonth ? 'This Month' : 'Last 7 Days',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '($attended / $total Days)',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final summary = _summary;
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            label: "Present",
            value: "${summary?.presentDays ?? 0}",
            unit: "Days",
            color: const Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            label: "Absent",
            value: "${summary?.absentDays ?? 0}",
            unit: "Days",
            color: const Color(0xFFE11D48),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            label: "Total",
            value: "${summary?.totalDays ?? 0}",
            unit: "Days",
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 3, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDetailsList() {
    final records = _summary?.records ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    "Date",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Day",
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Status",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No attendance records found.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.withValues(alpha: 0.08),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final record = records[index];
                final String date = DateFormat(
                  'dd MMM yyyy',
                ).format(record.attendanceDate);
                final String day = _formatDay(record.day);
                final String status = CommonService.getTodayStatusLabel(
                  record.status,
                );

                Color badgeColor;
                Color textColor;
                if (record.status == "PRESENT") {
                  badgeColor = const Color(0xFFE8F5E9);
                  textColor = const Color(0xFF16A34A);
                } else if (record.status == "ABSENT") {
                  badgeColor = const Color(0xFFFFE4E6);
                  textColor = const Color(0xFFE11D48);
                } else if (record.status == "LATE") {
                  badgeColor = const Color(0xFFFFEDD5);
                  textColor = const Color(0xFFEA580C);
                } else {
                  badgeColor = const Color(0xFFF1F5F9);
                  textColor = AppColors.darkGrey;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Date Column
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Day Column
                      Expanded(
                        flex: 3,
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Status Badge Column
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDay(String day) {
    if (day.isEmpty) return '';
    final lower = day.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  Widget _buildViewMoreButton() {
    return InkWell(
      onTap: _toggleRange,
      borderRadius: BorderRadius.circular(AppValues.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _showingMonth ? 'Last 7 Days' : 'This Month',
              style: const TextStyle(
                fontSize: AppValues.fontSizeCaption + 1,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              _showingMonth
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
