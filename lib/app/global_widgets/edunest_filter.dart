import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework/homework_filter.dart';
import 'package:edunest/app/global_widgets/edunest_button.dart';
import 'package:edunest/app/global_widgets/edunest_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edunest/app/core/utils/responsive.dart';

class EdunestFilter extends StatefulWidget {
  final HomeworkFilter? currentFilter;
  final String title;

  const EdunestFilter({
    super.key,
    this.currentFilter,
    this.title = 'Filter',
  });

  /// Static helper method to show the filter bottom sheet
  static Future<HomeworkFilter?> show(
    BuildContext context, {
    HomeworkFilter? currentFilter,
    String title = 'Filter',
  }) {
    return showModalBottomSheet<HomeworkFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rw(AppValues.radiusXLarge)),
        ),
      ),
      builder: (context) => EdunestFilter(
        currentFilter: currentFilter,
        title: title,
      ),
    );
  }

  @override
  State<EdunestFilter> createState() => _EdunestFilterState();
}

class _EdunestFilterState extends State<EdunestFilter> {
  late HomeworkFilterType _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.currentFilter?.type ?? HomeworkFilterType.thisWeek;
    _fromDate = widget.currentFilter?.fromDate;
    _toDate = widget.currentFilter?.toDate;
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final initial = (isFromDate ? _fromDate : _toDate) ?? DateTime.now();
    final picked = await EdunestDatePicker.pick(
      context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFromDate) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      _selectedType = HomeworkFilterType.thisWeek;
      _fromDate = null;
      _toDate = null;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      HomeworkFilter(
        type: _selectedType,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: context.rw(16),
          right: context.rw(16),
          top: context.rh(12),
          bottom: MediaQuery.of(context).viewInsets.bottom + context.rh(16),
        ),
        child: RadioGroup<HomeworkFilterType>(
          groupValue: _selectedType,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedType = value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: context.rw(40),
                  height: context.rh(4),
                  margin: EdgeInsets.only(bottom: context.rh(16)),
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(context.rw(4)),
                  ),
                ),
              ),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: context.rf(AppValues.fontSizeSubTitle),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: context.rh(12)),
              _buildOption(
                type: HomeworkFilterType.thisWeek,
                title: 'This Week',
                subtitle: 'Show data for this week',
              ),
              _buildOption(
                type: HomeworkFilterType.thisMonth,
                title: 'This Month',
                subtitle: 'Show data for this month',
              ),
              _buildOption(
                type: HomeworkFilterType.customRange,
                title: 'Custom Date Range',
                subtitle: 'Select a custom date range',
              ),
              if (_selectedType == HomeworkFilterType.customRange) ...[
                SizedBox(height: context.rh(8)),
                Text(
                  'From Date',
                  style: TextStyle(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: context.rh(6)),
                _buildDateField(isFromDate: true),
                SizedBox(height: context.rh(14)),
                Text(
                  'To Date',
                  style: TextStyle(
                    fontSize: context.rf(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: context.rh(6)),
                _buildDateField(isFromDate: false),
              ],
              SizedBox(height: context.rh(20)),
              Row(
                children: [
                  Expanded(
                    child: EdunestButton(
                      title: 'Reset',
                      useGradient: false,
                      backgroundColor: AppColors.colorWhite,
                      borderColor: AppColors.borderGrey,
                      textColor: AppColors.darkText,
                      height: 48,
                      fontSize: 14,
                      radius: AppValues.radiusDefault,
                      onPressed: _reset,
                    ),
                  ),
                  SizedBox(width: context.rw(12)),
                  Expanded(
                    child: EdunestButton(
                      title: 'Apply',
                      useGradient: true,
                      height: 48,
                      fontSize: 14,
                      radius: AppValues.radiusDefault,
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required HomeworkFilterType type,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
      child: Container(
        margin: EdgeInsets.only(bottom: context.rh(10)),
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(10),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueBackground : AppColors.colorWhite,
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: context.rw(20),
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
            SizedBox(width: context.rw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: context.rf(14),
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: context.rf(11.5),
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            Radio<HomeworkFilterType>(
              value: type,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({required bool isFromDate}) {
    final date = isFromDate ? _fromDate : _toDate;
    return InkWell(
      onTap: () => _pickDate(isFromDate: isFromDate),
      borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(14),
          vertical: context.rh(12),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMMM yyyy').format(date)
                  : 'Select date',
              style: TextStyle(
                fontSize: context.rf(13.5),
                color: date != null ? AppColors.darkText : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: context.rw(18),
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }
}
