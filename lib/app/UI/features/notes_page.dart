import 'package:edunest/app/UI/features/homework_item_card.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await featuresRepo.getStudentNotes();
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
        title: const Text(
          'Notes',
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

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 16),
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
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'No notes posted yet.',
                style: TextStyle(
                  fontSize: AppValues.fontSizeBody,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _notes.length,
        itemBuilder: (context, index) =>
            HomeworkItemCard(item: _notes[index], showDueDate: false),
      ),
    );
  }
}
