import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/student/student_detail_model.dart';
import 'package:edunest/app/data/model/student/student_model.dart';
import 'package:edunest/app/data/repository/profile_repo.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepo _profileRepo = ProfileRepo();

  StudentDetailModel? _student;
  bool _isLoading = true;
  String? _errorMessage;
  String? _expandedOption;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final StudentModel? stored = await CommonService.getStudent();
      if (stored == null) {
        throw ApiException('Please log in again to view your profile.');
      }
      final detail = await _profileRepo.getStudentDetailsById(stored.studentId);
      if (!mounted) return;
      setState(() => _student = detail);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _value(String? raw) => (raw == null || raw.isEmpty) ? '-' : raw;

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _formatGender(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    switch (raw.toUpperCase()) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = _student;

    String studentNameVal = '-';
    String displayClassVal = '-';
    String admissionNoVal = '-';
    String dateOfBirthVal = '-';
    String rollNoVal = '-';
    String aadharNoVal = '-';
    String genderVal = '-';
    String mobileNoVal = '-';
    String emailVal = '-';
    String classTeacherNameVal = '-';

    String fatherNameVal = '-';
    String motherNameVal = '-';
    String parentMobileVal = '-';
    String parentEmailVal = '-';
    String parentAadharVal = '-';

    String addressVal = '-';

    if (student != null) {
      studentNameVal = _value(student.studentName);
      displayClassVal = _value(student.displayClass);
      admissionNoVal = _value(student.admissionNo);
      dateOfBirthVal = _formatDate(student.dateOfBirth);
      rollNoVal = _value(student.rollNo);
      aadharNoVal = _value(student.aadharNo);
      genderVal = _formatGender(student.gender);
      mobileNoVal = _value(student.mobileNo);
      emailVal = _value(student.email);
      classTeacherNameVal = _value(student.classTeacherName);

      fatherNameVal = _value(student.fatherName);
      motherNameVal = _value(student.motherName);
      parentMobileVal = _value(student.parentMobile);
      parentEmailVal = _value(student.parentEmail);
      parentAadharVal = _value(student.parentAadhar);

      addressVal = _value(student.address);
    }
    return Scaffold(
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
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primary,
                      size: context.rw(AppValues.appBarIconSize),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: context.rf(22),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rw(48)),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(
                            context.rw(AppValues.paddingXLarge),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: context.rf(AppValues.fontSizeBody),
                                ),
                              ),
                              SizedBox(height: context.rh(12)),
                              TextButton(
                                onPressed: _loadStudentDetails,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rw(AppValues.paddingLarge),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: context.rh(16)),
                            Container(
                              padding: EdgeInsets.all(
                                context.rw(AppValues.paddingDefault),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.colorWhite,
                                borderRadius: BorderRadius.circular(
                                  context.rw(AppValues.radiusLarge),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.colorBlack.withValues(
                                      alpha: 0.04,
                                    ),
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
                                        color: AppColors.secondary.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: context.rw(32),
                                      backgroundColor: AppColors.blueBackground,
                                      backgroundImage:
                                          (student != null && student.photoUrl.isNotEmpty)
                                          ? CachedNetworkImageProvider(
                                              student.photoUrl,
                                            )
                                          : null,
                                      child:
                                          (student != null && student.photoUrl.isNotEmpty)
                                          ? null
                                          : Icon(
                                              Icons.person_outline_rounded,
                                              color: AppColors.primary,
                                              size: context.rw(AppValues.appBarIconSize),
                                            ),
                                    ),
                                  ),
                                  SizedBox(width: context.rw(16)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentNameVal,
                                          style: TextStyle(
                                            fontSize: context.rf(16),
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        SizedBox(height: context.rh(4)),
                                        Text(
                                          '$displayClassVal  •  $admissionNoVal',
                                          style: TextStyle(
                                            fontSize: context.rf(13),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.rh(20)),
                            _buildProfileOption(
                              title: 'Student Profile',
                              subtitle: 'Your personal profile details',
                              icon: Icons.badge_outlined,
                              iconColor: AppColors.primary,
                              bgColor: AppColors.blueBackground,
                              details: [
                                _buildDetailRow(
                                  'Admission No',
                                  admissionNoVal,
                                ),
                                _buildDetailRow(
                                  'Date of Birth',
                                  dateOfBirthVal,
                                ),
                                _buildDetailRow(
                                  'Class',
                                  displayClassVal,
                                ),
                                _buildDetailRow(
                                  'Roll Number',
                                  rollNoVal,
                                ),
                                _buildDetailRow(
                                  'Aadhaar Number',
                                  aadharNoVal,
                                ),
                                _buildDetailRow(
                                  'Gender',
                                  genderVal,
                                ),
                                _buildDetailRow(
                                  'Mobile Number',
                                  mobileNoVal,
                                ),
                                _buildDetailRow(
                                  'Email ID',
                                  emailVal,
                                ),
                                _buildDetailRow(
                                  'Class Teacher',
                                  classTeacherNameVal,
                                ),
                              ],
                            ),
                            _buildProfileOption(
                              title: 'Parent Details',
                              subtitle: 'Your family details',
                              icon: Icons.people_outline_rounded,
                              iconColor: AppColors.colorPurple,
                              bgColor: AppColors.lightPurple,
                              details: [
                                _buildDetailRow(
                                  'Father Name',
                                  fatherNameVal,
                                ),
                                _buildDetailRow(
                                  'Mother Name',
                                  motherNameVal,
                                ),
                                _buildDetailRow(
                                  'Primary Phone',
                                  parentMobileVal,
                                ),
                                _buildDetailRow(
                                  'Parent Email',
                                  parentEmailVal,
                                ),
                                _buildDetailRow(
                                  'Parent Aadhaar',
                                  parentAadharVal,
                                ),
                              ],
                            ),
                            _buildProfileOption(
                              title: 'Address Information',
                              subtitle: 'Your address details',
                              icon: Icons.location_on_outlined,
                              iconColor: AppColors.iconGreen,
                              bgColor: AppColors.lightGreen,
                              details: [
                                _buildDetailRow(
                                  'Address',
                                  addressVal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rh(AppValues.paddingSmall)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: context.rf(13),
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          SizedBox(width: context.rw(16)),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                fontSize: context.rf(13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required List<Widget> details,
  }) {
    final bool isExpanded = _expandedOption == title;

    return Container(
      margin: EdgeInsets.only(bottom: context.rh(12)),
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorBlack.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedOption = null;
              } else {
                _expandedOption = title;
              }
            });
          },
          borderRadius: BorderRadius.circular(context.rw(AppValues.radiusDefault)),
          child: Padding(
            padding: EdgeInsets.all(context.rw(AppValues.paddingDefault)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.rw(AppValues.margin10)),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(
                          context.rw(AppValues.margin10),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: context.rw(AppValues.iconDefaultSize),
                      ),
                    ),
                    SizedBox(width: context.rw(AppValues.paddingDefault)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: context.rf(15),
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          SizedBox(height: context.rh(2)),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: context.rf(12),
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: context.rw(AppValues.iconDefaultSize),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(height: 20, thickness: 0.5),
                            ...details,
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
