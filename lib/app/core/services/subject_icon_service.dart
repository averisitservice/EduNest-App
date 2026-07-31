import 'package:flutter/material.dart';

class SubjectIconService {
  static const IconData defaultIcon = Icons.book_rounded;

  static const Map<String, IconData> _icons = {
    'mathematics': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'english': Icons.menu_book_rounded,
    'hindi': Icons.translate_rounded,
    'social studies': Icons.groups_rounded,
    'computer science': Icons.computer_rounded,
    'physics': Icons.bolt_rounded,
    'chemistry': Icons.biotech_rounded,
    'biology': Icons.eco_rounded,
    'history': Icons.account_balance_rounded,
    'geography': Icons.public_rounded,
    'physical education': Icons.sports_soccer_rounded,
    'social science': Icons.groups_rounded,
    'gujarati': Icons.language_rounded,
    'environmental studies': Icons.park_rounded,
    'sanskrit': Icons.auto_stories_rounded,
    'drawing': Icons.brush_rounded,
    'moral science': Icons.favorite_rounded,
    'civics': Icons.gavel_rounded,
    'economics': Icons.trending_up_rounded,
    'physics (adv)': Icons.bolt_rounded,
    'chemistry (adv)': Icons.biotech_rounded,
    'mathematics (adv)': Icons.calculate_rounded,
    'biology (adv)': Icons.eco_rounded,
    'computer science (adv)': Icons.computer_rounded,
    'accountancy': Icons.account_balance_wallet_rounded,
    'business studies': Icons.business_center_rounded,
    'economics (adv)': Icons.trending_up_rounded,
    'statistics': Icons.bar_chart_rounded,
    'mathematics (com)': Icons.calculate_rounded,
    'history (adv)': Icons.account_balance_rounded,
    'geography (adv)': Icons.public_rounded,
    'civics (adv)': Icons.gavel_rounded,
    'psychology': Icons.psychology_rounded,
    'sociology': Icons.people_alt_rounded,
    'philosophy': Icons.lightbulb_rounded,
    'fine arts': Icons.palette_rounded,
    'music': Icons.music_note_rounded,
    'gujarati (adv)': Icons.language_rounded,
    'english (adv)': Icons.menu_book_rounded,
    'hindi (adv)': Icons.translate_rounded,
  };

  static IconData iconFor(String? subjectName) {
    if (subjectName == null || subjectName.trim().isEmpty) {
      return defaultIcon;
    }
    return _icons[subjectName.trim().toLowerCase()] ?? defaultIcon;
  }

  static Color colorFor(String? subjectName) {
    if (subjectName == null || subjectName.trim().isEmpty) {
      return const Color(0xFF0F65D6);
    }
    final name = subjectName.trim().toLowerCase();
    if (name.contains('math')) {
      return const Color(0xFF4CAF50); // Green
    }
    if (name.contains('scie') ||
        name.contains('phys') ||
        name.contains('chem') ||
        name.contains('biol')) {
      return const Color(0xFFFF9800); // Orange
    }
    if (name.contains('engl')) {
      return const Color(0xFFE91E63); // Pink
    }
    if (name.contains('hind')) {
      return const Color(0xFF009688); // Teal
    }
    if (name.contains('social') ||
        name.contains('hist') ||
        name.contains('geog') ||
        name.contains('civi') ||
        name.contains('econ')) {
      return const Color(0xFF2196F3); // Blue
    }
    if (name.contains('art') ||
        name.contains('draw') ||
        name.contains('fine') ||
        name.contains('musi')) {
      return const Color(0xFF9C27B0); // Purple
    }
    return const Color(0xFF0F65D6); // Default primary blue
  }

  static Color bgColorFor(String? subjectName) {
    if (subjectName == null || subjectName.trim().isEmpty) {
      return const Color(0xFFEAF4FC);
    }
    final name = subjectName.trim().toLowerCase();
    if (name.contains('math')) {
      return const Color(0xFFE8F5E9); // Light Green
    }
    if (name.contains('scie') ||
        name.contains('phys') ||
        name.contains('chem') ||
        name.contains('biol')) {
      return const Color(0xFFFFF3E0); // Light Orange
    }
    if (name.contains('engl')) {
      return const Color(0xFFFCE4EC); // Light Pink
    }
    if (name.contains('hind')) {
      return const Color(0xFFE0F2F1); // Light Teal
    }
    if (name.contains('social') ||
        name.contains('hist') ||
        name.contains('geog') ||
        name.contains('civi') ||
        name.contains('econ')) {
      return const Color(0xFFE3F2FD); // Light Blue
    }
    if (name.contains('art') ||
        name.contains('draw') ||
        name.contains('fine') ||
        name.contains('musi')) {
      return const Color(0xFFF3E5F5); // Light Purple
    }
    return const Color(0xFFEAF4FC); // Default light blue
  }
}
