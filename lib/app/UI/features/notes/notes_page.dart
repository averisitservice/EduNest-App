import 'package:edunest/app/UI/features/notes/notes_detail_page.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/subject_icon_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework/homework_filter.dart';
import 'package:edunest/app/data/model/homework/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:edunest/app/global_widgets/edunest_filter.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  List<HomeworkModelItem> _notes = [];
  bool _isLoading = true;
  String? _errorMessage;
  HomeworkFilter? _activeFilter = HomeworkFilter.lastSevenDays();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _openFilterSheet() async {
    final result = await EdunestFilter.show(context, currentFilter: _activeFilter);
    if (result == null) return;
    setState(() => _activeFilter = result);
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final (fromDate, toDate) = _activeFilter?.dateRange ?? (null, null);
      final notes = await featuresRepo.getStudentNotes(
        fromDate: fromDate,
        toDate: toDate,
      );
      if (!mounted) return;
      setState(() => _notes = notes);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
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
        title: Text(
          'Notes',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: context.rf(AppValues.fontSizeTitle),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
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

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.rw(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rf(AppValues.fontSizeBody),
                  color: AppColors.darkGrey,
                ),
              ),
              SizedBox(height: context.rh(16)),
              ElevatedButton(onPressed: _loadNotes, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_notes.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotes,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            SizedBox(height: context.rh(80)),
            const EdunestEmptyState(subtitle: 'No notes posted yet.'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: context.rw(16.0),
          vertical: context.rh(12.0),
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final item = _notes[index];
          return _buildNoteCard(context, item);
        },
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, HomeworkModelItem item) {
    return InkWell(
      onTap: () {
        Get.to(() => NotesDetailPage(noteId: item.id));
      },
      borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
      child: Container(
        margin: EdgeInsets.only(bottom: context.rh(AppValues.radius12)),
        padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
        decoration: BoxDecoration(
          color: AppColors.colorWhite,
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusLarge)),
          border: Border.all(color: AppColors.lightBackground),
          boxShadow: [
            BoxShadow(
              color: AppColors.colorBlack.withValues(alpha: 0.02),
              blurRadius: AppValues.smallMargin,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: context.rw(44),
              height: context.rw(44),
              decoration: const BoxDecoration(
                color: AppColors.blueBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                SubjectIconService.iconFor(item.subjectName),
                color: AppColors.primary,
                size: context.rw(22),
              ),
            ),
            SizedBox(width: context.rw(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subjectName,
                    style: TextStyle(
                      color: AppColors.darkText,
                      fontSize: context.rf(16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.rh(6)),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: context.rf(13.5),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.rw(12)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkGrey,
              size: context.rw(20),
            ),
          ],
        ),
      ),
    );
  }
}
