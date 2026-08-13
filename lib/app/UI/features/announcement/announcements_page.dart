import 'package:edunest/app/UI/features/announcement/announcement_detail_page.dart';
import 'package:edunest/app/core/helper/date_util.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/announcement/announcement_model.dart';
import 'package:edunest/app/data/repository/features_repo.dart';
import 'package:edunest/app/global_widgets/edunest_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final FeaturesRepo featuresRepo = FeaturesRepo();

  List<AnnouncementItem> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final announcements = await featuresRepo.getStudentAnnouncements();
      if (!mounted) return;
      setState(() => _announcements = announcements);
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
          'Announcements',
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
              ElevatedButton(
                onPressed: _loadAnnouncements,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_announcements.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadAnnouncements,
        color: AppColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: const [
            SizedBox(height: 80),
            EdunestEmptyState(
              title: 'No Announcements',
              subtitle: 'School announcements will appear here.',
              icon: Icons.campaign_outlined,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          return _buildAnnouncementCard(_announcements[index]);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementItem item) {
    final dateText = item.publishDate != null
        ? '${DateUtil.getDay(item.publishDate)} ${DateUtil.getMonth(item.publishDate)} ${DateUtil.getYear(item.publishDate)}'
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(AppValues.radiusLarge),
      onTap: () => Get.to(
        () => AnnouncementDetailPage(
          title: item.title,
          message: item.message,
          dateText: dateText,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppValues.radius12),
        padding: const EdgeInsets.all(AppValues.paddingDefault),
        decoration: BoxDecoration(
          color: AppColors.colorWhite,
          borderRadius: BorderRadius.circular(AppValues.radiusLarge),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.notificationPurpleBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.campaign_rounded,
                color: AppColors.notificationPurpleIcon,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (dateText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.borderGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
