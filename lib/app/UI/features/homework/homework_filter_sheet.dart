import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_filter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeworkFilterSheet extends StatefulWidget {
  final HomeworkFilter? currentFilter;

  const HomeworkFilterSheet({super.key, this.currentFilter});

  @override
  State<HomeworkFilterSheet> createState() => _HomeworkFilterSheetState();
}

class _HomeworkFilterSheetState extends State<HomeworkFilterSheet> {
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
    final picked = await showDatePicker(
      context: context,
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
      HomeworkFilter(type: _selectedType, fromDate: _fromDate, toDate: _toDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: AppValues.fontSizeSubTitle,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            _buildOption(
              type: HomeworkFilterType.thisWeek,
              title: 'This Week',
              subtitle: 'Show homework for this week',
            ),
            _buildOption(
              type: HomeworkFilterType.thisMonth,
              title: 'This Month',
              subtitle: 'Show homework for this month',
            ),
            _buildOption(
              type: HomeworkFilterType.customRange,
              title: 'Custom Date Range',
              subtitle: 'Select a custom date range',
            ),
            if (_selectedType == HomeworkFilterType.customRange) ...[
              const SizedBox(height: 8),
              const Text(
                'From Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 6),
              _buildDateField(isFromDate: true),
              const SizedBox(height: 14),
              const Text(
                'To Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 6),
              _buildDateField(isFromDate: false),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppValues.radiusDefault),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppValues.radiusDefault),
                      ),
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(color: AppColors.colorWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
      borderRadius: BorderRadius.circular(AppValues.radiusDefault),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueBackground : AppColors.colorWhite,
          borderRadius: BorderRadius.circular(AppValues.radiusDefault),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : AppColors.darkText,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.darkGrey),
                  ),
                ],
              ),
            ),
            Radio<HomeworkFilterType>(
              value: type,
              groupValue: _selectedType,
              activeColor: AppColors.primary,
              onChanged: (value) => setState(() => _selectedType = value!),
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
      borderRadius: BorderRadius.circular(AppValues.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(AppValues.radiusDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('dd MMMM yyyy').format(date) : 'Select date',
              style: TextStyle(
                fontSize: 13.5,
                color: date != null ? AppColors.darkText : AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }
}
