import 'package:edunest/app/UI/features/homework/homework_date_wise.dart';
import 'package:edunest/app/UI/features/homework/homework_subject_wise.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework/homework_filter.dart';
import 'package:edunest/app/data/model/homework/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_filter.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  List<HomeworkModelItem> _homework = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  HomeworkFilter _activeFilter = HomeworkFilter.lastSevenDays();

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  Future<void> _openFilterSheet() async {
    final result = await EdunestFilter.show(
      context,
      currentFilter: _activeFilter,
    );

    if (result == null) return;
    setState(() => _activeFilter = result);
    _loadHomework();
  }

  Future<void> _loadHomework() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final (fromDate, toDate) = _activeFilter.dateRange;
      final homework = await featuresRepo.getStudentHomework(
        fromDate: fromDate,
        toDate: toDate,
      );
      if (!mounted) return;
      setState(() => _homework = homework);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Homework',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: context.rf(AppValues.fontSizeTitle),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.filter_list_rounded,
              color: AppColors.primary,
            ),
            onPressed: _openFilterSheet,
          ),
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
          child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTabSwitcher(),
                  SizedBox(height: context.rh(6)),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? HomeworkDateWise(homework: _homework)
                        : HomeworkSubjectWise(homework: _homework),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      color: AppColors.colorWhite,
      height: context.rh(48),
      child: Row(
        children: [_buildTab('Date Wise', 0), _buildTab('Subject Wise', 1)],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          _selectedTabIndex = index;
        }),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.rf(14),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
