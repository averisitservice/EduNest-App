import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/UI/home/widgets/drawer_menu.dart';
import 'package:edunest/app/UI/notifications/notification_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StudentModel? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    try {
      final student = await CommonService.getStudent();
      if (mounted) {
        setState(() {
          _student = student;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = _student;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      drawer: const DrawerMenu(),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.notes_rounded,
              color: AppColors.darkText,
              size: 28,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'EduNest',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: AppValues.fontSizeTitle,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.darkText,
                  size: 28,
                ),
                onPressed: () {
                  Get.to(() => const NotificationPage());
                },
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.errorColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
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
              : student == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppValues.paddingDefault),
                  child: Column(children: [_buildProfileHeaderCard(student)]),
                ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(StudentModel student) {
    return Container(
      padding: const EdgeInsets.all(AppValues.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(AppValues.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2.5,
              ),
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.blueBackground,
              backgroundImage: student.photoUrl.isNotEmpty
                  ? CachedNetworkImageProvider(student.photoUrl)
                  : null,
              child: student.photoUrl.isEmpty
                  ? const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.primary,
                      size: AppValues.appBarIconSize,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: AppValues.paddingDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.studentName,
                  style: const TextStyle(
                    fontSize: AppValues.fontSizeTitle,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: AppValues.paddingXSmall),
                Text(
                  '${student.displayClass}  •  Roll No. ${student.rollNo}',
                  style: const TextStyle(
                    fontSize: AppValues.fontSizeBody,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: AppValues.paddingXSmall),
                const Text(
                  'Academic Year 2026-27',
                  style: TextStyle(
                    fontSize: AppValues.fontSizeSmall,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
