import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/core/values/app_values.dart';
import 'package:edunest/app/data/model/profile/school_contact_model.dart';
import 'package:edunest/app/data/repository/profile_repo.dart';
import 'package:edunest/app/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class SchoolContactsPage extends StatefulWidget {
  const SchoolContactsPage({super.key});

  @override
  State<SchoolContactsPage> createState() => _SchoolContactsPageState();
}

class _SchoolContactsPageState extends State<SchoolContactsPage> {
  final ProfileRepo _profileRepo = ProfileRepo();

  SchoolContactModel? _contact;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSchoolContact();
  }

  Future<void> _loadSchoolContact() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final contact = await _profileRepo.getSchoolContact();
      if (!mounted) return;
      setState(() => _contact = contact);
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

  @override
  Widget build(BuildContext context) {
    final contact = _contact;
    String schoolNameVal = '-';
    String addressVal = '-';
    String contactNameVal = '-';
    String contactPhoneVal = '-';
    String contactEmailVal = '-';
    String websiteVal = '-';

    if (contact != null) {
      schoolNameVal = _value(contact.schoolName);
      addressVal = _value(contact.address);
      contactNameVal = _value(contact.contactName);
      contactPhoneVal = _value(contact.contactPhone);
      contactEmailVal = _value(contact.contactEmail);
      websiteVal = _value(contact.website);
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
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rw(8.0),
                  vertical: context.rh(8.0),
                ),
                child: Row(
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
                          'School Contacts',
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
                              SizedBox(height: context.rh(AppValues.paddingMedium)),
                              TextButton(
                                onPressed: _loadSchoolContact,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.rw(AppValues.paddingXLarge),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoTile(
                                    icon: Icons.school_outlined,
                                    title: 'School Name',
                                    subtitle: schoolNameVal,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.location_on_outlined,
                                    title: 'Address',
                                    subtitle: addressVal,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Contact Person',
                                    subtitle: contactNameVal,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.phone_outlined,
                                    title: 'Contact No.',
                                    subtitle: contactPhoneVal,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.mail_outline_rounded,
                                    title: 'Email Address',
                                    subtitle: contactEmailVal,
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.language_rounded,
                                    title: 'Website',
                                    subtitle: websiteVal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: context.rh(5), top: context.rh(5)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Powered By',
                                  style: TextStyle(
                                    fontSize: context.rf(12),
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: context.rh(6)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      color: AppColors.primary,
                                      size: context.rw(18),
                                    ),
                                    SizedBox(width: context.rw(8)),
                                    Text(
                                      'EDUNEXT',
                                      style: TextStyle(
                                        fontSize: context.rf(16),
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.9,
                                        ),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rh(AppValues.paddingMedium)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: context.rw(26)),
          SizedBox(width: context.rw(16)),
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
                SizedBox(height: context.rh(4)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.rf(13),
                    color: AppColors.darkGrey,
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
