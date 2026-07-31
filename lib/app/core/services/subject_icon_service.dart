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
    final name = subjectName.trim().toLowerCase();

    final exact = _icons[name];
    if (exact != null) return exact;

    if (name.contains('math')) return Icons.calculate_rounded;
    if (name.contains('comp')) return Icons.computer_rounded;
    if (name.contains('phys') && !name.contains('education')) {
      return Icons.bolt_rounded;
    }
    if (name.contains('chem')) return Icons.biotech_rounded;
    if (name.contains('biol')) return Icons.eco_rounded;
    if (name.contains('scie')) return Icons.science_rounded;
    if (name.contains('engl')) return Icons.menu_book_rounded;
    if (name.contains('hind')) return Icons.translate_rounded;
    if (name.contains('guja')) return Icons.language_rounded;
    if (name.contains('sanskrit')) return Icons.auto_stories_rounded;
    if (name.contains('evs') || name.contains('environ')) {
      return Icons.park_rounded;
    }
    if (name.contains('value') || name.contains('moral')) {
      return Icons.favorite_rounded;
    }
    if (name.contains('art') || name.contains('draw')) {
      return Icons.brush_rounded;
    }
    if (name.contains('fine')) return Icons.palette_rounded;
    if (name.contains('musi')) return Icons.music_note_rounded;
    if (name.contains('physical') || name.contains('sport')) {
      return Icons.sports_soccer_rounded;
    }
    if (name.contains('psychol')) return Icons.psychology_rounded;
    if (name.contains('sociol')) return Icons.people_alt_rounded;
    if (name.contains('philosoph')) return Icons.lightbulb_rounded;
    if (name.contains('account')) return Icons.account_balance_wallet_rounded;
    if (name.contains('business')) return Icons.business_center_rounded;
    if (name.contains('stat')) return Icons.bar_chart_rounded;
    if (name.contains('social') ||
        name.contains('hist') ||
        name.contains('geog') ||
        name.contains('civi') ||
        name.contains('econ')) {
      return Icons.groups_rounded;
    }

    return defaultIcon;
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
