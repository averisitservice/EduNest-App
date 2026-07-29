import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/utils/app_constants.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/timetable_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();
  final ScrollController _scrollController = ScrollController();

  TimetableModel? _timetable;
  bool _isLoading = true;
  bool _dayLoading = false;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTimetable({String? day}) async {
    if (!mounted) return;
    setState(() {
      if (day == null) {
        _isLoading = true;
      } else {
        _dayLoading = true;
      }
    });

    try {
      final timetable = await featuresRepo.getStudentTimetable(day: day);
      if (!mounted) return;
      setState(() {
        _timetable = timetable;
        if (day == null) {
          _selectedDay = _defaultDayIndex(timetable);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToIndex(_selectedDay);
          });
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _dayLoading = false;
        });
      }
    }
  }

  Future<void> _onDaySelected(int index) async {
    final timetable = _timetable;
    if (timetable == null) return;

    setState(() => _selectedDay = index);
    _scrollToIndex(index);

    await _fetchTimetable(day: timetable.days[index].dayName);
  }

  void _scrollToIndex(int index) {
    if (_scrollController.hasClients) {
      final targetOffset = index * 125.0 - 60.0;
      final position = _scrollController.position;
      final offset = targetOffset.clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  int _defaultDayIndex(TimetableModel timetable) {
    final todayName = AppConstants.weekdays[(DateTime.now().weekday - 1) % 7];
    final index = timetable.days.indexWhere(
      (d) => d.dayName.toLowerCase() == todayName.toLowerCase(),
    );
    return index >= 0 ? index : 0;
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
          'Time Table',
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

    final timetable = _timetable;
    if (timetable == null || timetable.days.isEmpty) {
      return const Center(
        child: Text(
          'No timetable available.',
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: AppValues.fontSizeDefault,
          ),
        ),
      );
    }

    final day = timetable.days[_selectedDay];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDaySelector(timetable),
          const SizedBox(height: 18),
          if (_dayLoading)
            Container(
              height: AppValues.listBottomEmptySpace,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.primary),
            )
          else if (day.periods.isEmpty)
            Container(
              height: AppValues.listBottomEmptySpace,
              alignment: Alignment.center,
              child: const Text(
                'No periods scheduled for this day.',
                style: TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: day.periods.length,
              itemBuilder: (context, index) =>
                  _buildPeriodCard(day.periods[index]),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDaySelector(TimetableModel timetable) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          onPressed: _selectedDay > 0
              ? () => _onDaySelected(_selectedDay - 1)
              : null,
        ),
        Expanded(
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: timetable.days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dayData = timetable.days[index];
                final isSelected = index == _selectedDay;

                return InkWell(
                  onTap: () => _onDaySelected(index),
                  borderRadius: BorderRadius.circular(AppValues.radiusDefault),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.colorWhite,
                      borderRadius: BorderRadius.circular(
                        AppValues.radiusDefault,
                      ),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.borderGrey),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: AppValues.smallMargin,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      dayData.dayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.colorWhite
                            : AppColors.darkGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          onPressed: _selectedDay < timetable.days.length - 1
              ? () => _onDaySelected(_selectedDay + 1)
              : null,
        ),
      ],
    );
  }

  Widget _buildPeriodCard(Period period) {
    final bool isBreak = period.isBreak;
    final Color barColor = isBreak ? AppColors.colorPurple : AppColors.primary;
    final String startTime = DateUtil.getTime(period.startTime);
    final String endTime = DateUtil.getTime(period.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: AppValues.margin10),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radius12),
        border: Border.all(color: AppColors.lightBackground),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppValues.radius12),
                  bottomLeft: Radius.circular(AppValues.radius12),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      startTime,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'to',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endTime,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: AppValues.margin10),
              color: AppColors.borderGrey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 14.0,
                  bottom: 14.0,
                  right: 14.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isBreak
                          ? period.slotName
                          : (period.subjectName.isNotEmpty
                                ? period.subjectName
                                : period.slotName),
                      style: TextStyle(
                        fontSize: AppValues.fontSizeDefault,
                        fontWeight: FontWeight.bold,
                        color: isBreak
                            ? AppColors.colorPurple
                            : AppColors.darkText,
                      ),
                    ),
                    if (!isBreak) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 15,
                            color: AppColors.darkGrey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              period.teacherName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.darkGrey,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
