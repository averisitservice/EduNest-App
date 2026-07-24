import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/values/app_colors.dart';
import 'package:edunest/app/data/model/school_contact_model.dart';
import 'package:edunest/app/data/repository/profile_repo.dart';
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
              // Custom Header/AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
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
                          'School Contacts',
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoTile(
                                    icon: Icons.school_outlined,
                                    title: 'School Name',
                                    subtitle: _value(_contact?.schoolName),
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.location_on_outlined,
                                    title: 'Address',
                                    subtitle: _value(_contact?.address),
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Contact Person',
                                    subtitle: _value(_contact?.contactName),
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.phone_outlined,
                                    title: 'Contact No.',
                                    subtitle: _value(_contact?.contactPhone),
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.mail_outline_rounded,
                                    title: 'Email Address',
                                    subtitle: _value(_contact?.contactEmail),
                                  ),
                                  _buildInfoTile(
                                    icon: Icons.language_rounded,
                                    title: 'Website',
                                    subtitle: _value(_contact?.website),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bottom Brand Section
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Powered By',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.menu_book_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'EDUNEXT',
                                      style: TextStyle(
                                        fontSize: 16,
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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 26),
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
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
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
