import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  // Static state variables
  String _selectedMonth = "May 2024";

  final List<String> _months = ["May 2024", "June 2024", "July 2024"];

  // Mock attendance data
  final List<Map<String, dynamic>> _attendanceRecords = [
    {"date": "31 May 2024", "day": "Friday", "status": "Present"},
    {"date": "30 May 2024", "day": "Thursday", "status": "Present"},
    {"date": "29 May 2024", "day": "Wednesday", "status": "Present"},
    {"date": "28 May 2024", "day": "Tuesday", "status": "Absent"},
    {"date": "27 May 2024", "day": "Monday", "status": "Present"},
    {"date": "24 May 2024", "day": "Friday", "status": "Present"},
    {"date": "23 May 2024", "day": "Thursday", "status": "Leave"},
    {"date": "22 May 2024", "day": "Wednesday", "status": "Present"},
    {"date": "21 May 2024", "day": "Tuesday", "status": "Present"},
    {"date": "20 May 2024", "day": "Monday", "status": "Present"},
    {"date": "17 May 2024", "day": "Friday", "status": "Present"},
    {"date": "16 May 2024", "day": "Thursday", "status": "Present"},
    {"date": "15 May 2024", "day": "Wednesday", "status": "Present"},
    {"date": "14 May 2024", "day": "Tuesday", "status": "Absent"},
    {"date": "13 May 2024", "day": "Monday", "status": "Present"},
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppValues.paddingDefault,
              vertical: AppValues.paddingSmall,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownsRow(),
                const SizedBox(height: 16),

                // 3. Status Counter Cards
                _buildStatusRow(),
                const SizedBox(height: 20),

                // 4. Attendance Details Title
                const Text(
                  'Attendance Details',
                  style: TextStyle(
                    fontSize: AppValues.fontSizeDefault,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),

                // 5. Attendance Details List (Header + Items)
                _buildAttendanceDetailsList(),
                const SizedBox(height: 20),

                // 6. Bottom Info Banner
                _buildBottomInfoBanner(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownsRow() {
    return Row(
      children: [
        // Select Month Dropdown
        Expanded(
          child: _buildCustomDropdown(
            label: "Select Month",
            value: _selectedMonth,
            icon: Icons.calendar_today_rounded,
            items: _months,
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedMonth = val);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        // Select Subject Dropdown
        // 2. Dropdowns (Month & Subject)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.3),
            ),
          ),
          child: const Column(
            children: [
              Text(
                'Overall Attendance',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '92%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '(138 / 150 Days)',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGrey,
                size: 20,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.primary, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            label: "Present",
            value: "24",
            unit: "Days",
            color: const Color(0xFF16A34A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            label: "Absent",
            value: "2",
            unit: "Days",
            color: const Color(0xFFE11D48),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            label: "Leave",
            value: "1",
            unit: "Day",
            color: const Color(0xFFEA580C),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatusCard(
            label: "Total",
            value: "27",
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
          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceRecords.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.withValues(alpha: 0.08), height: 1),
            itemBuilder: (context, index) {
              final record = _attendanceRecords[index];
              final String date = record["date"] ?? "";
              final String day = record["day"] ?? "";
              final String status = record["status"] ?? "Present";

              Color badgeColor;
              Color textColor;
              if (status == "Present") {
                badgeColor = const Color(0xFFE8F5E9);
                textColor = const Color(0xFF16A34A);
              } else if (status == "Absent") {
                badgeColor = const Color(0xFFFFE4E6);
                textColor = const Color(0xFFE11D48);
              } else {
                badgeColor = const Color(0xFFFFEDD5);
                textColor = const Color(0xFFEA580C);
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

  Widget _buildBottomInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Attendance is updated regularly. Please contact school office for any discrepancies.",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary.withValues(alpha: 0.9),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
