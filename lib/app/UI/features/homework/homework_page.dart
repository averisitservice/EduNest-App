import 'package:edunest/app/UI/features/homework/homework_date_wise.dart';
import 'package:edunest/app/UI/features/homework/homework_filter_sheet.dart';
import 'package:edunest/app/UI/features/homework/homework_subject_wise.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_filter.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
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
  HomeworkFilter? _activeFilter;

  @override
  void initState() {
    super.initState();
    _loadHomework();
  }

  List<HomeworkModelItem> get _filteredHomework {
    final filter = _activeFilter;
    if (filter == null) return _homework;
    return _homework.where((item) => filter.matches(item.dueDate)).toList();
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<HomeworkFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppValues.radiusXLarge),
        ),
      ),
      builder: (context) => HomeworkFilterSheet(currentFilter: _activeFilter),
    );

    if (result == null) return;
    setState(() => _activeFilter = result);
  }

  Future<void> _loadHomework() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final homework = await featuresRepo.getStudentHomework();
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Homework',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _activeFilter != null
                  ? AppColors.primary
                  : AppColors.darkText,
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
              : RefreshIndicator(
                  onRefresh: _loadHomework,
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTabSwitcher(),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _selectedTabIndex == 0
                            ? HomeworkDateWise(homework: _filteredHomework)
                            : HomeworkSubjectWise(homework: _filteredHomework),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      color: AppColors.colorWhite,
      height: 48,
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
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
