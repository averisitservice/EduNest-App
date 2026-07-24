import 'package:cached_network_image/cached_network_image.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/data/model/student_detail_model.dart';
import 'package:edunest/app/data/model/student_model.dart';
import 'package:edunest/app/data/repository/student_repo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StudentRepo _studentRepo = StudentRepo();

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
      final detail = await _studentRepo.getStudentDetailsById(stored.studentId);
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
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
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
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
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
                                      radius: 32,
                                      backgroundColor: AppColors.blueBackground,
                                      backgroundImage:
                                          _student?.photoUrl.isNotEmpty == true
                                          ? CachedNetworkImageProvider(
                                              _student!.photoUrl,
                                            )
                                          : null,
                                      child:
                                          _student?.photoUrl.isNotEmpty == true
                                          ? null
                                          : const Icon(
                                              Icons.person_outline_rounded,
                                              color: AppColors.primary,
                                              size: 32,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _value(_student?.studentName),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_value(_student?.displayClass)}  •  ${_value(_student?.admissionNo)}',
                                          style: const TextStyle(
                                            fontSize: 13,
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
                            const SizedBox(height: 20),
                            _buildProfileOption(
                              title: 'Student Profile',
                              subtitle: 'Your personal profile details',
                              icon: Icons.badge_outlined,
                              iconColor: const Color(0xFF0F65D6),
                              bgColor: const Color(0xFFEAF4FC),
                              details: [
                                _buildDetailRow(
                                  'Admission No',
                                  _value(_student?.admissionNo),
                                ),
                                _buildDetailRow(
                                  'Date of Birth',
                                  _formatDate(_student?.dateOfBirth),
                                ),
                                _buildDetailRow(
                                  'Class',
                                  _value(_student?.displayClass),
                                ),
                                _buildDetailRow(
                                  'Roll Number',
                                  _value(_student?.rollNo),
                                ),
                                _buildDetailRow(
                                  'Aadhaar Number',
                                  _value(_student?.aadharNo),
                                ),
                                _buildDetailRow(
                                  'Gender',
                                  _formatGender(_student?.gender),
                                ),
                                _buildDetailRow(
                                  'Mobile Number',
                                  _value(_student?.mobileNo),
                                ),
                                _buildDetailRow(
                                  'Email ID',
                                  _value(_student?.email),
                                ),
                                _buildDetailRow(
                                  'Class Teacher',
                                  _value(_student?.classTeacherName),
                                ),
                              ],
                            ),
                            _buildProfileOption(
                              title: 'Parent Details',
                              subtitle: 'Your family details',
                              icon: Icons.people_outline_rounded,
                              iconColor: const Color(0xFF9C27B0),
                              bgColor: const Color(0xFFF3E5F5),
                              details: [
                                _buildDetailRow(
                                  'Father Name',
                                  _value(_student?.fatherName),
                                ),
                                _buildDetailRow(
                                  'Mother Name',
                                  _value(_student?.motherName),
                                ),
                                _buildDetailRow(
                                  'Primary Phone',
                                  _value(_student?.parentMobile),
                                ),
                                _buildDetailRow(
                                  'Parent Email',
                                  _value(_student?.parentEmail),
                                ),
                                _buildDetailRow(
                                  'Parent Aadhaar',
                                  _value(_student?.parentAadhar),
                                ),
                              ],
                            ),
                            _buildProfileOption(
                              title: 'Address Information',
                              subtitle: 'Your address details',
                              icon: Icons.location_on_outlined,
                              iconColor: const Color(0xFF4CAF50),
                              bgColor: const Color(0xFFE8F5E9),
                              details: [
                                _buildDetailRow(
                                  'Address',
                                  _value(_student?.address),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 12,
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
                      size: 24,
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
